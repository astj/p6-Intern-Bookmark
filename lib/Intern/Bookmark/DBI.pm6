use v6;
unit module Intern::Bookmark::DBI;
use DBIish;
use Intern::Bookmark::Config;

# This role will be injected into DBDish connection!
role ExtendedDBDishConnection {
    method query(Str $statement, *@param --> DBDish::StatementHandle) {
        my $sth = self.prepare($statement);
        $sth.execute(@param);
        $sth;
    }

    method retrieve-row(Str $statement, *@param --> Hash) {
        my $sth = self.query($statement, @param);
        return $sth.row(:hash);
    }

    method retrieve-allrows(Str $statement, *@param --> Seq) {
        my $sth = self.query($statement, @param);
        return $sth.allrows(:array-of-hash);
    }
}

sub connect-to-db ( --> DBDish::Connection) is export {
    my %db-config = config-param('db');
    my $dbh = DBIish.connect(
        'mysql',
        :host(%db-config<host>),
        :port(%db-config<port>),
        :database(%db-config<database>),
        :user(%db-config<user>),
        :password(%db-config<password>),
        :RaiseError
    ) but ExtendedDBDishConnection;
    $dbh.do('SET NAMES utf8mb4');

    # ensure timezone is same as local
    # refs: http://astj.hatenablog.com/entry/2016/06/10/234024
    my $tz = timezone-from-offset($*TZ);
    $dbh.do("SET time_zone = '$tz'");

    $dbh;
}

sub timezone-from-offset (Int $offset --> Str) {
    sprintf '%s%02d:%02d',
    $offset < 0 ?? '-' !! '+',
    ($offset.abs / 60 / 60).floor,
    ($offset.abs / 60 % 60).floor;
}
