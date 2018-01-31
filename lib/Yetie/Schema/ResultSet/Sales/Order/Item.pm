package Yetie::Schema::ResultSet::Sales::Order::Item;
use Mojo::Base 'Yetie::Schema::Base::ResultSet';

sub to_data {
    my $self = shift;

    my @items;
    $self->each( sub { push @items, shift->to_data } );
    return \@items;
}

1;
__END__
=encoding utf8

=head1 NAME

Yetie::Schema::ResultSet::Sales::Order::Item

=head1 SYNOPSIS

    my $data = $schema->resultset('Sales::Order::Item')->method();

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Schema::ResultSet::Sales::Order::Item> inherits all attributes from L<Yetie::Schema::Base::ResultSet> and implements
the following new ones.

=head1 METHODS

L<Yetie::Schema::ResultSet::Sales::Order::Item> inherits all methods from L<Yetie::Schema::Base::ResultSet> and implements
the following new ones.

=head2 C<to_data>

    my $data = $rs->to_data;

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Schema::Base::ResultSet>, L<Yetie::Schema>
