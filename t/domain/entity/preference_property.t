use Mojo::Base -strict;
use Test::More;

use_ok 'Yetie::Domain::Entity::PreferenceProperty';

my $data = {
    id            => 1,
    name          => 'pref1',
    value         => '',
    default_value => '11',
    title         => 'pref title',
    summary       => 'pref summary',
    position      => 500,
    group_id      => 1,
};

subtest 'default attributes' => sub {
    my $o = Yetie::Domain::Entity::PreferenceProperty->new($data);

    isa_ok $o, 'Yetie::Domain::Entity', 'right customer';

    can_ok $o, 'name';
    can_ok $o, 'value';
    can_ok $o, 'default_value';
    can_ok $o, 'title';
    can_ok $o, 'summary';
    can_ok $o, 'position';
    can_ok $o, 'group_id';
};

done_testing();
