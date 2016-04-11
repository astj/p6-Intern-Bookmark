use v6;
use Test;

use Parser;

use-ok('Parser');

my $parser = Parser.new:
    :filename<./sample_data/log.ltsv>;
isa-ok $parser, 'Parser';

my @parsed = $parser.parse;

isa-ok @parsed[0], 'Log';
isa-ok @parsed[1], 'Log';
isa-ok @parsed[2], 'Log';

is-deeply @parsed[0].to-hash, {
    'status' => 200,
    'time' => '2013-07-01T15:59:50Z',
    'size' => 2326,
    'uri' => 'http://127.0.0.1/apache_pb.gif',
    'user' => 'frank',
    'method' => 'GET',
    'referer' => 'http://www.hatena.ne.jp/'
};

is-deeply @parsed[1].to-hash, {
    'status' => 200,
    'time' => '2013-07-02T19:46:30Z',
    'size' => 1234,
    'uri' => 'http://127.0.0.1/apache_pb.gif',
    'user' => 'john',
    'method' => 'GET',
    'referer' => 'http://b.hatena.ne.jp/hotentry'
};
is-deeply @parsed[2].to-hash, {
    'status' => 503,
    'time' => '2013-07-03T23:33:10Z',
    'method' => 'GET',
    'referer' => 'http://www.example.com/start.html',
    'size' => 9999,
    'uri' => 'http://127.0.0.1/apache_pb.gif'
};

dies-ok { Parser.new(:filename<./sample_data/NOT_FOUND.ltsv>).parse; };

done-testing();
