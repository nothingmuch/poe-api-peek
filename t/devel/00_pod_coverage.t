
use Test::More tests => 1;
use Pod::Coverage;
my $pc = Pod::Coverage->new(package => 'POE::API::Peek');
ok($pc->coverage > 0.75, 'POD Coverage is greater than 75% (is '.($pc->coverage*100).'%)');
