use Mojo::Base -strict;

use Test::More;

use_ok $_ for qw(
    Markets
    Markets::Web
    Markets::Admin
);

done_testing();