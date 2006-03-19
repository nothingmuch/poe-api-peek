#!/usr/bin/perl

use warnings;
use strict;
use Test::More;

plan skip_all => 'No SIGNATURE file found' unless -s 'SIGNATURE';

eval "require Module::Signature";
plan skip_all => 'Module::Signature not found.' if $@;

eval { require Socket; Socket::inet_aton('pgp.mit.edu'); };
plan skip_all => 'Cannot connect to the keyserver' if $@;

plan tests => 1;

ok(Module::Signature::verify() == Module::Signature::SIGNATURE_OK(), "Signature check");


