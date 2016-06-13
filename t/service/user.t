use v6;
use Test;
use InternTest;

plan 6;

use Intern::Bookmark::Service::User;

use-ok('Intern::Bookmark::Service::User');

use Intern::Bookmark::DBI;

my $dbh = connect-to-db;

$dbh.query('delete from user where name="testuser"');

my $user = Intern::Bookmark::Service::User.find-or-create($dbh, 'testuser');
isa-ok $user, Intern::Bookmark::Model::User;
is $user.name, 'testuser';

my $user-again = Intern::Bookmark::Service::User.find-or-create($dbh, 'testuser');
isa-ok $user-again, Intern::Bookmark::Model::User;
is $user-again.name, 'testuser';
is $user-again.created, $user.created, 'created is the same';
