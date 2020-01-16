package Yetie::Schema::Result::TaxRule;
use Mojo::Base 'Yetie::Schema::Result';
use DBIx::Class::Candy -autotable => v1;

primary_column id => {
    data_type         => 'INT',
    is_auto_increment => 1,
};

column title => {
    data_type   => 'VARCHAR',
    size        => 64,
    is_nullable => 0,
};

column tax_rate => {
    data_type   => 'DECIMAL',
    size        => [ 6, 3 ],
    is_nullable => 0,
};

# Relation
has_many
  category_tax_rules => 'Yetie::Schema::Result::CategoryTaxRule',
  { 'foreign.tax_rule_id' => 'self.id' },
  { cascade_delete        => 0 };

has_many
  common_tax_rules => 'Yetie::Schema::Result::CommonTaxRule',
  { 'foreign.tax_rule_id' => 'self.id' },
  { cascade_delete        => 0 };

has_many
  sales_order_items => 'Yetie::Schema::Result::SalesOrderItem',
  { 'foreign.tax_rule_id' => 'self.id' },
  { cascade_delete        => 0 };

has_many
  shipments => 'Yetie::Schema::Result::SalesOrderShipment',
  { 'foreign.tax_rule_id' => 'self.id' },
  { cascade_delete        => 0 };

1;
