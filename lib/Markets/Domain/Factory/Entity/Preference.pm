package Markets::Domain::Factory::Entity::Preference;
use Mojo::Base 'Markets::Domain::Factory';

sub cook {
    my $self = shift;

    # Aggregate properties
    $self->aggregate_kvlist( properties => 'entity-preference-property', $self->param('properties') || [] );
}

1;
__END__

=head1 NAME

Markets::Domain::Factory::Entity::Preference

=head1 SYNOPSIS

    my $entity = Markets::Domain::Factory::Entity::Preference->new( %args )->create;

    # In controller
    my $entity = $c->factory('entity-prefence')->create(%args);

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Markets::Domain::Factory::Entity::Preference> inherits all attributes from L<Markets::Domain::Factory> and implements
the following new ones.

=head1 METHODS

L<Markets::Domain::Factory::Entity::Preference> inherits all methods from L<Markets::Domain::Factory> and implements
the following new ones.

=head1 AUTHOR

Markets authors.

=head1 SEE ALSO

 L<Markets::Domain::Factory>
