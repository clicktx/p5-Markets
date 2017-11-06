use Mojo::Base -strict;
use Test::More;
use Yetie::Domain::Factory;

my $test_data = {
    breadcrumb => [
        { title => 'Fashion', uri => '/fashion' },
        { title => 'Women', uri => '/women' },
    ],
};

sub _create_entity {
    Yetie::Domain::Factory->new('entity-content')->create($test_data);
}

use_ok 'Yetie::Domain::Entity::Content';

subtest 'basic' => sub {
    my $e = Yetie::Domain::Entity::Content->new();
    isa_ok $e, 'Yetie::Domain::Entity';

    can_ok $e, 'title';
    can_ok $e, 'description';
    can_ok $e, 'keywords';
    can_ok $e, 'robots';
    can_ok $e, 'breadcrumb';
    can_ok $e, 'pager';
    can_ok $e, 'params';
    is ref $e->params, 'HASH', 'right hash_ref';
};

subtest 'breadcrumb' => sub {
    my $e = _create_entity();

    my $attr = $e->breadcrumb;
    use DDP;p $attr;
    isa_ok $attr, 'Yetie::Domain::Collection';
    is @{$attr}, 2, 'right elements';
    isa_ok $attr->[0], 'Yetie::Domain::Entity::Breadcrumb';
};

subtest 'pager' => sub {
    my $e = _create_entity();

    my $attr = $e->pager;
    isa_ok $attr, 'Data::Page';
};

done_testing();