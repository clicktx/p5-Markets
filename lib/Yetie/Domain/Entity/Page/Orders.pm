package Yetie::Domain::Entity::Page::Orders;
use Yetie::Domain::Base 'Yetie::Domain::Entity::Page';

has order_list => sub { Yetie::Domain::Collection->new };

1;
__END__

=head1 NAME

Yetie::Domain::Entity::Page::Orders

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Entity::Page::Orders> inherits all attributes from L<Yetie::Domain::Entity::Page> and implements
the following new ones.

=head2 C<order_list>

    my $collection = $entity->order_list;

Return L<Yetie::Domain::Collection> object.

=head1 METHODS

L<Yetie::Domain::Entity::Page::Orders> inherits all methods from L<Yetie::Domain::Entity::Page> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Entity::Page>, L<Yetie::Domain::Entity>