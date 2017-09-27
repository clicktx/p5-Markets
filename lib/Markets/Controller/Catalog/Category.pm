package Markets::Controller::Catalog::Category;
use Mojo::Base 'Markets::Controller::Catalog';

sub index {
    my $self = shift;

    my $category_id = $self->stash('category_id');

    my $rs = $self->app->schema->resultset('Category');
    $self->stash( rs => $rs );

    my $category = $rs->find( $category_id, { prefetch => { products => 'product' } } );
    return $self->reply->not_found() unless $category;

    my $form = $self->form_set();
    $self->init_form();

    # return $self->render() unless $form->has_data;
    $form->validate;

    my $page = $form->param('p') || 1;

    # 下位カテゴリ取得
    my @category_ids = $category->descendant_ids;

    # 下位カテゴリに所属するproductsも全て取得
    # NOTE: SQLが非効率な可能性高い
    my $products = $self->schema->resultset('Product')->search(
        { 'product_categories.category_id' => { IN => \@category_ids } },
        {
            prefetch => 'product_categories',
            page     => $page,
            rows     => 3,
        },
    );

    my @breadcrumb;
    my $itr = $category->ancestors;
    while ( my $ancestor = $itr->next ) {
        push @breadcrumb,
          {
            title => $ancestor->title,
            uri   => $self->url_for(
                'RN_category_name_base' => { category_name => $ancestor->title, category_id => $ancestor->id }
            )
          };
    }
    push @breadcrumb,
      {
        title => $category->title,
        uri   => $self->url_for(
            'RN_category_name_base' => { category_name => $category->title, category_id => $category_id }
        )
      };

    # content entity
    my $content = $self->app->factory('entity-content')->create(
        {
            title      => $category->title,
            breadcrumb => \@breadcrumb,
            pager      => $products->pager,
            params     => $form->params->to_hash,
        }
    );

    $self->stash(
        content  => $content,
        category => $category,
        products => $products,
    );

    return $self->render();
}

1;
