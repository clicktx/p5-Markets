package Yetie::Schema::Result::AddonTrigger;
use Mojo::Base 'Yetie::Schema::Result';
use DBIx::Class::Candy -autotable => v1;

primary_column id => { data_type => 'INT', };

column addon_id => {
    data_type   => 'INT',
    is_nullable => 1,
};

column trigger_name => {
    data_type   => 'VARCHAR',
    size        => 64,
    is_nullable => 1,
};

column priority => {
    data_type     => 'INT',
    is_nullable   => 1,
    default_value => 100,
};

belongs_to
  staff => 'Yetie::Schema::Result::Addon',
  { 'foreign.id' => 'self.addon_id' };

1;