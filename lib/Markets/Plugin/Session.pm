package Markets::Plugin::Session;
use Mojo::Base 'Mojolicious::Plugin';
use Markets::Session;
use Markets::Plugin::Session::Store::Teng;

sub register {
    my ( $self, $app, $args ) = @_;
    $args ||= {};

    my $stash_key      = delete $args->{stash_key}      || 'markets.session';
    my $cart_stash_key = delete $args->{cart_stash_key} || 'markets.session.cart';
    my $init           = delete $args->{init};
    my $resultset      = $args->{resultset};
    my $session        = Markets::Session->new(
        %$args,
        store => Markets::Plugin::Session::Store::Teng->new(
            resultset => $resultset
        )
    );

    # Helpers
    $app->helper(
        markets_session => sub { shift->stash($stash_key) },
        markets_cart    => sub { shift->stash($cart_stash_key) },
    );

    # Hooks
    $app->hook(
        before_action => sub {
            my $c = shift;
            say "hook! before_action from plugin session";    # debug

            $session->tx( $c->tx );
            $init->( $c, $session ) if $init;
            $c->stash(
                $stash_key      => $session,
                $cart_stash_key => $session->cart,
            );
            say "   ... set stash: $stash_key => session object";      # debug
            say "   ... set stash: $cart_stash_key => cart object";    # debug

            # Create or Expires time for session
            $session->load;
            if ( $session->sid ) {
                say "   ... ented session expires time.";              # debug
                $session->extend_expires;
            }
            else {
                _create_session( $c, $session );
            }
            say "   ... sid: " . $session->sid;                        # debug

            # Cart
            say "  on Cart";                                           # debug
            $session->cart->load;
        }
    );

    $app->hook(
        after_action => sub {
            my $c = shift;
            say "hook! after_action from plugin session";              # debug
            say "   ... session flush";                                # debug
            $c->stash($stash_key)->flush;
        }
    );
}

sub _create_session {
    my ( $c, $session ) = @_;
    my $landing_page_on_cookie = $c->session('landing_page');

    # cookieに対応している場合のみセッション生成する
    # cookieが無いときはlanding pageのurlを保存
    if ($landing_page_on_cookie) {
        say "   ... created new session.";    # debug
        $session->data(
            is_loged_in  => 0,
            landing_page => $landing_page_on_cookie,
        );
        $session->create;
    }
    else {
        say "   ... created cookie landing_page.";    # debug
        my $landing_page = $c->req->url->to_string;
        $c->session( landing_page => $landing_page );
    }
}

1;
__END__

=head1 NAME

Markets::Plugin::Session - forked from Mojolicious::Plugin::Session

=head1 SYNOPSIS

    # Mojolicious::Lite
    plugin session =>
        {
            stash_key       => 'markets.session',
            cart_stash_key  => 'markets.session.cart',
            store           => 'dbi',
            expires_delta   => 5
        };

    # Mojolicious
    $self->plugin(
        session => {
            stash_key       => 'markets.session',
            cart_stash_key  => 'markets.session.cart',
            store           => 'dbi',
            expires_delta   => 5
        }
    );

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 C<stash_key>

    Markets::Session instance will be saved in stash using this key.

=head2 C<cart_stash_key>

    Markets::Session::Cart instance will be saved in stash using this key.

=head1 SEE ALSO

L<Markets::Session>

L<Markets::Session::Cart>

L<Mojolicious::Plugin::Session>

L<MojoX::Session>

L<Mojolicious>

=cut
