use Mojo::Base -strict;
use Test::More;
use Test::Deep;
use Yetie::Factory;

my $pkg = 'Yetie::Domain::List::CartItems';
use_ok $pkg;

my $construct = sub { Yetie::Factory->new('list-cart_items')->construct(@_) };

subtest 'basic' => sub {
    my $list = $construct->();
    isa_ok $list, 'Yetie::Domain::List';
};

subtest 'append' => sub {
    my $f = Yetie::Factory->new('entity-cart_item');
    my $data = [ { product_id => 1, quantity => 1 }, { product_id => 2, quantity => 2 } ];
    my ( $list, $item );

    # Append single
    $list = $construct->( list => $data );
    $item = $f->construct( { product_id => 3, quantity => 3 } );
    $list->append($item);
    cmp_deeply $list->to_data,
      [ { product_id => 1, quantity => 1 }, { product_id => 2, quantity => 2 }, { product_id => 3, quantity => 3 } ],
      'right single append';
    is $list->is_modified, 1, 'right modified';

    # Append same item
    $list = $construct->( list => $data );
    $item = $f->construct( { product_id => 2, quantity => 2 } );
    $list->append($item);
    cmp_deeply $list->to_data,
      [ { product_id => 1, quantity => 1 }, { product_id => 2, quantity => 4 } ],
      'right sum quantity';
    is $list->is_modified, 1, 'right modified';

    # Append multi
    $list = $construct->( list => $data );
    $item = $f->construct( { product_id => 1, quantity => 1 } );
    my $item2 = $f->construct( { product_id => 2, quantity => 2 } );
    my $item3 = $f->construct( { product_id => 3, quantity => 3 } );
    $list->append( $item, $item2, $item3 );
    cmp_deeply $list->to_data,
      [ { product_id => 1, quantity => 2 }, { product_id => 2, quantity => 4 }, { product_id => 3, quantity => 3 } ],
      'right multi append';
    is $list->is_modified, 1, 'right modified';
};

subtest 'total_quantity' => sub {
    my $list = $construct->( list => [ { quantity => 1 }, { quantity => 2 } ] );
    is $list->total_quantity, 3, 'right total quantity';
};

subtest 'remove' => sub {
    my $data = [ { product_id => 1 }, { product_id => 2 }, { product_id => 3 } ];
    my $list = $construct->( list => $data );
    my $hash = $list->get(1)->hash;
    $list->remove($hash);
    cmp_deeply $list->to_data, [ { product_id => 1 }, { product_id => 3 } ], 'right remove item';
    is $list->is_modified, 1, 'right modified';

    # Unremove. not found item.
    $list = $construct->( list => $data );
    $list->remove('foo');
    cmp_deeply $list->to_data,
      [ { product_id => 1 }, { product_id => 2 }, { product_id => 3 } ],
      'right not remove item';
    is $list->is_modified, 0, 'right not modified';
};

subtest 'subtotal' => sub {
    my $data = [ { quantity => 1, price => 1 }, { quantity => 2, price => 2 }, { quantity => 3, price => 3 } ];
    my $list = $construct->( list => $data );
    is $list->subtotal, 14, 'right subtotal';
};

done_testing();