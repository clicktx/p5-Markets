package Markets::Form::FieldSet;
use Mojo::Base -base;
use Mojo::Util qw/monkey_patch/;
use Tie::IxHash;
use Markets::Form::Field;

has 'legend';

sub add {
    my ( $self, $field_name ) = ( shift, shift );
    return unless ( my $class = ref $self || $self ) && $field_name;

    no strict 'refs';
    ${"${class}::fields"}{$field_name} = Markets::Form::Field->new( name => $field_name, @_ );
}

sub each {
    my ( $self, $cb ) = @_;
    my $class = ref $self || $self;
    my $caller = caller;

    no strict 'refs';
    foreach my $a ( $self->keys ) {
        my $b = %{"${class}::fields"}{$a};
        local ( *{"${caller}::a"}, *{"${caller}::b"} ) = ( \$a, \$b );
        $a->$cb($b);
    }
}

sub field {
    my $self = shift;
    my $class = ref $self || $self;

    no strict 'refs';
    @_ ? ${"${class}::fields"}{ $_[0] } : 0;
}

# sub fields {
#     my $self = shift;
#     my $class = ref $self || $self;
#
#     no strict 'refs';
#     return %{"${class}::fields"};
# }

sub keys {
    my $self = shift;
    my $class = ref $self || $self;

    no strict 'refs';
    return keys %{"${class}::fields"};
}

sub import {
    my $class  = shift;
    my $caller = caller;

    no strict 'refs';
    no warnings 'once';
    push @{"${caller}::ISA"}, $class;
    tie %{"${caller}::fields"}, 'Tie::IxHash';
    monkey_patch $caller, 'has_field', sub { add( $caller, @_ ) };
}

sub remove {
    my ( $self, $field_name ) = ( shift, shift );
    return unless ( my $class = ref $self || $self ) && $field_name;

    no strict 'refs';
    delete ${"${class}::fields"}{$field_name};
}

1;

=encoding utf8

=head1 NAME

Markets::Form::Field

=head1 SYNOPSIS

    package MyForm::Field::User;
    use Markets::Form::FieldSet;

    has_field 'name' => ( %args );


    # In controller
    my $fieldset = MyForm::Field::User->new();


=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 C<has_field>

    has_field 'field_name' => ( type => 'text', ... );

=head1 METHODS

=head2 C<add>

    $obj->add( 'field_name' => ( %args ) );

=head2 C<each>

    $obj->each( sub { say $a, $b } );
    $obj->each( sub { my ( $field_name, $field_obj ) } );

C<$b> is L<Markets::Form::Field> object.

=head2 C<field>

    my $field = $obj->field('field_name');

=head2 C<keys>

    my @keys = $obj->keys;

=head2 C<remove>

    $obj->remove('field_name');

=head1 SEE ALSO

=cut
