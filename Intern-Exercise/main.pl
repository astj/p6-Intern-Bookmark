use v6;

use Log;

my $log = Log.new(
    host    => '127.0.0.1',
    user    => 'frank',
    epoch   => 1372694390,
    req     => 'GET /apache_pb.gif HTTP/1.0',
    status  => 200,
    size    => 2326,
    referer => 'http://www.hatena.ne.jp/',
);
say $log.method;
say $log.path;
say $log.protocol;
say $log.uri;
say $log.time;
