package t::service::email;

use Mojo::Base 't::common';
use t::Util;
use Test::More;
use Test::Mojo;

sub _init {
    my $self = shift;
    my $c    = $self->t->app->build_controller;
    return ( $c, $c->service('email') );
}

sub t00_startup : Tests(startup) { shift->app->routes->any('/:controller/:action')->to() }

sub t01_find_email : Tests() {
    my $self = shift;
    my ( $c, $s ) = $self->_init;

    my $e = $s->find_email('c@example.org');
    isa_ok $e, 'Yetie::Domain::Value::Email';
    ok $e->in_storage,  'right in storage';
    ok $e->is_verified, 'right verified';

    $e = $s->find_email('g@example.org');
    isa_ok $e, 'Yetie::Domain::Value::Email';
    ok $e->in_storage, 'right in storage';
    ok !$e->is_verified, 'right not verified';

    $e = $s->find_email('notstorage@foo.bar');
    isa_ok $e, 'Yetie::Domain::Value::Email';
    ok !$e->in_storage,  'right not in storage';
    ok !$e->is_verified, 'right not verified';
}

sub to_verified : Tests() {
    my $self = shift;
    my ( $c, $s ) = $self->_init;

    my $email_addr = 'to_verified_test@example.org';
    $c->schema->resultset('Email')->find_or_create( { address => $email_addr } );
    my $e = $s->find_email($email_addr);
    ok !$e->is_verified, 'right unverified';

    $e = $s->to_verified($email_addr);
    ok $e->is_verified, 'right verified';

    $e = $s->to_verified('');
    ok !$e->is_verified, 'right argument empty';
}

__PACKAGE__->runtests;
