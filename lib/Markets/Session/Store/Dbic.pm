package Markets::Session::Store::Dbic;
use Mojo::Base 'MojoX::Session::Store';

# use MIME::Base64; シリアライズ時にbase64する必要があるか？MessagePackなら不要？
use Try::Tiny;
use Data::MessagePack;
use Mojo::Util;

has 'schema';
has resultset_session => 'Session';
has resultset_cart    => 'Cart';
has sid_column        => 'sid';
has expires_column    => 'expires';
has data_column       => 'data';
has cart_id_column    => 'cart_id';

sub create {
    my ( $self, $sid, $expires, $data ) = @_;

    my $schema         = $self->schema;
    my $sid_column     = $self->sid_column;
    my $expires_column = $self->expires_column;
    my $data_column    = $self->data_column;
    my $cart_id_column = $self->cart_id_column;

    my ( $session_data, $cart_id, $cart_data ) = _separate_session_data($data);
    my $session_data_mp = $session_data ? Data::MessagePack->pack($session_data) : '';
    my $cart_data_mp    = %$cart_data   ? Data::MessagePack->pack($cart_data)    : '';

    my $cb = sub {

        # Cart
        $schema->resultset( $self->resultset_cart )->create(
            {
                $cart_id_column => $cart_id,
                $data_column    => $cart_data_mp,
            }
        );

        # Session
        $schema->resultset( $self->resultset_session )->create(
            {
                $sid_column     => $sid,
                $expires_column => $expires,
                $data_column    => $session_data_mp,
                $cart_id_column => $cart_id,
            }
        );
    };

    try {
        $schema->txn_do($cb);
        return 1;
    }
    catch {
        $self->error($_);
        return;
    };
}

sub update {
    my ( $self, $sid, $expires, $data ) = @_;

    my ( $session_data, $cart_id, $cart_data ) = _separate_session_data($data);

    # カートの変更をチェック
    my $cart_data_mp = %$cart_data ? Data::MessagePack->pack($cart_data) : '';
    my ( $is_modified, $checksum ) = _cart_checksum( $session_data, $cart_data_mp );
    $session_data->{cart_checksum} = $checksum;

    my $schema          = $self->schema;
    my $sid_column      = $self->sid_column;
    my $expires_column  = $self->expires_column;
    my $data_column     = $self->data_column;
    my $cart_id_column  = $self->cart_id_column;
    my $session_data_mp = $session_data ? Data::MessagePack->pack($session_data) : '';

    my $cb = sub {

        # Update Cart
        $schema->resultset( $self->resultset_cart )->search( { $cart_id_column => $cart_id } )
          ->update( { $data_column => $cart_data_mp } )
          if $is_modified;

        # Update Session
        $schema->resultset( $self->resultset_session )->search( { $sid_column => $sid } )->update(
            {
                $expires_column => $expires,
                $data_column    => $session_data_mp,
                $cart_id_column => $cart_id,
            }
        );
    };

    try {
        $schema->txn_do($cb);
        return 1;
    }
    catch {
        $self->error($_);
        return;
    };
}

sub update_sid {
    my ( $self, $original_sid, $new_sid ) = @_;

    my $schema     = $self->schema;
    my $sid_column = $self->sid_column;

    return $schema->resultset( $self->resultset_session )
      ->search( { $sid_column => $original_sid } )->update( { $sid_column => $new_sid } ) ? 1 : 0;
}

sub load {
    my ( $self, $sid ) = @_;

    my $schema         = $self->schema;
    my $sid_column     = $self->sid_column;
    my $expires_column = $self->expires_column;
    my $data_column    = $self->data_column;
    my $cart_id_column = $self->cart_id_column;

    my $row_session =
      $schema->resultset( $self->resultset_session )->find( { $sid_column => $sid } );
    return unless $row_session;

    my $expires         = $row_session->get_column($expires_column);
    my $session_data_mp = $row_session->get_column($data_column);
    my $session_data    = $session_data_mp ? Data::MessagePack->unpack($session_data_mp) : {};
    my $cart_id         = $row_session->get_column($cart_id_column);
    $session_data->{cart_id} = $cart_id if $cart_id;

    my $cart_data_mp =
        $session_data->{cart_checksum}
      ? $schema->resultset( $self->resultset_cart )->find( { $cart_id_column => $cart_id } )
      ->get_column($data_column)
      : '';
    $session_data->{cart} = $cart_data_mp ? Data::MessagePack->unpack($cart_data_mp) : '';

    return ( $expires, $session_data );
}

