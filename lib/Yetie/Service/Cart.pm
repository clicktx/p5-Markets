package Yetie::Service::Cart;
use Mojo::Base 'Yetie::Service';

sub add_item {
    my ( $self, $args ) = @_;

    # NOTE: APIで利用する場合にproductがstashに無い場合は生成する。
    # productをMojo::Cache等でキャッシュするか？
    # キャッシュする場合はservice('product')->load_entity()等としてキャッシュを使うようにする
    # fileキャッシュで全てのproductのキャッシュを生成するのもありか？
    my $product = $self->controller->stash('product');
    if ( !$product ) { $product = $self->service('product')->find_product( $args->{product_id} ) }

    # FIXME: データマッピングは別のメソッドで行うようにする
    $args->{product_title} = $product->title;
    $args->{price}         = $product->price->to_data;
    $args->{tax_rule}      = $product->tax_rule->to_data;

    my $item = $self->factory('entity-cart_item')->construct($args);
    return $self->controller->cart->add_item($item);
}

sub find_cart {
    my ( $self, $cart_id ) = @_;

    my $session = $self->controller->server_session;
    my $data = $session->store->load_cart_data($cart_id) || {};
    return $self->factory('entity-cart')->construct($data);
}

sub merge_cart {
    my ( $self, $customer_cart_id ) = @_;
    my $c       = $self->controller;
    my $session = $c->server_session;

    my $customer_cart = $self->find_cart($customer_cart_id);
    return $customer_cart if !$c->cart;    # NOTE: necessary remember_me login

    my $merged_cart = $c->cart->merge($customer_cart);
    $session->remove_cart( $session->cart_id );
    return $merged_cart;
}

1;
__END__

=head1 NAME

Yetie::Service::Cart - Application Service Layer

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Service::Cart> inherits all attributes from L<Yetie::Service> and implements
the following new ones.

=head1 METHODS

L<Yetie::Service::Cart> inherits all methods from L<Yetie::Service> and implements
the following new ones.

=head2 C<add_item>

    my $cart = $service->add_item( $product, \%params);

Return L<Yetie::Domain::Entity::Cart> object.

=head2 C<find_cart>

    my $cart = $service->find_cart($cart_id);

Return L<Yetie::Domain::Entity::Cart> object.

=head2 C<merge_cart>

    my $merged_cart = $service->merge_cart($customer_cart_id);

Return L<Yetie::Domain::Entity::Cart> object.

Merge with saved customer cart.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Service>
