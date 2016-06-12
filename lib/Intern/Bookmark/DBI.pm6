use v6;
unit class Intern::Bookmark::DBI;
use DBIish;
use Intern::Bookmark::Config;

method connect-to-db ( --> DBDish::Connection) {
    my %db-config = config-param('db');
    my $dbh = DBIish.connect(
        'mysql',
        :host(%db-config<host>),
        :port(%db-config<port>),
        :database(%db-config<database>),
        :user(%db-config<user>),
        :password(%db-config<password>),
        :RaiseError
    );
    $dbh.do('SET NAMES utf8mb4');

    # ensure timezone is same as local
    # refs: http://astj.hatenablog.com/entry/2016/06/10/234024
    my $tz = self.timezone-from-offset($*TZ);
    $dbh.do("SET time_zone = '$tz'");

    $dbh;
}

method timezone-from-offset (Int $offset --> Str) {
    sprintf '%s%02d:%02d',
    $offset < 0 ?? '-' !! '+',
    ($offset.abs / 60 / 60).floor,
    ($offset.abs / 60 % 60).floor;
}
