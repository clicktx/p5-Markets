use Mojo::Base -strict;

use t::Util;
use Test::More;
use Test::Mojo;

my $t   = Test::Mojo->new('App');
my $app = $t->app;

# routes
my $r = $app->routes->namespaces( ['Markets::Controller'] );
$r->find('RN_category_name_base')->remove;    # Hack for name base category
$r->get('/customer')->to('customer#login');
$r->get('/staff')->to('staff#login');
$r->get('/buged')->to('buged#login');

subtest 'is_logged_in' => sub {
    $t->get_ok('/customer')->json_is( { is_logged_in => 0 } );
    $t->get_ok('/staff')->json_is( { is_logged_in => 0 } );
    $t->get_ok('/buged')->json_is( { is_logged_in => undef } );
};

done_testing();

package Markets::Controller::Customer;
use Mojo::Base 'Markets::Controller::Catalog';

sub login {
    my $c = shift;
    return $c->render( json => { is_logged_in => $c->is_logged_in } );
}
1;

package Markets::Controller::Staff;
use Mojo::Base 'Markets::Controller::Admin';

sub login {
    my $c = shift;
    return $c->render( json => { is_logged_in => $c->is_logged_in } );
}
1;

package Markets::Controller::Buged;
use Mojo::Base 'Markets::Controller';

sub login {
    my $c = shift;
    return $c->render( json => { is_logged_in => $c->is_logged_in } );
}
1;
