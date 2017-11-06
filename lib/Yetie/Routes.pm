package Yetie::Routes;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
    my ( $self, $app ) = @_;

    # TODO: 別の場所に移す
    $app->config( history_disable_route_names => [ 'RN_customer_login', 'RN_example' ] );

    $self->add_admin_routes($app);
    $self->add_catalog_routes($app);
}

# Routes for Admin
sub add_admin_routes {
    my ( $self, $app ) = @_;

    my $r = $app->routes->any( $app->pref('admin_uri_prefix') )->to( namespace => 'Yetie::Controller' );

    # Not required authorization Routes
    {
        my $login = $r->any('login')->to( controller => 'admin-staff' );
        $login->any('/')->to('#login')->name('RN_admin_login');
    }

    # Required authorization Routes
    $r = $r->under->to('admin-staff#authorize')->name('RN_admin_bridge');
    {
        # Dashboard
        $r->get( '/' => sub { shift->redirect_to('RN_admin_dashboard') } );
        $r->get('/dashboard')->to('admin-dashboard#index')->name('RN_admin_dashboard');

        # Logout
        $r->get('/logout')->to('admin-staff#logout')->name('RN_admin_logout');

        # Settings
        {
            my $settings = $r->any('/settings')->to( controller => 'admin-setting' );
            $settings->get('/')->to('#index')->name('RN_admin_settings');
            {
                my $addons = $settings->any('/addon')->to( controller => 'admin-addon' );
                $addons->get('/:action')->to('addon#')->name('RN_admin_settings_addon_action');
                $addons->get('/')->to('#index')->name('RN_admin_settings_addon');
            }
        }

        # Preferences
        {
            my $pref = $r->any('/preferences')->to( controller => 'admin-preference' );
            $pref->any('/')->to('#index')->name('RN_admin_preferences');
        }

        # Categories
        $r->any('/categories')->to('admin-category#index')->name('RN_admin_categories');

        # Products
        $r->any('/products')->to('admin-products#index')->name('RN_admin_products');

        # Product
        {
            my $product = $r->any('/product')->to( controller => 'admin-product' )->name('RN_admin_product');

            # NOTE: create, delete, duplicate はPOST requestのみにするべき
            $product->any('/create')->to('#create')->name('RN_admin_product_create');
            $product->any('/:product_id/delete')->to('#delete')->name('RN_admin_product_delete');
            $product->any('/:product_id/duplicate')->to('#duplicate')->name('RN_admin_product_duplicate');
            $product->any('/:product_id/edit')->to('#edit')->name('RN_admin_product_edit');
            $product->any('/:product_id/edit/category')->to('#category')->name('RN_admin_product_category');
        }

        # Orders
        $r->any('/orders')->to('admin-orders#index')->name('RN_admin_orders');

        # Order
        {
            # NOTE: create, delete, duplicate はPOST requestのみにするべき
            my $order = $r->any('/order')->to( controller => 'admin-order' );
            $order->get('/:id')->to('#index')->name('RN_admin_order');
            $order->any('/:id/edit')->to('#edit')->name('RN_admin_order_edit');
            $order->post('/delete')->to('#delete')->name('RN_admin_order_delete');

            # $order->any('/create')->to('#create')->name('RN_admin_order_create');
            $order->any('/:id/duplicate')->to('#duplicate')->name('RN_admin_order_duplicate');
        }
    }
}

# Routes for Catalog
sub add_catalog_routes {
    my ( $self, $app ) = @_;
    my $r = $app->routes->namespaces( ['Yetie::Controller::Catalog'] );

    # Route Examples
    $r->get('/')->to('example#welcome')->name('RN_top');
    $r->get('/regenerate_sid')->to('example#regenerate_sid');
    $r->any('/login_example')->to('login_example#index');

    # Cart
    $r->any('/cart')->to('cart#index')->name('RN_cart');
    $r->post('/cart/clear')->to('cart#clear')->name('RN_cart_clear');

    # Checkout
    {
        my $checkout = $r->any('/checkout')->to( controller => 'checkout' );
        $checkout->any('/')->to('#index')->name('RN_checkout');
        $checkout->any('/address')->to('#address')->name('RN_checkout_address');
        $checkout->any('/shipping')->to('#shipping')->name('RN_checkout_shipping');
        $checkout->any('/confirm')->to('#confirm')->name('RN_checkout_confirm');
        $checkout->get('/complete')->to('#complete')->name('RN_checkout_complete');
    }

    # For Customers
    $r->get('/register')->to('register#index')->name('RN_customer_create_account');
    $r->post('/register')->to('register#index')->name('RN_customer_create_account');

    $r->any('/login')->to('account#login')->name('RN_customer_login');
    $r->get('/logout')->to('account#logout')->name('RN_customer_logout');
    {
        # Required authorization Routes
        my $account = $r->under('/account')->to('account#authorize')->name('RN_customer_bridge');
        $account->get('/home')->to('account#home')->name('RN_customer_home');
        $account->get('/orders')->to('account#orders')->name('RN_customer_orders');
        $account->get('/wishlist')->to('account#wishlist')->name('RN_customer_wishlist');
    }

    # Product
    $r->any('/product/:product_id')->to('product#index')->name('RN_product');

    # Category
    $r->get('/category/:category_id')->to('category#index')->name('RN_category');
    $r->get('/:category_name/c/:category_id')->to('category#index')->name('RN_category_name_base');
}

1;