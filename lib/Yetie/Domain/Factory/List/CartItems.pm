package Yetie::Domain::Factory::List::CartItems;
use Mojo::Base 'Yetie::Domain::Factory';

sub cook {
    my $self = shift;

    # my $list = $self->param('list');
    # my $new = $list->map( sub { $self->factory('entity-cart-item')->construct($_) } );
    # $self->param( list => $new );

    # Aggregate items
    $self->aggregate_collection( 'list', 'entity-cart-item', $self->param('list') );
}

1;
__END__

=head1 NAME

Yetie::Domain::Factory::List::CartItems

=head1 SYNOPSIS

    my $entity = Yetie::Domain::Factory::List::CartItems->new()->construct();

    # In controller
    my $entity = $c->factory('list-cart_items')->construct();

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Factory::List::CartItems> inherits all attributes from L<Yetie::Domain::Factory> and implements
the following new ones.

=head1 METHODS

L<Yetie::Domain::Factory::List::CartItems> inherits all methods from L<Yetie::Domain::Factory> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

 L<Yetie::Domain::Factory>
