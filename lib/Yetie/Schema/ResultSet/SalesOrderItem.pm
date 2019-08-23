package Yetie::Schema::ResultSet::SalesOrderItem;
use Mojo::Base 'Yetie::Schema::ResultSet';

sub store_items {
    my ( $self, $order ) = @_;

    my $order_id = $order->id;
    my $items    = $order->items;
    $items->each(
        sub {
            my $item = shift;
            my $data = _to_data( $order_id, $item );
            $self->update_or_create($data);
        }
    );
    return $self;
}

sub _to_data {
    my ( $order_id, $item ) = @_;

    my $item_data = $item->to_data;
    my $tax_rule  = delete $item_data->{tax_rule};
    my $price     = delete $item_data->{price};

    my %data = (
        order_id    => $order_id,
        price       => $price->{value},
        tax_rule_id => $tax_rule->{id},
        %{$item_data},
    );
    return \%data;
}

1;
__END__
=encoding utf8

=head1 NAME

Yetie::Schema::ResultSet::SalesOrderItem

=head1 SYNOPSIS

    my $result = $schema->resultset('SalesOrderItem')->method();

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Schema::ResultSet::SalesOrderItem> inherits all attributes from L<Yetie::Schema::ResultSet> and implements
the following new ones.

=head1 METHODS

L<Yetie::Schema::ResultSet::SalesOrderItem> inherits all methods from L<Yetie::Schema::ResultSet> and implements
the following new ones.

=head2 C<store_items>

Create or update items.

    $rs->store_items( $order );

Argument: L<Yetie::Domain::Entity::OrderDetail> object.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Schema::ResultSet>, L<Yetie::Schema>
