package Yetie::Schema::ResultSet::Sales::Order;
use Mojo::Base 'Yetie::Schema::Base::ResultSet';

sub find_by_id {
    my ( $self, $shipment_id ) = @_;

    return $self->find(
        $shipment_id,
        {
            prefetch => [
                'shipping_address',
                'items',
                {
                    sales => [ 'customer', 'billing_address' ],
                },
            ],
        },
    );
}

sub search_sales_orders {
    my ( $self, $args ) = @_;

    my $where = $args->{where} || {};
    my $order_by = $args->{order_by} || { -desc => 'me.id' };
    my $page_no = $args->{page_no};
    my $rows    = $args->{rows};

    return $self->search(
        $where,
        {
            page     => $page_no,
            rows     => $rows,
            order_by => $order_by,
            prefetch => [ 'shipping_address', 'items', { sales => [ 'customer', 'billing_address' ] }, ],
        }
    );
}

sub to_data {
    my $self = shift;

    my @order_list;
    $self->each(
        sub {
            my $order = _mapping(shift);
            push @order_list, $order;
        }
    );
    return \@order_list;
}

sub _mapping {
    my $row = shift;
    return {
        id               => $row->id,
        purchased_on     => $row->sales->created_at,
        billing_address  => $row->sales->billing_address->to_data,
        shipping_address => $row->shipping_address->to_data,
        items            => $row->items->to_data,
        order_status => '',
    };
}

1;
__END__
=encoding utf8

=head1 NAME

Yetie::Schema::ResultSet::Sales::Order

=head1 SYNOPSIS

    my $data = $schema->resultset('Sales::Order')->method();

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Schema::ResultSet::Sales::Order> inherits all attributes from L<Yetie::Schema::Base::ResultSet> and implements
the following new ones.

=head1 METHODS

L<Yetie::Schema::ResultSet::Sales::Order> inherits all methods from L<Yetie::Schema::Base::ResultSet> and implements
the following new ones.

=head2 C<find_by_id>

    my $shipment = $rs->find_by_id($shipment_id);

=head2 C<search_sales_orders>

    my $orders = $rs->search_sales_orders( \%args);

    my $orders = $rs->search_sales_orders(
        {
            where => { ... },
            order_by => { ... },
            page_no => 5,
            $rows => 20,
        }
    );

=head2 C<to_data>

    my $data = $rs->to_data;

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Schema::Base::ResultSet>, L<Yetie::Schema>
