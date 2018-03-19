package Yetie::Schema::Result::Address::Type;
use Mojo::Base 'Yetie::Schema::Base::Result';
use DBIx::Class::Candy -autotable => v1;

primary_column id => {
    data_type         => 'INT',
    is_auto_increment => 1,
};

column name => {
    data_type   => 'VARCHAR',
    size        => 50,
    is_nullable => 0,
};

has_many
  customer_addresses => 'Yetie::Schema::Result::Customer::Address',
  { 'foreign.address_type_id' => 'self.id' },
  { cascade_delete            => 0 };

1;