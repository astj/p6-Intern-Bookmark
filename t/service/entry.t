use v6;
use Test;
use InternTest;

plan 8 + 8 + 5;

use Intern::Bookmark::Service::Entry;

use-ok('Intern::Bookmark::Service::Entry');

use Intern::Bookmark::DBI;
use Intern::Bookmark::Model::Bookmark;

my $dbh = connect-to-db;

my $url1 = 'http://' ~ random-strings-by-length(15) ~ '.com/' ~ random-strings-by-length(5);
my $url2 = 'http://' ~ random-strings-by-length(15) ~ '.com/' ~ random-strings-by-length(5);

##### find-by-url, find-or-create-by-url
my $entry-notfound = Intern::Bookmark::Service::Entry.find-by-url($dbh, $url1);
ok !$entry-notfound.defined;

my $entry1 = Intern::Bookmark::Service::Entry.find-or-create-by-url($dbh, $url1);
isa-ok $entry1, Intern::Bookmark::Model::Entry;
is $entry1.url, $url1;

my $entry1-again = Intern::Bookmark::Service::Entry.find-by-url($dbh, $url1);
isa-ok $entry1-again, Intern::Bookmark::Model::Entry;
is $entry1-again.url, $url1;

my $entry1-again2 = Intern::Bookmark::Service::Entry.find-or-create-by-url($dbh, $url1);
isa-ok $entry1-again2, Intern::Bookmark::Model::Entry;
is $entry1-again2.url, $url1;
is $entry1-again2.created, $entry1.created, 'created is the same';

#### search-by-ids
my @empty-entries = Intern::Bookmark::Service::Entry.search-by-ids($dbh, ());
is @empty-entries.elems, 0;

# XXX
$dbh.query("delete from entry where entry_id=99999");

my @notfound-entries = Intern::Bookmark::Service::Entry.search-by-ids($dbh, [99999]);
is @notfound-entries.elems, 0;

my @one-entries = Intern::Bookmark::Service::Entry.search-by-ids($dbh, ($entry1.entry_id, 99999));
is @one-entries.elems, 1;
is @one-entries[0].url, $url1;

my $entry2 = Intern::Bookmark::Service::Entry.find-or-create-by-url($dbh, $url2);

my @entries = Intern::Bookmark::Service::Entry.search-by-ids($dbh, ($entry1.entry_id, $entry2.entry_id));
is @entries.elems, 2;
is @entries[0].url, $url1;
is @entries[1].url, $url2;

#### search-by-ids-and-embed-to-bookmarks
my $bookmark1 = Intern::Bookmark::Model::Bookmark.new(entry_id => $entry1.entry_id);
my $bookmark2 = Intern::Bookmark::Model::Bookmark.new(entry_id => $entry2.entry_id);
my $bookmarkX = Intern::Bookmark::Model::Bookmark.new(entry_id => 999);

Intern::Bookmark::Service::Entry.search-by-ids-and-embed-to-bookmarks(
    $dbh, ($bookmark2, $bookmark1, $bookmarkX)
);

isa-ok  $bookmark1.entry, 'Intern::Bookmark::Model::Entry';
isa-ok  $bookmark2.entry, 'Intern::Bookmark::Model::Entry';
ok     !$bookmarkX.entry.defined;

is $bookmark1.entry.entry_id, $entry1.entry_id;
is $bookmark2.entry.entry_id, $entry2.entry_id;

$dbh.query("delete from entry where url='$url1'");
$dbh.query("delete from entry where url='$url2'");
