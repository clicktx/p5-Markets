package Yetie::Service::Orders;
use Mojo::Base 'Yetie::Service';

has resultset => sub { shift->app->resultset('Sales::Order') };

sub search_orders {
    my ( $self, $form ) = @_;

    my $conditions = {
        where    => '',
        order_by => '',
        page_no  => $form->param('page') || 1,
        per_page => $form->param('per_page') || 5,
    };
    my $result = $self->resultset->search_sales_orders($conditions);
    my $data   = $result->to_data;
    my $orders = $self->factory('entity-page-orders')->create(
        {
            title      => 'Orders',
            form       => $form,
            breadcrumb => [],
            pager      => $result->pager,
            order_list => $data,
        }
    );
    return $orders;
}

1;
__END__

=head1 NAME

Yetie::Service::Orders

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Service::Orders> inherits all attributes from L<Yetie::Service> and implements
the following new ones.

=head1 METHODS

L<Yetie::Service::Orders> inherits all methods from L<Yetie::Service> and implements
the following new ones.

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<Yetie::Service>
