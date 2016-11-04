use v6;

unit class Intern::Bookmark::Service::User;

use Intern::Bookmark::Model::User;
need DBDish::Connection;

method find-or-create(DBDish::Connection $dbh!, Str $user-name! --> Intern::Bookmark::Model::User) {
    my $row = $dbh.retrieve-row(
        'SELECT user_id, name, created FROM user WHERE name = ?',
        $user-name
    );
    unless $row {
        $dbh.query('INSERT INTO user (name, created) VALUES (?, ?)', $user-name, DateTime.now);
        $row = $dbh.retrieve-row('SELECT user_id, name, created FROM user WHERE user_id = LAST_INSERT_ID()');
    }
    return Intern::Bookmark::Model::User.new(|$row); # Not good way?
}

method guest-user(--> Intern::Bookmark::Model::User) {
    Intern::Bookmark::Model::User.new(:name<guest>);
}
