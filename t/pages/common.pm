package t::pages::common;

use Mojo::Base 'Test::Class';
use t::Util;
use Test::More;
use Test::Mojo;

has [qw/t app ua tx csrf_token/];
has sid => sub { t::Util::get_sid( shift->t ) };
has server_session => sub {
    my $self           = shift;
    my $server_session = t::Util::server_session( $self->t->app );
    $server_session->load( $self->sid );
    return $server_session;
};

sub admin_loged_in {
    my $self = shift;

    my $post_data = {
        login_id   => 'staff',
        password   => '12345678',
        csrf_token => $self->csrf_token,
    };

    $self->t->post_ok( $self->app->url_for('RN_admin_login'), form => $post_data );
    is $self->server_session->staff_id, 223, 'right staff loged in';
}

sub customer_loged_in {
    my $self = shift;

    my $post_data = {
        email      => 'c@example.org',
        password   => '12345678',
        csrf_token => $self->csrf_token,
    };

    $self->t->post_ok( $self->app->url_for('RN_customer_login'), form => $post_data );
    is $self->server_session->customer_id, 111, 'right customer loged in';
}

sub make_path {
    my ( $self, $route, $args ) = @_;
    return $route->is_endpoint ? $route->render($args) : $self->make_path( $route->children );
}

sub make_paths {
    my ( $self, $routes, $args ) = @_;

    my @paths;
    foreach my $r ( @{$routes} ) {
        if ( $r->is_endpoint ) { push @paths, $r->render($args) }
        else                   { $self->make_paths( $r->children ) }
    }
    return \@paths;
}

sub startup : Test(startup) {
    my $self = shift;

    my $t = Test::Mojo->new('App');
    $self->{t}   = $t;
    $self->{app} = $t->app;
    $self->{ua}  = $t->ua;
    $self->{tx}  = $t->tx;

    $t->ua->get('/');

    # CSRF token
    $self->{csrf_token} = t::Util::get_csrf_token($t);

    # redirect
    $self->ua->max_redirects(1);
}

# sub _common_basic_test : Tests() {
#     my $self = shift;
#     isa_ok $self->t, 'Test::Mojo', 'right isa Test::Mojo';
#     ok $self->csrf_token, 'right csrf token';
# }

1;
