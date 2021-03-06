use Mojo::Base -strict;
use Test::More;
use Test::Deep;
use Yetie::Factory;

use_ok 'Yetie::Domain::Entity::CategoryTreeNode';

subtest 'basic' => sub {
    my $e = Yetie::Domain::Entity::CategoryTreeNode->new();
    isa_ok $e, 'Yetie::Domain::Entity';

    can_ok $e, 'level';
    can_ok $e, 'root_id';
    can_ok $e, 'title';

    can_ok $e, 'ancestors';
    can_ok $e, 'children';
    isa_ok $e->ancestors, 'Yetie::Domain::List::CategoryTrees';
    isa_ok $e->children,  'Yetie::Domain::List::CategoryTrees';
};

subtest 'has_child' => sub {
    my $f = Yetie::Factory->new('entity-category_tree_node');
    my $e = $f->construct( ancestors => [ {} ], children => [ {} ] );
    is $e->has_child, 1, 'right has child';
    $e = $f->construct( ancestors => [], children => [] );
    is $e->has_child, 0, 'right has not child';
};

done_testing();
