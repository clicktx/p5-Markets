use Mojo::Base -strict;

use t::Util;
use Test::More;
use Test::Mojo;

my $t   = Test::Mojo->new('App');
my $app = $t->app;
use_ok 'Markets::Service::Address';

subtest 'basic' => sub {
    my $c       = $app->build_controller;
    my $service = $c->service('address');

    can_ok $service, 'create_entity';
};

done_testing();

__END__
