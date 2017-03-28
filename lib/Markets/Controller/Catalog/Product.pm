package Markets::Controller::Catalog::Product;
use Mojo::Base 'Markets::Controller::Catalog';

sub index {
    my $self = shift;
    $self->render();
}

sub add_to_cart {
    my $self = shift;

    die unless $self->service('cart')->add_item;

    use DDP;
    p $self->cart->to_hash;    # debug

    $self->flash( ref => $self->req->url->to_string );
    $self->redirect_to('RN_cart');
}

1;
