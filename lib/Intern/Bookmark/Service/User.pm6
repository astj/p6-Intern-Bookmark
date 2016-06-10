use v6;

unit class Intern::Bookmark::Service::User;

use Intern::Bookmark::Model::User;
need DBDish::Connection;

method find-or-create-user(DBDish::Connection $dbh!, Str $user-name! --> Intern::Bookmark::Model::User) {
    my $row = do {
        my $sth = $dbh.prepare('SELECT user_id, name, created FROM user WHERE name = ?');
        $sth.execute($user-name);
        $sth.row(:hash);
    };
    unless $row {
        $dbh.prepare('INSERT INTO user (name, created) VALUES (?, ?)').execute($user-name, DateTime.now);
        my $sth = $dbh.prepare('SELECT user_id, name, created FROM user WHERE user_id = LAST_INSERT_ID()');
        $sth.execute;
        $row = $sth.row(:hash);
    }
    return Intern::Bookmark::Model::User.new(|$row); # Not good way?
}
