package Yetie::Schema::Result::Address;
use Mojo::Base 'Yetie::Schema::Base::Result';
use DBIx::Class::Candy -autotable => v1;

primary_column id => {
    data_type         => 'INT',
    is_auto_increment => 1,
};

column line1 => {
    data_type   => 'VARCHAR',
    size        => 255,
    is_nullable => 0,
};

column line2 => {
    data_type   => 'VARCHAR',
    size        => 255,
    is_nullable => 0,
};

column level1 => {
    data_type   => 'VARCHAR',
    size        => 255,
    is_nullable => 0,
    comments    => 'State/Province/Province/Region',
};

column level2 => {
    data_type   => 'VARCHAR',
    size        => 255,
    is_nullable => 0,
    comments    => 'City/Town',
};

column postal_code => {
    data_type   => 'VARCHAR',
    size        => 255,
    is_nullable => 0,
    comments    => 'Post Code/Zip Code',
};

has_many
  customer_addresses => 'Yetie::Schema::Result::Customer::Address',
  { 'foreign.address_id' => 'self.id' },
  { cascade_delete       => 0 };

has_many
  sales => 'Yetie::Schema::Result::Sales',
  { 'foreign.address_id' => 'self.id' },
  { cascade_delete       => 0 };

has_many
  orders => 'Yetie::Schema::Result::Sales::Order',
  { 'foreign.address_id' => 'self.id' },
  { cascade_delete       => 0 };

1;
