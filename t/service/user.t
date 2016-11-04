use v6;
use Test;
use InternTest;

plan 9;

use Intern::Bookmark::Service::User;

use-ok('Intern::Bookmark::Service::User');

use Intern::Bookmark::DBI;

my $dbh = connect-to-db;

my $user-name = random-strings-by-length(15);

my $user = Intern::Bookmark::Service::User.find-or-create($dbh, $user-name);
isa-ok $user, Intern::Bookmark::Model::User;
is $user.name, $user-name;

my $user-again = Intern::Bookmark::Service::User.find-or-create($dbh, $user-name);
isa-ok $user-again, Intern::Bookmark::Model::User;
is $user-again.name, $user-name;
is $user-again.created, $user.created, 'created is the same';

$dbh.query("delete from user where name='$user-name'");

my $guest = Intern::Bookmark::Service::User.guest-user();
is $guest.name, "guest";
ok !$guest.user_id.defined;
ok !$guest.created.defined;
