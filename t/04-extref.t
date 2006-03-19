
# Tests for extref related code. See code block labeled "Extref fun"

use Test::More qw|no_plan|;

use warnings;
use strict;
use POE;
use Data::Dumper;

use_ok('POE::API::Peek');

my $api = POE::API::Peek->new();

POE::Session->create(
    inline_states => {
        _start => \&_start,
        _stop => \&_stop,

    },
    heap => { api => $api },
);

POE::Kernel->run();

###############################################

sub _start {
    my $sess = $_[SESSION];
    my $api = $_[HEAP]->{api};

# extref_count {{{
    my $ext_count;
    eval { $ext_count = $api->extref_count() };
    ok(!$@, 'extref_count() does not cause exceptions');
    is($ext_count, 0, 'extref_count() returns proper count');
# }}}

# get_session_extref_count {{{
    my $sess_ext_count;
    eval { $sess_ext_count = $api->get_session_extref_count() };
    ok(!$@, 'get_session_extref_count() does not cause exceptions');
    is($sess_ext_count, 0, 'get_session_extref_count() returns proper count');
# }}}

}


sub _stop {


}
