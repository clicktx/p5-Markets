package Yetie::Domain::Entity;
use Yetie::Factory;
use Yetie::Domain::Collection qw();
use Yetie::Domain::IxHash qw();
use Mojo::Util qw();
use Scalar::Util qw();
use Data::Clone qw();
use Data::Dumper;

use Moose;
use namespace::autoclean;
extends 'Yetie::Domain::Base';

my @not_dump_attrs_defautls = (qw/created_at updated_at/);

has _hash_sum => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
    writer     => '_set_hash_sum',
);
sub _build__hash_sum { return shift->hash_code }

has id => ( is => 'rw' );

# Do not created an undefined attributes
around BUILDARGS => sub {
    ( shift, shift );    # $orig, $class
    my %args = @_ ? @_ > 1 ? @_ : %{ $_[0] } : ();

    foreach my $key ( keys %args ) {
        if ( !defined $args{$key} ) { delete $args{$key} }
    }
    return \%args;
};

sub BUILD {
    my $self = shift;

    # Lazy build
    $self->_hash_sum;
}

sub clone {
    my $self  = shift;
    my $clone = Data::Clone::data_clone($self);

    my @attributes = keys %{$self};
    foreach my $attr (@attributes) {
        next if !$self->can($attr);
        next if !Scalar::Util::blessed( $self->$attr );

        if ( $self->$attr->can('map') ) {
            $clone->$attr( $self->$attr->map( sub { $_->clone } ) );
        }
    }

    # Reset object hash_sum
    $clone->_set_hash_sum( $clone->hash_code );
    return $clone;
}

sub equals {
    my ( $self, $obj ) = @_;
    return $self->hash_code eq $obj->hash_code ? 1 : 0;
}

sub factory { return Yetie::Factory->new( $_[1] ) }

sub has_id { return shift->id ? 1 : 0 }

sub hash_code {
    my ( $self, $arg ) = @_;
    return Mojo::Util::sha1_sum($arg) if $arg;

    return Mojo::Util::sha1_sum( shift->_dump_public_attr );
}

sub is_empty { return shift->id ? 0 : 1 }

sub is_modified {
    my $self = shift;
    return $self->_hash_sum ne $self->hash_code ? 1 : 0;

    # return 1 if $self->_hash_sum ne $self->hash_code;

    # # Recursive call for attributes
    # return $self->_recursive_call( sub { return 1 if shift->is_modified } ) ? 1 : 0;
}

sub reset_modified { warn 'reset_modified() is deprecated' }

sub to_array {
    my $self = shift;
    my $hash = $self->to_hash;

    my @keys = sort keys %{$hash};
    my @values = map { $hash->{$_} } @keys;
    return [ \@keys, \@values ];
}

sub to_data {
    my $self = shift;
    my $hash = $self->to_hash;
    my %data;
    foreach my $key ( keys %{$hash} ) {
        my $value = $hash->{$key};
        if ( Scalar::Util::blessed $value) { $data{$key} = $value->to_data if $value->can('to_data') }
        else                               { $data{$key} = $value }
    }
    return \%data;
}

sub to_hash {
    my %hash = %{ +shift };

    # Remove needless data
    my @not_dump = ();
    push @not_dump, @not_dump_attrs_defautls, grep { /\A_.*/sxm } keys %hash;
    foreach (@not_dump) { delete $hash{$_} }
    return \%hash;
}

sub _dump_public_attr {
    local $Data::Dumper::Terse    = 1;
    local $Data::Dumper::Indent   = 0;
    local $Data::Dumper::Sortkeys = sub {
        my ($hash) = @_;
        my @keys = grep { /\A(?!_).*/sxm } ( sort keys %{$hash} );
        return \@keys;
    };
    return Dumper(shift);
}

# sub _recursive_call {
#     my ( $self, $cb ) = @_;
#     foreach my $attr ( keys %{$self} ) {
#         next if !$self->can($attr);
#         next if !Scalar::Util::blessed( $self->$attr );

#         if ( $self->$attr->isa('Yetie::Domain::Entity') ) {
#             $cb->( $self->$attr );
#         }
#         elsif ( $self->$attr->isa('Yetie::Domain::Collection') ) {
#             $self->$attr->each( sub { $cb->($_) } );
#         }
#         elsif ( $self->$attr->isa('Yetie::Domain::IxHash') ) {
#             $self->$attr->each( sub { $cb->($b) } );
#         }
#     }
# }

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=encoding utf8

=head1 NAME

Yetie::Domain::Entity - Entity Object Base Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 C<collection>

    my $collection = collection( 'foo', 'bar', 'baz' );

Construct a new index-hash-based L<Yetie::Domain::Collection> object.

=head2 C<ixhash>

    my $ixhash = ixhash( foo => 1, bar => 2, baz => 3 );

Construct a new index-hash-based L<Yetie::Domain::IxHash> object.

=head1 ATTRIBUTES

L<Yetie::Domain::Entity> inherits all attributes from L<Yetie::Domain::Base> and implements
the following new ones.

=head1 METHODS

L<Yetie::Domain::Entity> inherits all methods from L<Yetie::Domain::Base> and implements
the following new ones.

=head2 C<clone>

    my $clone = $self->clone;

Return object.

=head2 C<equals>

    my $bool = $entity->equals($other_entity);

Return boolean value.

=head2 C<factory>

    __PACKAGE__->factory('entity-foo');

Return Yetie::Factory object.

=head2 C<has_id>

    my $bool = $entity->has_id;

Return boolean value.

=head2 C<hash_code>

    my $sha1_sum = $entity->hash_code;
    my $sha1_sum = $entity->hash_code($bytes);

Return SHA1 checksum. Default bytes is L<Yetie::Domain::Entity/id>.

=head2 C<id>

    my $entity_id = $entity->id;

=head2 C<is_empty>

    my $bool = $entity->is_empty;

Return boolean value.

=head2 C<is_modified>

    # Getter
    my $bool = $entity->is_modified;
    say 'Entity is modified!' if $bool;

    # Setter
    $entity->is_modified($bool);

Return boolean value.

=head2 C<reset_modified>

    $entity->reset_modified;

Reset modified flag.
Recursively reset all entities to keep.

=head2 C<to_array>

    my $array = $entity->to_array;

    # eg.
    my $e = Yetie::Domain::Entity->new({ id => 11, b => 5, a => 3, z => 15 });
    my $array = $e->to_array;

    # Return value
    print Dumper $array;
    $VAR1 = [
        [ 'a', 'b', 'z' ],
        [ 3, 5, 15 ]
    ];

Return Array reference.

Note: All private attributes (e.g. "_xxx") and "id", "created_at", "updated_at" are removed.

=head2 C<to_data>

    my $data = $e->to_data;

Return hash reference. This method recursive call L</to_hash>.

Note: All private attributes (e.g. "_xxx") and "id", "created_at", "updated_at" are removed.

Objects that do not have method "to_data" are also deleted.

    my $e = Yetie::Domain::Entity->new({
        a => 1,
        b => Yetie::Domain::Collection->new(1,2,3);
        u => Mojo::URL->new,    # do not have method "to_data"
    });
    my $data = $e->to_data;

    print Dumper $data;
    $VAR1 = {
        a => 1,
        b => [1,2,3],
    };

=head2 C<to_hash>

    my $data = $entity->to_hash;

Return Hash reference.

Note: All private attributes (e.g. "_xxx") and "id", "created_at", "updated_at" are removed.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Domain::Base>, L<Moose>, L<Yetie::Domain::Collection>, L<Yetie::Domain::IxHash>
