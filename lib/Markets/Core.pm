package Markets::Core;
use Mojo::Base 'Mojolicious';

use Carp qw/croak/;
use File::Spec;
use File::Basename;
use DBI;
use Markets::Util;
use Markets::DB;
use Markets::Session::Store::Teng;
use Markets::Hook::Action;
use Markets::Hook::Filter;

my $all_addons;

BEGIN {
    # add path to @INC
    my $base_dir =
      File::Spec->catdir( dirname(__FILE__), '..', '..', 'addons' );
    $all_addons = Markets::Util::directories('addons');
    foreach my $path (@$all_addons) {
        push @INC,
          Mojo::Path->new( File::Spec->catdir( $base_dir, $path, 'lib' ) )
          ->canonicalize->to_string;
    }
}

has util => sub { Markets::Util->new };
has dbh => sub {
    my $self = shift;
    my $conf = $self->config->{db} or die "Missing configuration for db";
    my $dsn  = $self->dsn($conf);
    my $dbh  = DBI->connect( $dsn, { RaiseError => 1 } ) or die $DBI::errstr;
    say "connecting DB.";                            # debug
    say '$app->dbh => ' . $dbh . 'on Markets.pm';    # debug
    return $dbh;
};
has db => sub {
    say "+++++ DB. +++++";                           # debug
    my $db = Markets::DB->new( dbh => shift->dbh );
    return $db;
};
has actions => sub { Markets::Hook::Action->new };
has filters => sub { Markets::Hook::Filter->new };

sub add_action {
    my ( $self, $name, $cb, $conf ) = ( shift, shift, shift, shift // {} );
    $conf->{client} = caller;
    $self->actions->add_action( $name, $cb, $conf );
}

sub add_filter {
    my ( $self, $name, $cb, $conf ) = ( shift, shift, shift, shift // {} );
    $conf->{client} = caller;
    $self->filters->add_filter( $name, $cb, $conf );
}

sub dsn {
    my ( $self, $conf ) = @_;
    my $dsn;
    if ( $ENV{TEST_MYSQL} ) {
        $dsn = $ENV{TEST_MYSQL};
    }
    else {
        $dsn =
            "DBI:$conf->{dbtype}:dbname=$conf->{dbname};"
          . "host=$conf->{host};port=$conf->{port};"
          . "user=$conf->{user};password=$conf->{password};";
    }
    return $dsn;
}

sub initialize_app {
    my $self = shift;
    my $home = $self->home;
    my $mode = $self->mode;

    # change log dir
    $self->log->path( $home->rel_file("var/log/$mode.log") )
      if -d $home->rel_file('var/log') && -w _;

    my $config_path = $home->rel_file("config/$mode.conf");
    $self->plugin( Config => { file       => $config_path } );
    $self->plugin( Model  => { namespaces => ['Markets::Model'] } );

    # constants
    $self->helper(
        const => sub {
            my ( $c, $key ) = @_;
            my $constants = $c->app->config('constants');
            unless ( $constants->{$key} ) {
                $c->app->log->warn("const('$key') has no constant value.");
                croak "const('$key') has no constant value.";
            }
            return $constants->{$key};
        }
    );
    my $constants = $self->model('data-constant')->load;
    $constants->{LINK_NAME} = 'リンク先';          # ex)
    $constants->{ROOT_URL}  = 'http://google.com/';    # ex)
    $self->config( constants => $constants );

    # $self->config( constants => $self->model('data-constant')->load );

    # [WIP] addon config
    my $addons_setting_from_db = [
        {
            name       => 'MyAddon',
            is_enabled => 1,
            hooks      => {
                before_compile_template => 300,
                before_xxx_action       => 500,
            },
        },

        # DBで is_enabled=false を除く事も出来るが...
        {
            name       => 'MyDisableAddon',
            is_enabled => 0,
        },
    ];
    $self->config( addons => $addons_setting_from_db );

    # regist enable addons
    my $addons = $self->config->{addons};
    my @enabled = grep { $_->{is_enabled} } @$addons;
    foreach my $addon (@enabled) {
        my $addon_name = $addon->{name};
        my $hooks = $addon->{hooks} || {};
        $self->plugin( "Addon::" . $addon_name => $hooks );
    }

    # load config after. option schema loading.
    my $more_schema_classes_from_db = [qw /Markets::DB::Schema::More/];
    $self->db->merge_schema($more_schema_classes_from_db);

    # session
    my $rs = $self->db->resultset('sessions');
    $self->plugin(
        'Markets::Plugin::Session' => {
            stash_key => 'markets_session',
            store     => Markets::Session::Store::Teng->new( resultset => $rs ),
            expires_delta => 3600,
        }
    );

    # locale
    $ENV{MOJO_I18N_DEBUG} = $self->mode eq 'development' ? 1 : 0;
    $self->plugin(
        'LocaleTextDomainOO',
        {
            # file_type => 'po',    # or 'mo'. default: po
            default   => 'en',               # default en
            languages => [qw( en ja de )],

            # Mojolicious::Plugin::I18N like options
            no_header_detect  => 1,                   # option. default: false
            support_url_langs => [qw( en ja de )],    # option
        }
    );

    # loading lexicon files
    $self->lexicon(
        {
            search_dirs =>
              [ File::Spec->catdir( $self->home, 'share', 'locale' ) ],

            # gettext_to_maketext => $boolean,                    # option
            # decode              => $boolean,                    # option
            data => [ '*::' => '*.po' ],
        }
    );

 # loading lexicon for addons
 # TODO: config->{addons}->{enable}のみを読み込むように修正しよう
 #       addon configを考慮すると全てのアドオンのlocaleを読み込んだほうが良い
    foreach my $addon (@$all_addons) {
        my $text_domain = Mojo::Util::decamelize($addon);
        $self->lexicon(
            {
                search_dirs => [
                    File::Spec->catdir(
                        $self->home, 'addons', $addon, 'locale'
                    )
                ],
                data => [ "*::$text_domain" => '*.po' ],    # set text domain
            }
        );
    }

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    # helper
    $self->helper( markets_session => sub { shift->stash('markets_session') } );
}

1;
