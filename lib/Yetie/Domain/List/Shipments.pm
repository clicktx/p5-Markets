package Yetie::Domain::List::Shipments;
use Yetie::Domain::Base 'Yetie::Domain::List';

sub clear_items {
    shift->each( sub { $_->items->clear } );
}

sub has_shipment { shift->size ? 1 : 0 }

sub total_item_size {
    shift->list->map( sub { $_->items->each } )->size;
}

sub total_quantity {
    shift->list->reduce( sub { $a + $b->items->total_quantity }, 0 );
}

sub revert {
    my $self = shift;

    my $shipment_first = $self->first;
    $shipment_first->items->clear;

    my $shipments = $self->list->new($shipment_first);
    $self->list($shipments);
}

sub subtotal {
    shift->list->reduce( sub { $a + $b->items->subtotal }, 0 );
}

1;
__END__

=head1 NAME

Yetie::Domain::List::Shipments

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::List::Shipments> inherits all attributes from L<Yetie::Domain::List> and implements
the following new ones.

=head1 METHODS

L<Yetie::Domain::List::Shipments> inherits all methods from L<Yetie::Domain::List> and implements
the following new ones.

=head2 C<clear_items>

    my $list->clear_items;

=head2 C<has_shipment>

    my $bool = $list->has_shipment;

Return boolean.

=head2 C<total_item_size>

    my $size = $list->total_item_size;

=head2 C<total_quantity>

    my $qty = $list->total_quantity;

=head2 C<revert>

    $list->revert;

Delete except the first element. Also delete all items of the first element.

=head2 C<subtotal>

    my $subtotal = $list->subtotal;

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Entity::Item>, L<Yetie::Domain::List>
