package Markets::DB2::Schema::Result::Addon;
use strict;
use warnings;

use DBIx::Class::Candy -autotable => v1;

primary_column id => { data_type => 'INT', };

unique_column name => {
    data_type => 'VARCHAR',
    size      => 50,
};

column is_enabled => {
    data_type     => 'TINYINT',
    size          => 1,
    is_nullable   => 1,
    default_value => 0,
};

has_many hooks => 'Markets::DB2::Schema::Result::Addon::Hook', 'addon_id';

1;
