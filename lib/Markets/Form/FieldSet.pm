package Markets::Form::FieldSet;
use Mojo::Base -base;
use Mojo::Util qw/monkey_patch/;
use Tie::IxHash;
use Scalar::Util qw/weaken/;
use Mojolicious::Controller;
use Mojo::Collection;
use Markets::Form::Field;

has field_list => sub { {} };
has controller => sub { Mojolicious::Controller->new };

sub append {
    my ( $self, $field_key ) = ( shift, shift );
    return unless ( my $class = ref $self || $self ) && $field_key;

    no strict 'refs';
    ${"${class}::field_list"}{$field_key} = +{@_};
}

sub checks { shift->_get_data_from_field( shift, 'validations' ) }

sub field_keys {
    my $self = shift;
    my $class = ref $self || $self;

    no strict 'refs';
    my @field_keys = keys %{"${class}::field_list"};
    return wantarray ? @field_keys : \@field_keys;
}

sub field {
    my ( $self, $name ) = ( shift, shift );
    my $args = @_ > 1 ? +{@_} : shift || {};
    my $class = ref $self || $self;

    my $field_key = _replace_key($name);

    no strict 'refs';
    my $attrs = $field_key ? ${"${class}::field_list"}{$field_key} : {};
    return Markets::Form::Field->new( field_key => $field_key, name => $name, %{$args}, %{$attrs} );
}

sub filters { shift->_get_data_from_field( shift, 'filters' ) }

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    weaken $self->{controller};

    no strict 'refs';
    $self->{field_list} = \%{"${class}::field_list"};
    return $self;
}

sub import {
    my $class  = shift;
    my $caller = caller;

    no strict 'refs';
    no warnings 'once';
    push @{"${caller}::ISA"}, $class;
    tie %{"${caller}::field_list"}, 'Tie::IxHash';
    monkey_patch $caller, 'has_field', sub { append( $caller, @_ ) };
    monkey_patch $caller, 'c', sub { Mojo::Collection->new(@_) };
}

sub remove {
    my ( $self, $field_key ) = ( shift, shift );
    return unless ( my $class = ref $self || $self ) && $field_key;

    no strict 'refs';
    delete ${"${class}::field_list"}{$field_key};
}

sub render_label {
    my $self = shift;
    my $name = shift;

    $self->field($name)->label_for;
}

sub render {
    my $self = shift;
    my $name = shift;

    my $field = $self->field( $name, value => $self->controller->req->params->param($name) );
    my $method = $field->type || 'text';
    $field->$method;
}

sub validate {
    my $self  = shift;
    my $v     = $self->controller->validation;
    my $names = $self->controller->req->params->names;

    foreach my $field_key ( @{ $self->field_keys } ) {
        my $required = $self->field_list->{$field_key}->{required};
        my $cheks    = $self->checks($field_key);

        if ( $field_key =~ m/\.\[\]/ ) {
            my @match = grep { my $name = _replace_key($_); $field_key eq $name } @{$names};
            foreach my $key (@match) {
                $required ? $v->required($key) : $v->optional($key);
                _do_check( $v, $_ ) for @$cheks;
            }
        }
        else {
            $required ? $v->required($field_key) : $v->optional($field_key);
            _do_check( $v, $_ ) for @$cheks;
        }
    }
    return $v->has_error ? undef : 1;
}

sub _do_check {
    my $v = shift;

    my ( $check, $args ) = ref $_[0] ? %{ $_[0] } : ( $_[0], undef );
    return $v->$check unless $args;

    return ref $args eq 'ARRAY' ? $v->$check( @{$args} ) : $v->$check($args);
}

sub _replace_key {
    my $arg = shift;
    $arg =~ s/\.\d/.[]/g;
    $arg;
}

1;
__END__

=encoding utf8

=head1 NAME

Markets::Form::Field

=head1 SYNOPSIS

    # Your form field class
    package Markets::Form::Type::User;
    use Markets::Form::FieldSet;

    has_field 'name' => ( %args );
    ...

    # In controller
    my $fieldset = $c->form_set('user');

    if ( $fieldset->validate ){
        $c->render( text => 'thanks');
    } else {
        $c->render( text => 'validation failure');
    }


=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 C<controller>

    my $controller = $fieldset->controller;
    $fieldset->controller( Mojolicious::Controller->new );

Return L<Mojolicious::Controller> object.

=head1 FUNCTIONS

=head2 C<c>

    my $collection = c(1, 2, 3);

Construct a new array-based L<Mojo::Collection> object.

=head2 C<has_field>

    has_field 'field_name' => ( type => 'text', ... );

=head1 METHODS

=head2 C<append>

    $fieldset->append( 'field_name' => ( %args ) );

=head2 C<checks>

    # Return array refference
    my $checks = $fieldset->checks('email');

    # Return hash refference
    my $checks = $fieldset->checks;

=head2 C<field_keys>

    my @field_keys = $fieldset->field_keys;

    # Return array refference
    my $field_keys = $fieldset->field_keys;

=head2 C<field>

    my $field = $fieldset->field('field_name');

Return L<Markets::Form::Field> object.

=head2 C<filters>

    # Return array refference
    my $filters = $fieldset->filters('field_key');

    # Return hash refference
    my $filters = $fieldset->filters;

=head2 C<remove>

    $fieldset->remove('field_name');

=head2 C<render_label>

    $fieldset->render_label('email');

Return code refference.

=head2 C<render>

    $fieldset->render('email');

Return code refference.

=head2 C<validate>

    my $bool = $fieldset->validate;
    say 'Validation failure!' unless $bool;

Return boolean. success return true.

=head1 SEE ALSO

=cut