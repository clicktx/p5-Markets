package Markets::Session;
use Mojo::Base 'Mojolicious::Plugin';
use MojoX::Session;

sub register {
    my ( $self, $app, $args ) = @_;

    $args ||= {};

    my $stash_key = delete $args->{stash_key} || 'mojox-session';
    my $init = delete $args->{init};

    $app->hook(
        around_action => sub {
            my ( $next, $c, $action, $last ) = @_;
            my $session = MojoX::Session->new(%$args);

            $session->tx( $c->tx );
            $init->( $c, $session ) if $init;
            $c->stash( $stash_key => $session );

            $session->load;
            if ( $session->sid ) {
                say "ented session expires time."; 
                $session->extend_expires;
            }
            else {
                say "created new session."; 
                $session->create;
            }
            say $session->sid; 

            $next->();

            $c->stash($stash_key)->flush;
        }
    );

}

1;
__END__

=head1 NAME

Markets::Session - forked from Mojolicious::Plugin::Session

=head1 SYNOPSIS

    # Mojolicious::Lite
    plugin session =>
      {stash_key => 'mojox-session', store => 'dbi', expires_delta => 5};

    # Mojolicious
    $self->plugin(
        session => {
            stash_key     => 'mojox-session',
            store         => 'dbi',
            expires_delta => 5
        }
    );

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 C<stash_key>

    MojoX::Session instance will be saved in stash using this key.

=head1 SEE ALSO

L<Mojolicious::Plugin::Session>

L<MojoX::Session>

L<Mojolicious>

=cut



1;