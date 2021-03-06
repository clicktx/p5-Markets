package Yetie::Domain::Entity::Category;
use Moose;
use namespace::autoclean;
extends 'Yetie::Domain::Entity';

with 'Yetie::Domain::Role::Category';

has products => ( is => 'ro', default => sub { __PACKAGE__->factory('list-products')->construct() } );

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Yetie::Domain::Entity::Category

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Domain::Entity::Category> inherits all attributes from L<Yetie::Domain::Entity> and L<Yetie::Domain::Role::Category>.

implements the following new ones.

=head2 C<products>

Return L<Yetie::Schema::ResultSet::Product> object or C<undefined>.

=head1 METHODS

L<Yetie::Domain::Entity::Category> inherits all methods from L<Yetie::Domain::Entity> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Role::Category>, L<Yetie::Domain::Entity>
