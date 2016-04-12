use v6;
use Test;

plan 12;

use Log;

use-ok('Log');

my $log = Log.new(
    host    => '127.0.0.1',
    user    => 'frank',
    epoch   => 1372694390,
    req     => 'GET /apache_pb.gif HTTP/1.0',
    status  => 200,
    size    => 2326,
    referer => 'http://www.hatena.ne.jp/',
);

is $log.method, 'GET';
is $log.path, '/apache_pb.gif';
is $log.protocol, 'HTTP/1.0';
is $log.uri, 'http://127.0.0.1/apache_pb.gif';
is $log.time, '2013-07-01T15:59:50Z'; # last `Z` is not present p5's DateTime
is $log.display-user-name, 'frank';

is-deeply $log.to-hash, {
    user     => 'frank',
    status   => 200,
    size     => 2326,
    referer  => 'http://www.hatena.ne.jp/',
    method   => 'GET',
    uri      => 'http://127.0.0.1/apache_pb.gif',
    time     => '2013-07-01T15:59:50Z',
};

my $log-with-less-args = Log.new(
    host    => '127.0.0.1',
    epoch   => 1372694390,
    req     => 'GET /apache_pb.gif HTTP/1.0',
    status  => 200,
    size    => 2326,
);

is $log-with-less-args.display-user-name, 'guest';
is-deeply $log-with-less-args.to-hash, {
    status   => 200,
    size     => 2326,
    method   => 'GET',
    uri      => 'http://127.0.0.1/apache_pb.gif',
    time     => '2013-07-01T15:59:50Z',
};

ok Log.new(
    host    => '127.0.0.1',
    epoch   => 1372694390,
    req     => 'GET /apache_pb.gif HTTP/1.0',
    status  => 200,
    size    => 2326,
) eqv Log.new(
    host    => '127.0.0.1',
    epoch   => 1372694390,
    req     => 'GET /apache_pb.gif HTTP/1.0',
    status  => 200,
    size    => 2326,
);

ok Log.new(
    host    => '127.0.0.1',
    epoch   => 1372694392,
    req     => 'GET /apache_pb.gif HTTP/1.0',
    status  => 200,
    size    => 2326,
) !eqv Log.new(
    host    => '127.0.0.1',
    epoch   => 1372694390,
    req     => 'GET /apache_pb.gif HTTP/1.0',
    status  => 200,
    size    => 2326,
);
