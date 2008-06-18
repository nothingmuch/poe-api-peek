
# Tests for session related api. see code block marked "Session fun".

use Test::More tests => 37;

use warnings;
use strict;
use POE;
use Data::Dumper;

use_ok('POE::API::Peek');

my $api = POE::API::Peek->new();

POE::Session->create(
	inline_states => {
		_start => \&_start,
		_stop => sub {},
		stub => sub {},
	},
	heap => { api => $api },
);

POE::Kernel->run();

###############################################

sub _start {
	my $sess = $_[SESSION];
	my $api = $_[HEAP]->{api};
	my $cur_sess;

# current_session() {{{
	eval { $cur_sess = $api->current_session() };
	ok(!$@, "current_session() causes no execeptions");
	ok(defined $cur_sess, "current_session() returns something");
	is(ref $cur_sess, 'POE::Session', 'current_session() returns a POE::Session object');
	is($cur_sess, $sess, "current_session() returns the RIGHT POE::Session object");        
# }}}

# resolve_session_to_id {{{
	my $id;
	eval { $id = $api->resolve_session_to_id() };
	ok(!$@, "resolve_session_to_id() causes no exceptions");
	is($id, $sess->ID, "resolve_session_to_id() returns the proper id");
# }}}

# resolve_session_to_ref {{{
	my $tmp_sess;
	eval { $tmp_sess = $api->resolve_session_to_ref($id); };
	ok(!$@, "resolve_session_to_ref() causes no exceptions");
	is(ref $tmp_sess, 'POE::Session', 'resolve_session_to_ref() returns a POE::Session object');
	is($tmp_sess, $sess, "resolve_session_to_ref() returns the RIGHT POE::Session object");        
# }}}

# get_session_refcount {{{
	my $refcnt;
	eval { $refcnt = $api->get_session_refcount(); };
	ok(!$@, "get_session_refcount() causes no exceptions.");
	ok(defined $refcnt, "get_session_refcount() returns data");
	is($refcnt, 0, "get_session_refcount() returned the proper count");
# }}}

# session_count {{{
	my $count;
	eval { $count = $api->session_count(); };
	ok(!$@, "session_count() causes no exceptions.");
	ok(defined $count, "session_count() returns data.");
	is($count, 2, "session_count() returns the proper count");
#}}}

# get_session_children {{{

	my @children;
	eval { @children = $api->get_session_children(); };
	ok(!$@, "get_session_children() causes no exceptions.");  
	is(scalar @children, 0, "get_session_children() returns the proper data when there are no children");

	POE::Session->create(
		inline_states => {
			_start => sub {
				my $bool;
				eval { $bool = $api->is_session_child($sess) };
				ok(!$@, 'is_session_child() causes no exceptions');
				ok($bool, 'is_session_child() correctly determined parentage of session'); 
			},
			_stop => sub {},
		}
	);
    
	@children = ();
	eval { @children = $api->get_session_children(); };
	ok(!$@, "get_session_children() causes no exceptions.");  
	is(scalar @children, 1, "get_session_children() returns the proper data when there is a child session");
	is(ref $children[0], 'POE::Session', "data returned from get_session_children() contains a valid child session reference");

# }}}

# get_session_parent {{{

	my $parent = eval { $api->get_session_parent };
	ok(!$@, "get_session_parent() causes no exceptions.");
	ok($parent, "parent returned");
	is($parent, $poe_kernel, "our parent is the kernel");

# }}}

# session_memory_size {{{
	my $size;
	eval { $size = $api->session_memory_size() };
	ok(!$@, "session_memory_size() causes no exceptions");

	# we can't really test this value much since its going to be different on 
	# every system, and even between runs

	ok(defined $size, "session_memory_size() returns data");
	ok($size > 0, "session_memory_size() returns non-zero value");

	my $new_size;

	# we grab the size again because Devel::Size adds a bit of new memory to the
	# session when we call total_size the first time.
	eval { 
		$size = $api->session_memory_size($cur_sess);
		$new_size = $api->session_memory_size($cur_sess) 
	};
	ok(!$@, "session_memory_size() causes no exceptions");


	ok(defined $new_size, "session_memory_size() returns data");
	ok($new_size > 0, "session_memory_size() returns non-zero value");
	is($new_size, $size, "session_memory_size: memory size matches between runs");
# }}}

# session_event_list {{{
	my @events;
	eval { @events = $api->session_event_list() };
	ok(!$@, "session_event_list() causes no exceptions");

	ok(scalar @events, "session_event_list() returns data");
	ok(scalar @events > 0, "session_event_list() returns more than one value");


	is_deeply(\@events, [ '_start','_stop','stub' ], "session_event_list() returns correct list of events");

# }}}

}



