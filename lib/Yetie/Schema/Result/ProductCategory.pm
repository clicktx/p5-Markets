package Yetie::Schema::Result::ProductCategory;
use Mojo::Base 'Yetie::Schema::Result';
use DBIx::Class::Candy -autotable => v1;

primary_column product_id  => { data_type => 'INT', };
primary_column category_id => { data_type => 'INT', };

column is_primary => {
    data_type     => 'BOOLEAN',
    is_nullable   => 0,
    default_value => 0,
};

# Relation
belongs_to
  product => 'Yetie::Schema::Result::Product',
  { 'foreign.id' => 'self.product_id' };

belongs_to
  detail => 'Yetie::Schema::Result::Category',
  { 'foreign.id' => 'self.category_id' };

sub to_data {
    my $self = shift;

    my $ancestors = $self->schema->resultset('Category')->get_ancestors_arrayref( $self->category_id );
    return {
        ancestors   => $ancestors,
        category_id => $self->category_id,
        is_primary  => $self->is_primary,
        title       => $self->detail->title,
    };
}

1;