#!/usr/bin/env perl6
use v6;

use Intern::Bookmark::DBI;
#use Intern::Bookmark::Model::User;
#use Intern::Bookmark::Model::Entry;
#use Intern::Bookmark::Model::Bookmark;

use Intern::Bookmark::Service::Entry;
use Intern::Bookmark::Service::User;
use Intern::Bookmark::Service::Bookmark;

my $dbh = Intern::Bookmark::DBI.connect-to-db;

sub get-or-create-user ($user-name --> Intern::Bookmark::Model::User) {
    return Intern::Bookmark::Service::User.find-or-create-user($dbh, $user-name);
}

# Maybe[Entry]
sub find-entry-by-url ($url --> Intern::Bookmark::Model::Entry) {
    return Intern::Bookmark::Service::Entry.find-entry-by-url($dbh, $url);
}

sub find-or-create-entry-by-url ($url --> Intern::Bookmark::Model::Entry) {
    return Intern::Bookmark::Service::Entry.find-or-create-entry-by-url($dbh, $url);
}

# Maybe[Bookmark]
sub find-bookmark (:user($user), :entry($entry) --> Intern::Bookmark::Model::Bookmark) {
    return Intern::Bookmark::Service::Bookmark.find-by-user-and-entry(
        $dbh, :$user, :$entry
    );
}

sub create-or-update-bookmark (:user($user), :url($url), :comment($comment) --> Intern::Bookmark::Model::Bookmark) {
    my $entry = find-or-create-entry-by-url($url);
    return Intern::Bookmark::Service::Bookmark.create-or-update(
        $dbh, :$user, :$entry, :$comment
    );
}

sub delete-bookmark-by-id ($bookmark-id!) {
    return Intern::Bookmark::Service::Bookmark.delete-by-id(
        $dbh, :$bookmark-id
    );
}

sub find-bookmarks-for-user ($user) {
    return Intern::Bookmark::Service::Bookmark.search-by-user(
        $dbh, :$user
    );
}

sub find-entries (@entry-ids where *.elems > 0) {
    return Intern::Bookmark::Service::Entry.find-entries($dbh, @entry-ids);
}

sub find-entries-and-embed-to-bookmarks (@bookmarks) {
    return Intern::Bookmark::Service::Entry.find-entries-and-embed-to-bookmarks($dbh, @bookmarks);
}

# -------------------------------------
#  MAIN
# -------------------------------------

# comment is optional!
multi MAIN($user-name, 'add', $url, $comment = '') {
    my $user = get-or-create-user($user-name);

    my $bookmark = create-or-update-bookmark(user => $user, url => $url, comment => $comment);
    my $entry = find-or-create-entry-by-url($url);

    say 'Bookmarked ' ~ $entry.url ~ ($comment.chars ?? (' with comment ' ~ $comment) !! '');
}

multi MAIN($user-name, 'list') {
    my $user = get-or-create-user($user-name);
    my @bookmarks = find-bookmarks-for-user($user);
    find-entries-and-embed-to-bookmarks(@bookmarks);

    my constant $formatter = "%-30s\t%-25s\t%s";
    say sprintf($formatter,'url', 'created', 'comment');
    for @bookmarks -> $bookmark {
        say sprintf($formatter, $bookmark.entry.url, $bookmark.created.local, $bookmark.comment);
    }
}

multi MAIN($user-name, 'delete', $url) {
    my $user = get-or-create-user($user-name);

    my $entry = find-entry-by-url($url);
    without $entry {
        say 'No entry found for' ~ $url;
        return;
    }

    my $bookmark = find-bookmark(user => $user, entry => $entry);
    without $bookmark {
        say $user.name ~ '\'s bookmark for ' ~ $url ~ ' is not found.';
        return;
    }

    delete-bookmark-by-id($bookmark.bookmark_id);
    say 'Deleted ' ~ $user.name ~ '\'s bookmark for ' ~ $url;
}
