use strict;
use warnings;

use lib qw( ../lib );

use Wcpancover;
use Wcpancover::DB::Schema;
use Wcpancover::Command::setup;

use Mojo::JSON qw(decode_json encode_json);

use Test::More;
END { done_testing(); }

use Test::Mojo;

my $db = Wcpancover::DB::Schema->connect('dbi:SQLite:dbname=:memory:');

Wcpancover::Command::setup->inject_sample_data($db);

ok($db->resultset('Package')->single({name => 'AproJo'}), 'DB package exists');



my $t = Test::Mojo->new(Wcpancover->new(db => $db));
$t->ua->max_redirects(2);

subtest 'Static File' => sub {

  $t->get_ok('/robots.txt')->status_is(200);

};

subtest 'Static page' => sub {

  # landing page
  $t->get_ok('/')->status_is(200)->text_is(h2 => 'Testpage for Cpancover');

  $t->get_ok('/front/index')->status_is(200)->text_is(h2 => 'Testpage for Cpancover');


  # attempt to get non-existant page
  $t->get_ok('/page/doesntexist')->status_is(404);

};

