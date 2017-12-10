package Yetie::Controller::Admin::Category;
use Mojo::Base 'Yetie::Controller::Admin';

sub index {
    my $self = shift;

    my $form = $self->form('admin-category');
    my $rs   = $self->app->schema->resultset('Category');
    $self->stash( rs => $rs );

    # Init form
    my $tree = $rs->get_category_choices;
    $form->field('parent_id')->choices($tree);
    $self->init_form();

    return $self->render() unless $form->has_data;

    return $self->render() unless $form->do_validate;

    # Validation
    # 同階層の同名カテゴリを作成しない
    my ( $title, $parent_id ) = ( $form->param('title'), $form->param('parent_id') );
    if ( $rs->has_title( $title, $parent_id ) ) {
        $form->validation->error( title => ['duplicate_title'] );
        return $self->render( status => 409 );
    }

    # Create category
    $rs->create_category( $title, $parent_id );
    $self->redirect_to('RN_admin_category');
}

sub edit {
    my $self = shift;

    my $category_id = $self->stash('category_id');
    my $entity      = $self->factory('category')->build($category_id);
    return $self->reply->not_found() unless $entity->has_data;

    my $form = $self->form('admin-category')->fill_in($entity);
    return $self->render() unless $form->has_data;
    return $self->render() unless $form->do_validate;

    # update
    # title
    $entity->title( $form->param('title') );

    use DDP;
    p $entity;
    p $entity->is_modified;
    $self->service('category')->update( $entity, [] ) if $entity->is_modified;

    p $self->current_route;
    p $self->server_session;
    $self->app->admin_log->info('Category updated for id:' . $category_id );
    return $self->redirect_to( $self->current_route, category_id => $category_id );
}

1;
