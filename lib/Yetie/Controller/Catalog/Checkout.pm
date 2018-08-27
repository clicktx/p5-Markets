package Yetie::Controller::Catalog::Checkout;
use Mojo::Base 'Yetie::Controller::Catalog';

sub index {
    my $c = shift;

    # Redirect logged-in customer
    return $c->redirect_to('RN_checkout_shipping_address') if $c->is_logged_in;

    # Guest or a customer not logged in
    my $form = $c->form('checkout-index');
    $c->flash( ref => 'RN_checkout' );
    return $c->render() unless $form->has_data;

    # Check guest email
    # NOTE: 登録済みの顧客ではないか？
    # 認証済みのメールアドレスか？
    $form->do_validate;
    my $email = $c->factory('value-email')->create( value => $form->param('guest-email') );
    $c->cart->email($email);

    return $c->render();
}

sub shipping_address {
    my $c = shift;
    $c->render();
}

sub address {
    my $c = shift;

    my $form = $c->form('checkout-address');
    $form->fill_in( $c->cart );

    return $c->render() unless $form->has_data;
    return $c->render() unless $form->do_validate;

    # Update Cart
    my $address_fields = $c->cart->billing_address->field_names;

    # billing address
    foreach my $field ( @{$address_fields} ) {
        my $value = $form->param("billing_address.$field");
        $c->cart->billing_address->$field($value);
    }

    # shipping address
    my $shipments = $c->cart->shipments;
    $shipments->each(
        sub {
            my ( $shipment, $i ) = ( shift, shift );
            $i--;
            foreach my $field ( @{$address_fields} ) {
                my $value = $form->param("shipments.$i.shipping_address.$field");
                $shipment->shipping_address->$field($value);
            }
        }
    );
    return $c->redirect_to('RN_checkout_shipping');
}

sub shipping {
    my $c = shift;

    my $form = $c->form('checkout-shipping');
    return $c->render() unless $form->has_data;

    return $c->render() unless $form->do_validate;

    # 複数配送を使うか
    if ( $c->pref('can_multiple_shipments') ) {
        say 'multiple shipment is true';
    }
    else {
        say 'multiple shipment is false';
    }

    # shipping address
    # 商品をshipmentに移動
    # cart.itemsからitemを減らす。shipment.itemsを増やす
    # 本来は数量を考慮しなくてはならない
    # $item.quantityが0になった場合の動作はどうする？
    my $cart = $c->cart;
    $cart->items->each(
        sub {
            # カートitemsから削除
            my $item = $cart->remove_item( $_->id );

            # 配送itemsに追加
            $cart->add_shipping_item( 0, $item );
        }
    );

    # NOTE: 移動や追加をした際にis_modifiedをどのobjectに行うか
    # $cart->is_modified(1)? しか使わなければ実行時間は早く出来る。
    # Entity::Cart::is_modifiedも考慮して実装しよう

    return $c->redirect_to('RN_checkout_confirm');
}

#sub payment { }
# sub billing {
#     my $c = shift;
#     $c->render();
# }

sub confirm {
    my $c = shift;

    my $form = $c->form('checkout-confirm');
    return $c->render() unless $form->has_data;

    return $c->render() unless $form->do_validate;

    # checkout complete
    $c->complete_validate;
}

sub complete_validate {
    my $c = shift;

    # NOTE: itemsに商品がある場合 or shipment.itemsが1つも無い場合はcomplete出来ない。
    my $cart = $c->cart;
    return $c->redirect_to('RN_cart') if $cart->count('items') or !$cart->count('all_shipping_items');

    # Make order data
    my $order = $cart->to_order_data;

    # Customer id
    # ログイン購入
    my $customer_id = $c->server_session->data('customer_id');
    if ($customer_id) {
        $order->{customer} = { id => $customer_id };
    }
    else {
        # ゲスト購入
        # emailからcustomer_idを算出？新規顧客の場合はcustomer作成
        $order->{customer} = {};
    }

    # Address正規化
    my $schema_address = $c->app->schema->resultset('Address');

    # billing_address
    my $billing_address = $schema_address->find( { line1 => $order->{billing_address}->{line1} } );
    $order->{billing_address} = { id => $billing_address->id } if $billing_address;

    # shipping_address
    foreach my $shipment ( @{ $order->{shipments} } ) {
        my $result = $schema_address->find( { line1 => $shipment->{shipping_address}->{line1} } );
        next unless $result;
        my $shipping_address_id = $result->id;
        $shipment->{shipping_address} = { id => $shipping_address_id };
    }
    $order->{orders} = delete $order->{shipments};

    use DDP;
    p $order;    # debug

    # Store order
    my $schema = $c->app->schema;
    my $cb     = sub {

        # Order
        # $order->{order_number} = $schema->sequence('Order');
        # $schema->resultset('Order')->create($order);    # NOTE: itemsはbulk insert されない
        $schema->resultset('Sales')->create($order);

        # NOTE:
        # DBIx::Class::ResultSet https://metacpan.org/pod/DBIx::Class::ResultSet#populate
        # chekout の他に注文修正等で使う可能性があるのでresultsetにmethod化しておく？
        # $schema->resultset('Order')->create_with_bulkinsert_items($order);

        # bulk insert
        # my $items = $cart->items->first->to_array;
        # my $order_id = $schema->storage->last_insert_id;
        # my $data = $c->model('item')->to_array( $order_id, $items );
        # $schema->resultset('Order::Item')->populate($data);
    };

    use Try::Tiny;
    try {
        $schema->txn_do($cb);
    }
    catch {
        $schema->txn_failed($_);
    };

    # cart sessionクリア
    # cartクリア（再生成）
    my $newcart = $c->factory('entity-cart')->create( {} );
    $c->cart_session->data( $newcart->to_data );

    # redirect_to thank you page
    # $c->render();
    $c->redirect_to('RN_checkout_complete');
}

sub complete {
    my $c = shift;
    $c->render();
}

1;
