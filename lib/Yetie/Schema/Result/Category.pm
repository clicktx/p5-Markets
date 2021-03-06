package Yetie::Schema::Result::Category;
use Mojo::Base 'Yetie::Schema::Result';
use DBIx::Class::Candy -autotable => v1, -components => [qw( Tree::NestedSet )];

primary_column id => {
    data_type         => 'INT',
    is_auto_increment => 1,
};

column root_id => {
    data_type   => 'INT',
    is_nullable => 1,
};

column lft => {
    data_type   => 'INT',
    is_nullable => 0,
};

column rgt => {
    data_type   => 'INT',
    is_nullable => 0,
};

column level => {
    data_type   => 'INT',
    is_nullable => 0,
};

column title => {
    data_type   => 'VARCHAR',
    size        => 64,
    is_nullable => 0,
};

# NOTE: Need a sqlt_deploy_hook
__PACKAGE__->tree_columns(
    {
        root_column  => 'root_id',
        left_column  => 'lft',
        right_column => 'rgt',
        level_column => 'level',
    }
);

# Relation
has_many
  products => 'Yetie::Schema::Result::ProductCategory',
  { 'foreign.category_id' => 'self.id' },
  { cascade_delete        => 0 };

has_many
  tax_rules => 'Yetie::Schema::Result::CategoryTaxRule',
  { 'foreign.category_id' => 'self.id' },
  {
    cascade_delete => 0,
    join_type      => 'inner',
  };

# Add Index
sub sqlt_deploy_hook {
    my ( $self, $table ) = @_;

    $table->add_index( name => 'idx_root_id', fields => ['root_id'] );
    $table->add_index( name => 'idx_level',   fields => ['level'] );

    # HACK: Create constraints and indexes at schema deployment.
    $table->drop_constraint('categories_fk_root_id');
    $table->drop_index('categories_idx_root_id');
}

sub descendant_ids {
    my $self = shift;

    my @rs = $self->result_source->resultset->search(
        { root_id => $self->root_id, lft => { '>' => $self->lft }, rgt => { '<' => $self->rgt } } );
    my @ids = map { $_->id } @rs;
    unshift @ids, $self->id;

    return wantarray ? @ids : \@ids;
}

# NOTE: 下位カテゴリに所属するproductsも全て取得
# TODO: SQLが非効率な可能性が高いので検証
sub search_products_in_categories {
    my $self = shift;
    my $args = @_ ? @_ > 1 ? {@_} : shift : {};

    my @category_ids = $self->descendant_ids;
    my $products     = $self->schema->resultset('Product')->search(
        { 'product_categories.category_id' => { IN => \@category_ids } },
        {
            prefetch => 'product_categories',
            page     => $args->{page} // 1,
            rows     => $args->{rows} // 10,
        },
    );
}

# search_related with special handling for relationships
# sub search_related {
#     my ( $self, $rel, $cond, @rest ) = @_;

#     my $columns = [qw( me.id me.root_id me.level me.title)];
#     push @rest, { columns => $columns, order_by => 'me.lft' };
#     return $self->next::method( $rel, $cond, @rest );
# }
# *search_related_rs = \&search_related;

sub to_data {
    my ( $self, $options ) = @_;

    my $data = {
        id      => $self->id,
        root_id => $self->root_id,
        level   => $self->level,
        title   => $self->title,
    };

    # Options
    if ( !$options->{no_children} ) {
        $data->{children} = $self->children->to_data;
        $data->{ancestors} = $self->ancestors->to_data( { no_children => 1 } );
    }

    return $data;
}

1;
__END__
=encoding utf8

=head1 NAME

Yetie::Schema::Result::Category

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

L<Yetie::Schema::Result::Category> inherits all attributes from L<Yetie::Schema::Result> and implements
the following new ones.

=head1 METHODS

L<Yetie::Schema::Result::Category> inherits all methods from L<Yetie::Schema::Result>
and L<DBIx::Class::Tree::NestedSet> and implements the following new ones.

=head2 C<descendant_ids>

    my $category->find($category_id);

    my @ids = $category->descendant_ids;
    my $ids = $category->descendant_ids;

Return Array or Array reference.

NOTE: return values includes C<me.id> in addition to descendant ids.

=head2 C<search_products_in_categories>

    my $rs = $category->search_products_in_categories( page => 1, rows => 10 );
    my $rs = $category->search_products_in_categories( { page => 1, rows => 10 } );

Return L<Yetie::Schema::ResultSet::Product> object.

Search products belonging to this category.
Includes descendants of the current category.

=head2 C<search_related>

Getting columns is C<id, root_id, level, title>

See L<DBIx::Class::Tree::NestedSet/search_related>.

=head2 C<to_data>

    my $hashref = $result->to_data;

I<OPTIONS>

=over

=item * no_children

    my $data = $result->to_data( { no_children => 1 } );

Set to C<true>, returns value does not include C<children>.

=back

=head1 AUTHOR

Yetie authors.

=head1 SEE ALSO

L<DBIx::Class::Tree::NestedSet>, L<Yetie::Schema::Result>, L<Yetie::Schema>
