package Yetie::Controller::Catalog::Login;
use Mojo::Base 'Yetie::Controller::Catalog';

sub index {
    my $c = shift;

    $c->continue_url( $c->continue_url );
    return $c->redirect_to( $c->continue_url ) if $c->is_logged_in;

    # Link login
    return $c->redirect_to('rn.dropin') if !$c->cookie('login_with_password');

    # Initialize form
    my $form = $c->form('auth-login');
    $form->field('remember_me')->checked( $c->cookie('remember_me') );

    # Get request
    return $c->render() if $c->is_get_request;

    # Validation form
    return $c->render() if !$form->do_validate;

    my $remember_me = $form->param('remember_me') ? 1 : 0;
    $c->cookie(
        remember_me => $remember_me,
        { expires => time + $c->pref('cookie_expires_long') }
    );

    my $customer_id = $c->service('customer')->login_process_with_password($form);
    return $c->render( login_failure => 1 ) if !$customer_id;

    # Login success
    if ($remember_me) { $c->service('authentication')->remember_token( $form->param('email') ) }
    return $c->redirect_to( $c->continue_url );
}

sub remember_me {
    my $c            = shift;
    my $continue_url = $c->continue_url;

    my $token = $c->cookie('remember_token');
    return $c->redirect_to($continue_url) if !$token;

    # Login
    $c->service('customer')->login_process_remember_me($token);
    return $c->redirect_to($continue_url);
}

sub toggle {
    my $c = shift;
    $c->continue_url( $c->continue_url );

    my $value = $c->cookie('login_with_password') ? 0 : 1;
    $c->cookie( login_with_password => $value, { expires => time + $c->pref('cookie_expires_long') } );
    return $c->redirect_to('rn.login');
}

sub with_password {
    my $c = shift;
    $c->continue_url( $c->continue_url );

    # Set a cookie
    $c->cookie( login_with_password => 1, { expires => time + $c->pref('cookie_expires_long') } );
    return $c->redirect_to('rn.login');
}

1;
