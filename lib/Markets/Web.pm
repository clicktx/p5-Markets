package Markets::Web;
use Mojo::Base 'Markets::Core';
use Markets::Util qw(directories);

# This method will run once at server start
sub startup {
    my $self = shift;
    $self->initialize_app;

    # templets paths
    $self->renderer->paths( [ 'themes/default', 'themes/admin' ] );
    my $themes = directories( 'themes', { ignore => [ 'default', 'admin' ] } );
    say $self->dumper($themes);    # debug

    # unshift @{$self->renderer->paths}, 'themes/mytheme';

    # renderer
    $self->plugin('Markets::Plugin::EPRenderer');
    $self->plugin('Markets::Plugin::EPLRenderer');
    $self->plugin('Markets::Plugin::DOM');

    # Routes
    $self->plugin('Markets::Admin::DispatchRoutes');
    $self->plugin('Markets::Web::DispatchRoutes');

    # Loading indtalled Addons
    # [WIP] addon config
    my $addons_setting_from_db = {
        'Markets::Addon::MyAddon' => {
            is_enabled => 1,
            hooks      => [],
            config     => {
                hook_priorities => {
                    before_compile_template => 300,
                    before_xxx_action       => 500,
                    # action_replace_template => 222,
                },
            },
        },
        # 'Markets::Addon::MyDisableAddon' => {
        #     is_enabled => 0,
        #     hooks      => [],
        #     config     => {},
        # },
        'Markets::Addon::Newpage' => {
            is_enabled => 1,
            hooks      => [],
            config     => {},
        },
    };

    # Initialize all addons
    $self->addons->init($addons_setting_from_db);
}

1;
