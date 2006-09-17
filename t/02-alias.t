
# Tests for alias related code. See code block labeled "Alias fun"

use Test::More tests => 12;

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
    my $cur_sess;

# session_id_loggable {{{
    my $log_id;
    eval { $log_id = $api->session_id_loggable() };
    ok(!$@, "session_id_loggable() causes no exceptions");
    like($log_id, qr/session 2 \(POE::Session/, "session_id_loggable() returns proper string when no alias");
    
    $_[KERNEL]->alias_set('PIE');
    
    $log_id = undef;
    eval { $log_id = $api->session_id_loggable() };
    ok(!$@, "session_id_loggable() causes no exceptions");
    like($log_id, qr/session 2 \(PIE/, "session_id_loggable() returns proper string when alias is set");

# }}}

# session alias_count {{{

    my $alias_count;
    eval { $alias_count = $api->session_alias_count() };
    ok(!$@, "session_alias_count() causes no exceptions");
    is($alias_count, 1, "session_alias_count() returns the proper alias count");

# }}}

# session_alias_list {{{

    my @aliases;
    eval { @aliases = $api->session_alias_list() };
    ok(!$@, "session_alias_list() causes no exceptions");
    is(scalar @aliases, 1, 'session_alias_list() returns proper amount of data');
    is($aliases[0], 'PIE', 'session_alias_list() returns proper data');
    
# }}}

# resolve_alias {{{

    my $session;
    eval { $session = $api->resolve_alias('PIE') };
    ok(!$@, "resolve_alias() causes no exceptions");
    is_deeply($session, $sess, "resolve_alias() resolves the provided alias properly");

# }}}

}


sub _stop {


}
