
# Tests for filehandle related code. See code block labeled "Filehandle fun"

use Test::More tests => 18;

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

        sig_handler => \&sig_handler,
    },
    heap => { api => $api },
);

POE::Kernel->run();

###############################################

sub _start {
    my $sess = $_[SESSION];
    my $api = $_[HEAP]->{api};

# get_safe_signals {{{
    my @safe_signals;
    eval { @safe_signals = $api->get_safe_signals };
    ok(!$@, 'get_safe_signals() does not cause exceptions');
    ok(scalar @safe_signals, "get_safe_signals() returns a list");
# }}}

# get_signal_type {{{
    my $sig_type;
    eval { $sig_type = $api->get_signal_type('INT'); };
    ok(!$@, 'get_signal_type() causes no exceptions');
    is($sig_type, &POE::Kernel::SIGTYPE_TERMINAL, 'get_signal_type() returns proper type for SIG INT');
# }}}

# is_signal_watched {{{
    my $bool2;
    eval { $bool2 = $api->is_signal_watched('INT') };
    ok(!$@, 'is_signal_watched() causes no exceptions');
    ok(!$bool2, 'is_signal_watched() correctly returns that INT is not being watched');
    
    $poe_kernel->sig('INT', 'sig_handler');
   
    my $bool3;
    eval { $bool3 = $api->is_signal_watched('INT') };
    ok(!$@, 'is_signal_watched() causes no exceptions');
    ok($bool3, 'is_signal_watched() correctly returns that INT is being watched');
# }}}

# signals_watched_by_session {{{
    my %signals;
    eval { %signals = $api->signals_watched_by_session() };
    ok(!$@, 'signals_watched_by_session() causes no exceptions');
    ok(defined $signals{INT}, 'data returned from signals_watched_by_session() correctly indicates that INT is watched by this session');
    is($signals{INT}, 'sig_handler',  'data returned from signals_watched_by_session() indicates that INT is being watched by the correct event');
# }}}

# signal_watchers {{{
    my %watchers;
    eval { %watchers = $api->signal_watchers('INT'); };
    ok(!$@, 'signal_watchers() causes no exceptions');
    ok(scalar keys %watchers, "signal_watchers() returns data");
    ok(defined $watchers{ $sess }, "signal_watchers() notes that this session is watching INT");
    is($watchers{ $sess }, 'sig_handler', 'signal_watchers() notes that the proper event from this session is watching INT');
# }}}
   
# is_signal_watched_by_session {{{ 
    my $bool4;
    eval { $bool4 = $api->is_signal_watched_by_session('INT'); };
    ok(!$@, 'is_signal_watched_by_session() causes no exceptions');
    ok($bool4, 'is_signal_watched_by_sesion() correctly notes that this session is watching INT');
# }}}

}

sub sig_handler { }

sub _stop {


}
