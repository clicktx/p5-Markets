package Yetie::Schema::Result::AuthorizationRequest;
use Mojo::Base 'Yetie::Schema::Base::Result';
use DBIx::Class::Candy -autotable => v1;

primary_column id => {
    data_type         => 'INT',
    is_auto_increment => 1,
};

column email => {
    data_type   => 'VARCHAR',
    size        => 128,
    is_nullable => 0,
};

column token => {
    data_type   => 'VARCHAR',
    size        => 40,
    is_nullable => 0,
};

column redirect => {
    data_type   => 'VARCHAR',
    size        => 256,
    is_nullable => 1,
};

column request_ip => {
    data_type   => 'VARCHAR',
    size        => 45,
    is_nullable => 0,
};

column is_activated => {
    data_type     => 'BOOLEAN',
    is_nullable   => 0,
    default_value => 0,
};

column expires => {
    data_type   => 'INT',
    is_nullable => 0,
};

column created_at => {
    data_type   => 'DATETIME',
    is_nullable => 0,
    timezone    => Yetie::Schema->TZ,
};

column updated_at => {
    data_type   => 'DATETIME',
    is_nullable => 1,
    timezone    => Yetie::Schema->TZ,
};

# Index
unique_constraint ui_token => [qw/token/];

sub sqlt_deploy_hook {
    my ( $self, $table ) = @_;
    $table->add_index( name => 'idx_email', fields => ['email'] );
}

1;