sub delete {
    my ( $self, $sid ) = @_;

    my $schema         = $self->schema;
    my $sid_column     = $self->sid_column;
    my $cart_id_column = $self->cart_id_column;

    # session deleteで関係するcartもdeleteされる
    my $cb = sub {
        my $session = $schema->resultset( $self->resultset_session )->find($sid)->delete;
        # $session->delete_related('cart');#リレーション設定により不要
    };

    try {
        $schema->txn_do($cb);
        return 1;
    }
    catch {
        $self->error($_);
        say $_;
        return;
    };
}

sub _separate_session_data {
    my $data = shift;

    my %clone     = %$data;
    my $cart_id   = delete $clone{cart_id};
    my $cart_data = delete $clone{cart};

    return ( \%clone, $cart_id, $cart_data );
}

# カートデータからchecksumを生成
# カートデータが空の場合のchecksumは空文字
sub _cart_checksum {
    my ( $session_data, $cart_data_mp ) = @_;

    my $checksum     = $session_data->{cart_checksum};
    my $new_checksum = $cart_data_mp ? Mojo::Util::md5_sum($cart_data_mp) : '';
    my $is_modified  = $checksum ne $new_checksum ? 1 : 0;

    return $is_modified, $new_checksum;
}

1;
__END__

=head1 NAME

Markets::Session::Store::Dbic - Dbic Store for MojoX::Session

=head1 SYNOPSIS

    CREATE TABLE sessions (
        sid          VARCHAR(50) PRIMARY KEY,
        data         MEDIUMTEXT,
        cart_id      VARCHAR(50),
        expires      BIGINT NOT NULL
    );
    CREATE TABLE carts (
        cart_id      VARCHAR(50) PRIMARY KEY,
        data         MEDIUMTEXT
    );

    # Your App
    my $schema = MyDbic::DB->new(...);
    my $session = MojoX::Session->new(
        store => Markets::Session::Store::Dbic->new( schema => $schema ),
        ...
    );

=head1 DESCRIPTION

L<Markets::Session::Store::Dbic> is a store for L<MojoX::Session> that stores a
session in a database using Dbic.

forked by L<MojoX::Session::Store::Dbic>

=head1 ATTRIBUTES

L<Markets::Session::Store::Dbic> implements the following attributes.

=head2 C<schema>

    my $schema = $store->schema;
    $store->schema($schema);

Get and set L<DBIx::Class::Schema> object.

=head2 C<sid_column>

Session id column name. Default is 'sid'.

=head2 C<expires_column>

Expires column name. Default is 'expires'.

=head2 C<data_column>

Data column name. Default is 'data'.

=head2 C<cart_id_column>

Cart column name. Default is 'cart_id'.

=head1 METHODS

L<Markets::Session::Store::Dbic> inherits all methods from
L<MojoX::Session::Store>.

=head2 C<create>

Insert session to database.

=head2 C<update>

Update session in database.

=head2 C<update_sid>

Update sid in database.

=head2 C<load>

Load session from database.

=head2 C<delete>

Delete session from database.

=head1 SEE ALSO

L<Markets::Session::Cart>

L<DBIx::Class>

L<Mojolicious::Plugin::Session>

L<MojoX::Session::Store>

L<MojoX::Session::Store::Dbic>

L<MojoX::Session>

=head1 AUTHOR

clicktx

=head1 COPYRIGHT

Copyright (C) 2016, clicktx.

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl 5.10.

=cut