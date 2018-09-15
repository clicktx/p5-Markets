use Mojo::Base -strict;
use Test::More;
use Yetie::Domain::Factory;

my $pkg = 'Yetie::Domain::List::Shipments';
use_ok $pkg;

my $construct = sub {
    Yetie::Domain::Factory->new('list-shipments')->construct(@_);
};

subtest 'basic' => sub {
    my $v = $construct->();
    isa_ok $v, 'Yetie::Domain::List';
};

subtest 'total_quantity' => sub {
    my $v = $construct->( { list => [ { items => [ { quantity => 1 }, { quantity => 2 } ] } ] } );
    is $v->total_quantity, 3, 'right total quantity';
};

done_testing();
