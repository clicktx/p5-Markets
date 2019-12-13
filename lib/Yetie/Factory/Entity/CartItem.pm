package Yetie::Factory::Entity::CartItem;
use Mojo::Base 'Yetie::Factory';

sub cook {
    my $self = shift;

    # price
    $self->aggregate( price => 'value-price', $self->{price} );

    # tax rule
    $self->aggregate( tax_rule => 'entity-tax_rule', $self->param('tax_rule') || {} );
}

1;
__END__

=head1 NAME

Yetie::Factory::Entity::CartItem

=head1 SYNOPSIS

    my $entity = Yetie::Factory::Entity::CartItem->new( %args )->construct();

    # In controller
    my $entity = $c->factory('entity-cart_item')->construct(%args);

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Factory::Entity::CartItem> inherits all attributes from L<Yetie::Factory> and implements
the following new ones.

=head1 METHODS

L<Yetie::Factory::Entity::CartItem> inherits all methods from L<Yetie::Factory> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Factory>
