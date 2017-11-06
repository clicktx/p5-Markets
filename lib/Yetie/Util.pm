package Yetie::Util;
use Mojo::Base -strict;

use Exporter 'import';
use Carp qw(croak);
use File::Find::Rule;
use Session::Token;
use Mojo::Loader;

our @EXPORT_OK = ( qw(directories generate_token load_class), );

=head1 FUNCTIONS

L<Yetie::Util> implements the following functions, which can be imported
individually.

=over

=item C<directories>

List all sub directories in a directory.

B<options>

ignore - ignore directory name.

    use Yetie::Util qw(directories);

    $sub_directories = directories('hoge', { ignore => ['huga'] });
    @sub_directories = directories('hoge', { ignore => ['huga'] });

=back

=cut

sub directories {
    my ( $dir, $options ) = ( shift, shift // {} );
    my @sub_directories;
    my $ignore_dir = $options->{ignore} // '';

    my $rule = File::Find::Rule->new;
    if ($ignore_dir)
    {    # Hack the `Use of uninitialized value $regex in regexp compilation at Text/Glob.pm`
        $rule->not( File::Find::Rule->name($ignore_dir) );
    }
    $rule->maxdepth(1)->directory->start($dir);

    while ( my $sub_dir = $rule->match ) {
        $sub_dir =~ s/$dir\/?//;
        push @sub_directories, $sub_dir if $sub_dir;
    }
    return wantarray ? @sub_directories : \@sub_directories;
}

=over

=item C<generate_token>

Generate secure token. based L<Session::Token>

    use Yetie::Util qw(genarate_token);
    my $token = genarate_token( { length => 30 } );
    # -> ZVZdkwIfNrvsk9N8f3jB0zBZ12kePJ

B<options>

SEE ALSO L<Session::Token>

=back

=cut

sub generate_token { Session::Token->new(@_)->get }

=over

=item C<load_class>

Load a class.

    use Yetie::Util qw(load_class);

    load_class 'Foo::Bar';

SEE ALSO L<Mojo::Loader/load_class>

=back

=cut

sub load_class {
    my $class = shift;

    if ( my $e = Mojo::Loader::load_class($class) ) {
        croak ref $e ? "Exception: $e" : "$class not found!";
    }
    1;
}

1;