package Markets::Domain::Entity::Cart;
use Mojo::Base 'Markets::Domain::Entity';

has [qw/ cart_id items shipments /];

has id => sub { $_[0]->hash_code( $_[0]->cart_id ) };

# has 'items';
# has item_count       => sub { shift->items->flatten->size };
# has original_total_price => 0;
# has total_price          => 0;
# has total_weight         => 0;

# cart.attributes
# cart.item_count
# cart.items
# cart.note
# cart.original_total_price
# cart.total_price
# cart.total_weight
use DDP;

sub to_hash {
    my $self = shift;
    my $hash = $self->SUPER::to_hash;

    # items
    my @items;
    $self->items->each( sub { push @items, $_->to_hash } );
    $hash->{items} = \@items;

    # shipments
    my @shipments;
    $self->shipments->each( sub { push @shipments, $_->to_hash } );
    $hash->{shipments} = \@shipments;

    delete $hash->{$_} for (qw/id cart_id/);
    return $hash;
}

sub total_item_count {
    my $self = shift;
    my $cnt  = 0;
    $self->items->each( sub     { $cnt += $_->quantity } );
    $self->shipments->each( sub { $cnt += $_->item_count } );
    return $cnt;
}

1;
__END__

=head1 NAME

Markets::Domain::Entity::Cart

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Markets::Domain::Entity::Cart> inherits all attributes from L<Markets::Domain::Entity> and implements
the following new ones.

=head1 METHODS

=head1 AUTHOR

Markets authors.

=head1 SEE ALSO

 L<Markets::Domain::Entity>
