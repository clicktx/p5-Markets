use Mojo::Base -strict;
use Test::More;
use Test::Deep;
use Test::Mojo;
use t::Util;
use Mojo::DOM;

use_ok 'Yetie::Form::FieldSet';

my $t = Test::Mojo->new('App');
my $c = $t->app->build_controller;

use_ok 'Yetie::Form::FieldSet::Test';
my $fs = Yetie::Form::FieldSet::Test->new( controller => $c );

subtest 'attributes' => sub {
    ok( $fs->can($_), "right $_" ) for qw(schema);
};

subtest 'c' => sub {
    ok $fs->can('c');
    isa_ok $fs->c( 1, 2, 3 ), 'Mojo::Collection';
};

subtest 'checks' => sub {
    is $fs->checks('hoge'), undef, 'right not exist field_key';
    cmp_deeply $fs->checks('email'), [ [ size => 2, 5 ], [ like => ignore() ] ], 'right get validations';
    cmp_deeply $fs->checks,
      {
        no_attrs              => [],
        email                 => [ [ size => 2, 5 ], [ like => ignore() ] ],
        name                  => [],
        nickname              => [],
        address               => [],
        'favorite_color[]'    => [],
        luky_number           => [],
        'order.{}.name'       => [],
        'item.[].id'          => [],
        'item.[].name'        => [],
        'billing.line1'       => [],
        'billing.line2'       => [],
        'burgers.[].name'     => [],
        'burgers.[].toppings' => [],
      },
      'right all field_key validations';
};

subtest 'export_field' => sub {
    is_deeply __PACKAGE__->schema, {}, 'right not exported';

    $fs->export_field('item.[].id');
    is_deeply __PACKAGE__->schema('item.[].id'),
      {
        type        => 'text',
        label       => 'Item ',
        required    => 1,
        filters     => [],
        validations => [],
      },
      'right export field';

    # Export all fields
    $fs->export_field();
    is_deeply \@{ __PACKAGE__->field_keys }, [
        qw(
          item.[].id no_attrs email name nickname address favorite_color[] luky_number order.{}.name item.[].name
          billing.line1 billing.line2 burgers.[].name burgers.[].toppings
          )
      ],
      'right exported all';

    # Module base import
    my %foo = Test::Form::FieldSet::Foo->field_info;
    is_deeply \%foo,
      {
        aa => {},
        bb => {},
        cc => {},
      },
      'right import all';
    my %bar = Test::Form::FieldSet::Bar->field_info;
    is_deeply \%bar, { bb => {} }, 'right import';
    my %baz = Test::Form::FieldSet::Buzz->field_info;
    is_deeply \%baz, {}, 'right not import';
    my %qux = Test::Form::FieldSet::Qux->field_info;
    is_deeply \%qux,
      {
        bb => {},
        ff => {},
      },
      'right import from inherit module';
};

subtest 'field' => sub {
    ok !$fs->{_field}->{email}, 'right not cached';

    my $f = $fs->field('email');
    ok $fs->{_field}->{email}, 'right cached';
    isa_ok $f, 'Yetie::Form::Field';
    is $f->_fieldset, 'Test', 'right field set name';
};

subtest 'fieldset' => sub {
    my $pkg = fieldset('search');
    is $pkg, 'Yetie::Form::FieldSet::Search', 'right fieldset';
    can_ok $pkg, 'new';
};

subtest 'field_info' => sub {
    my %info = Yetie::Form::FieldSet::Test->field_info('name');
    is_deeply \%info,
      {
        type     => 'text',
        required => 1
      },
      'right field info';
};

subtest 'extends' => sub {
    my %info = extends('test#name');
    is_deeply \%info,
      {
        type     => 'text',
        required => 1
      },
      'right field info';
};

subtest 'field_keys' => sub {
    my @field_keys = $fs->field_keys;
    is_deeply \@field_keys, [
        qw/
          no_attrs email name nickname address favorite_color[] luky_number order.{}.name item.[].id item.[].name
          billing.line1 billing.line2 burgers.[].name burgers.[].toppings
          /
      ],
      'right field_keys';
    my $field_keys = $fs->field_keys;
    is ref $field_keys, 'ARRAY', 'right scalar';
};

subtest 'filters' => sub {
    is $fs->filters('hoge'), undef, 'right not exist field_key';
    is ref $fs->filters('name'), 'ARRAY', 'right filters';
    cmp_deeply $fs->filters,
      {
        no_attrs              => [],
        email                 => [qw/trim/],
        name                  => [],
        nickname              => [],
        address               => [],
        'favorite_color[]'    => [],
        luky_number           => [],
        'order.{}.name'       => [],
        'item.[].id'          => [],
        'item.[].name'        => [qw/trim/],
        'billing.line1'       => [],
        'billing.line2'       => [],
        'burgers.[].name'     => [],
        'burgers.[].toppings' => [],
      },
      'right all filters';
};

subtest 'schema' => sub {
    my $schema = $fs->schema;
    is ref $schema, 'HASH';
    my $field_schema = $fs->schema('email');
    is ref $field_schema, 'HASH';
};

# This test should be done at the end!
subtest 'append/remove' => sub {
    $fs->append_field( aaa => ( type => 'text' ) );
    my @field_keys = $fs->field_keys;
    is_deeply \@field_keys, [
        qw/
          no_attrs email name nickname address favorite_color[] luky_number order.{}.name item.[].id item.[].name
          billing.line1 billing.line2 burgers.[].name burgers.[].toppings
          aaa
          /
      ],
      'right field_keys';

    # Hash refference
    $fs->append_field( bbb => { type => 'choice' } );
    @field_keys = $fs->field_keys;
    is_deeply \@field_keys, [
        qw/
          no_attrs email name nickname address favorite_color[] luky_number order.{}.name item.[].id item.[].name
          billing.line1 billing.line2 burgers.[].name burgers.[].toppings
          aaa bbb
          /
      ],
      'right field_keys';
    is_deeply $fs->schema('bbb'), { type => 'choice' }, 'right schema';

    $fs->remove('name');
    @field_keys = $fs->field_keys;
    is_deeply \@field_keys, [
        qw/
          no_attrs email nickname address favorite_color[] luky_number order.{}.name item.[].id item.[].name
          billing.line1 billing.line2 burgers.[].name burgers.[].toppings
          aaa bbb
          /
      ],
      'right field_keys';
};

subtest 'replace_key' => sub {
    is $fs->replace_key('foo.0'),     'foo.[]',     'right replace';
    is $fs->replace_key('foo[]'),     'foo[]',      'right not replace';
    is $fs->replace_key('foo0'),      'foo0',       'right not replace';
    is $fs->replace_key('foo.0.bar'), 'foo.[].bar', 'right replace';

    is $fs->replace_key('foo.{bar}'),     'foo.{}',     'right replace';
    is $fs->replace_key('foo.{bar}.baz'), 'foo.{}.baz', 'right replace';
    is $fs->replace_key('foo{bar}'),      'foo{bar}',   'right not replace';
    is $fs->replace_key('foo{}'),         'foo{}',      'right not replace';
};

done_testing();

package Test::Form::FieldSet::Foo;
use Test::Form::FieldSet::Base -all;
1;

package Test::Form::FieldSet::Bar;
use Test::Form::FieldSet::Base qw(bb);
1;

package Test::Form::FieldSet::Buzz;
use Test::Form::FieldSet::Base;
1;

package Test::Form::FieldSet::Qux;
use Test::Form::FieldSet::Common qw(bb ff);
1;
