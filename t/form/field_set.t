use Mojo::Base -strict;
use Test::More;
use Test::Deep;
use Test::Mojo;
use t::Util;

use_ok 'Markets::Form::FieldSet';

my $t = Test::Mojo->new('App');
my $c = $t->app->build_controller;

use Markets::Form::Type::Test;
my $fs = Markets::Form::Type::Test->new( controller => $c );

subtest 'attributes' => sub {
    ok( $fs->can($_), "right $_" ) for qw(controller params field_list);
};

subtest 'c' => sub {
    ok $fs->can('c');
    isa_ok $fs->c( 1, 2, 3 ), 'Mojo::Collection';
};

subtest 'field' => sub {
    my $f = $fs->field('email');
    isa_ok $f, 'Markets::Form::Field';
};

subtest 'field_keys' => sub {
    my @field_keys = $fs->field_keys;
    is_deeply \@field_keys, [qw/email name address item.[].id item.[].name/], 'right field_keys';
    my $field_keys = $fs->field_keys;
    is ref $field_keys, 'ARRAY', 'right scalar';
};

subtest 'params' => sub {
    isa_ok $fs->params, 'Mojo::Parameters';
    $fs->params->append( email => 'a@b.com' );

    is $fs->params->param('email'), 'a@b.com', 'right get param';
    is $fs->params->param('a'),     undef,     'right empty param';
};

subtest 'render tags' => sub {
    is ref $fs->render('email'),       'CODE', 'right render method';
    is ref $fs->render_label('email'), 'CODE', 'right render_label method';
};

subtest 'checks' => sub {
    is $fs->checks('hoge'), undef, 'right not exist field_key';
    cmp_deeply $fs->checks('email'), [ { size => ignore() }, { like => ignore() } ], 'right get validations';
    cmp_deeply $fs->checks,
      {
        email          => [ { size => ignore() }, { like => ignore() } ],
        name           => [],
        address        => [],
        'item.[].id'   => [],
        'item.[].name' => [],
      },
      'right all field_key validations';
};

subtest 'filters' => sub {
    is $fs->filters('hoge'), undef, 'right not exist field_key';
    is ref $fs->filters('name'), 'ARRAY', 'right filters';
    cmp_deeply $fs->filters,
      {
        email          => [],
        name           => [],
        address        => [],
        'item.[].id'   => [],
        'item.[].name' => [qw/trim/],
      },
      'right all filters';
};

subtest 'validate' => sub {

    # Set form parameters
    $fs->params->pairs(
        [
            email         => 'a@b33',
            name          => '',
            address       => 'ny',
            'item.0.id'   => 11,
            'item.1.id'   => '',
            'item.2.id'   => 33,
            'item.0.name' => '',
            'item.1.name' => '',
            'item.2.name' => '',
        ]
    );
    my $result = $fs->validate;
    ok !$result, 'right failed validation';

    my $v = $fs->controller->validation;
    my ( $check, $res, @args ) = @{ $v->error('email') };
    is $check, 'like', 'right validation error';
    is_deeply $v->error('name'),      ['required'], 'right required';
    is_deeply $v->error('item.1.id'), ['required'], 'right required';

    # Create new request
    $c = $t->app->build_controller;
    $fs = Markets::Form::Type::Test->new( controller => $c );
    $fs->params->pairs(
        [
            email         => 'a@b.c',
            name          => 'frank',
            address       => 'ny',
            'item.0.id'   => 11,
            'item.1.id'   => 22,
            'item.2.id'   => 33,
            'item.0.name' => '',
            'item.1.name' => '',
            'item.2.name' => '',
        ]
    );
    $result = $fs->validate;
    ok $result, 'right validation';
};

subtest 'validate with filter' => sub {

    # Create new request
    $c = $t->app->build_controller;
    $fs = Markets::Form::Type::Test->new( controller => $c );
    $fs->params->pairs(
        [
            'item.0.name' => ' aaa ',
            'item.1.name' => ' bbb ',
            'item.2.name' => ' ccc ',
        ]
    );
    $fs->validate;
    my $v = $c->validation;
    is $v->param('item.0.name'), 'aaa';
    is $v->param('item.1.name'), 'bbb';
    is $v->param('item.2.name'), 'ccc';
};

# This test should be done at the end!
subtest 'append/remove' => sub {
    $fs->append( aaa => ( type => 'text' ) );
    my @field_keys = $fs->field_keys;
    is_deeply \@field_keys, [qw/email name address item.[].id item.[].name aaa/], 'right field_keys';

    $fs->remove('name');
    @field_keys = $fs->field_keys;
    is_deeply \@field_keys, [qw/email address item.[].id item.[].name aaa/], 'right field_keys';
};

done_testing();
