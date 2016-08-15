use v6;
use Test;
use InternTest;

plan 1 + 5 + 4 + 1;

use Intern::Bookmark::Service::Bookmark;

use-ok('Intern::Bookmark::Service::Bookmark');

use Intern::Bookmark::DBI;

use Intern::Bookmark::Service::Entry;
use Intern::Bookmark::Service::User;

my $dbh = connect-to-db;

### assets
my $url1 = random-url;
my $url2 = random-url;
## TODO: define some test factory method??
my $entry1 = Intern::Bookmark::Service::Entry.find-or-create-by-url($dbh, $url1);
my $entry2 = Intern::Bookmark::Service::Entry.find-or-create-by-url($dbh, $url2);
my $user1 = Intern::Bookmark::Service::User.find-or-create($dbh, random-strings-by-length(10));
my $user2 = Intern::Bookmark::Service::User.find-or-create($dbh, random-strings-by-length(10));

#### find-by-user-and-entry, create-or-update, delete-by-id
my $bookmark-notfound = Intern::Bookmark::Service::Bookmark.find-by-user-and-entry(
    $dbh, :user($user1), :entry($entry1)
);
ok !$bookmark-notfound.defined;

my $bookmark1-without-comment = Intern::Bookmark::Service::Bookmark.create-or-update(
    $dbh, :user($user1), :entry($entry1)
);
ok $bookmark1-without-comment;
is $bookmark1-without-comment.user_id, $user1.user_id;
is $bookmark1-without-comment.entry_id, $entry1.entry_id;
is $bookmark1-without-comment.comment, '', 'default comment is empty';

my $bookmark2 = Intern::Bookmark::Service::Bookmark.create-or-update(
    $dbh, :user($user2), :entry($entry1)
);
Intern::Bookmark::Service::Bookmark.delete-by-id($dbh, :bookmark-id($bookmark2.bookmark_id));

my $bookmark2-notfound-anymore = Intern::Bookmark::Service::Bookmark.find-by-user-and-entry(
    $dbh, :user($user2), :entry($entry2)
);
ok !$bookmark2-notfound-anymore.defined;

sleep 1; # ensure `created` will change

# update with comment
my $comment1 = random-strings-by-length(20);
my $bookmark1-with-comment = Intern::Bookmark::Service::Bookmark.create-or-update(
    $dbh, :user($user1), :entry($entry1), :comment($comment1)
);
ok $bookmark1-with-comment;
is $bookmark1-with-comment.comment, $comment1;
is $bookmark1-with-comment.created, $bookmark1-without-comment.created, 'created is same';
cmp-ok $bookmark1-with-comment.updated, '>', $bookmark1-with-comment.created, 'updated!';


$dbh.query("delete from entry where url='$url1'");
$dbh.query("delete from entry where url='$url2'");
$dbh.query("delete from bookmark where entry_id='$entry1.entry_id'");
$dbh.query("delete from user where user_id='$user1.user_id'");
$dbh.query("delete from user where user_id='$user2.user_id'");
