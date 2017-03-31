package Markets::Domain::Collection;
use Mojo::Base 'Mojo::Collection';
use Carp qw/croak/;

# NOTE: 同じcollectionに同一のidを持つ要素は存在しないはずなのでsearchメソッドは不要？
sub find {
    my ( $self, $str ) = @_;
    $self->first( sub { $_->id eq $str } ) or undef;
}

sub new {
    my $class = shift;
    if (@_) { croak 'Arguments not Entity Object.' if ( ref $_[0] ) !~ /Entity/ }
    return bless [@_], ref $class || $class;
}

1;
__END__

=head1 NAME

Markets::Domain::Collection

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Markets::Domain::Collection> inherits all attributes from L<Mojo::Collection> and implements
the following new ones.

=head1 METHODS

=head2 C<find>

    my $entity = $collection->find($entity_id);

Return L<Markets::Domain::Entity> object or undef.

=head1 AUTHOR

Markets authors.

=head1 SEE ALSO

 L<Mojo::Collection>
