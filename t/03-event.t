
# Tests for event related code. See code block labeled "Event fun"

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
        dummy => sub {},

    },
    heap => { api => $api },
);

POE::Kernel->run();

###############################################

sub _start {
    my $sess = $_[SESSION];
    my $api = $_[HEAP]->{api};

# event_count_to {{{
    my $to_count;
    eval { $to_count = $api->event_count_to() };
    ok(!$@, "event_count_to() causes no exceptions");
    is($to_count, 0, 'event_count_to() returns proper count');
# }}}

# event_count_from {{{
    my $from_count;
    eval { $from_count = $api->event_count_from() };
    ok(!$@, "event_count_from() causes no exceptions");
    is($from_count, 0, 'event_count_from() returns proper count');
# }}}

# event_queue {{{
    my $queue;
    eval { $queue = $api->event_queue() };
    ok(!$@, "event_queue() causes no exceptions");
    my $ref = ref $queue;

    # work around a bug in POE::XS::Queue::Array. This will be fixed in the future.
    if( ($ref eq 'POE::Queue') or ($ref eq 'POE::XS::Queue::Array') ) {
        pass('event_queue() returns POE::Queue object');
    } else {
        fail('event_queue() returns POE::Queue object');
    }

# }}}

# event_queue_dump {{{
    if($POE::VERSION >= '0.31') {
        $_[KERNEL]->yield('dummy');

        my @queue;
        eval { @queue = $api->event_queue_dump() };
        ok(!$@, "event_queue_dump() causes no exceptions: $@");
        is(scalar @queue, 1, "event_queue_dump() returns the right number of items");

        my $item = $queue[0];
        is($item->{type}, 'User', 'event_queue_dump() item has proper type');
        is($item->{event}, 'dummy', 'event_queue_dump() item has proper event name');
        is($item->{source}, $item->{destination}, 'event_queue_dump() item has proper source and destination');
    } else {
        my @queue;
        eval { @queue = $api->event_queue_dump() };
        ok(!$@, "event_queue_dump() causes no exceptions: $@");
        is(scalar @queue, 1, "event_queue_dump() returns the right number of items");

        my $item = $queue[0];
        is($item->{type}, '_sigchld_poll', 'event_queue_dump() item has proper type');
        is($item->{event}, '_sigchld_poll', 'event_queue_dump() item has proper event name');
        is($item->{source}, $item->{destination}, 'event_queue_dump() item has proper source and destination');
    }
# }}}
    
}


sub _stop {


}
