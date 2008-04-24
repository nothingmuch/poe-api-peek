# $Id: Makefile.PL 615 2005-12-08 05:44:24Z sungo $

use inc::Module::Install;

name            ('POE-API-Peek');
author          ('Matt Cashner (sungo@pobox.com)');
version_from    ('VERSION');
license         ('bsd');

requires        ('perl' => 5.006001);
requires        ('POE'  => 0.38);
requires        ('Devel::Size');
requires        ('Test::More');

build_requires  ('Test::Distribution');
build_requires  ('Test::Pod::Coverage');


WriteAll();
