package Yetie::Schema::Result::SalesOrder;
use Mojo::Base 'Yetie::Schema::Result';
use DBIx::Class::Candy -autotable => v1;

use Yetie::Schema::Result::Sales;
use Yetie::Schema::Result::Address;

primary_column id => {
    data_type         => 'INT',
    is_auto_increment => 1,
};

column sales_id => {
    data_type   => Yetie::Schema::Result::Sales->column_info('id')->{data_type},
    is_nullable => 0,
};

column shipping_address_id => {
    data_type   => Yetie::Schema::Result::Address->column_info('id')->{data_type},
    is_nullable => 0,
};

column trashed_at => {
    data_type   => 'DATETIME',
    is_nullable => 1,
    timezone    => Yetie::Schema->TZ,
};

# Relation
belongs_to
  sales => 'Yetie::Schema::Result::Sales',
  { 'foreign.id' => 'self.sales_id' };

belongs_to
  shipping_address => 'Yetie::Schema::Result::Address',
  { 'foreign.id' => 'self.shipping_address_id' };

has_many
  items => 'Yetie::Schema::Result::SalesOrderItem',
  { 'foreign.order_id' => 'self.id' },
  { cascade_delete     => 0 };

has_many
  shipments => 'Yetie::Schema::Result::Shipment',
  { 'foreign.order_id' => 'self.id' },
  { cascade_delete     => 0 };

sub to_data {
    my $self = shift;
    return {
        id               => $self->id,
        purchased_on     => $self->sales->created_at,
        billing_address  => $self->sales->billing_address->to_data,
        shipping_address => $self->shipping_address->to_data,
        items            => $self->items->to_data,
        order_status     => '',
    };
}

1;
