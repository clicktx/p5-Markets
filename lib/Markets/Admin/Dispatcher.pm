package Markets::Admin::Dispatcher;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
    my ( $self, $app ) = @_;
    my $r = $app->routes->any( $app->ADMIN_PAGE_PREFIX )
      ->to( namespace => 'Markets::Admin::Controller' );

    # Admin route to controller
    $r->get('/')->to('index#welcome');
}

1;
