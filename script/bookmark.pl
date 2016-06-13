#!/usr/bin/env perl6
use v6;

use Intern::Bookmark::DBI;

use Intern::Bookmark::Service::Entry;
use Intern::Bookmark::Service::User;
use Intern::Bookmark::Service::Bookmark;

my $dbh = connect-to-db;

sub get-or-create-user ($user-name --> Intern::Bookmark::Model::User) {
    return Intern::Bookmark::Service::User.find-or-create($dbh, $user-name);
}

# -------------------------------------
#  MAIN
# -------------------------------------

# comment is optional!
multi MAIN($user-name, 'add', $url, $comment = '') {
    my $user = get-or-create-user($user-name);

    my $entry = Intern::Bookmark::Service::Entry.find-or-create-by-url($dbh, $url);
    my $bookmark =  Intern::Bookmark::Service::Bookmark.create-or-update(
        $dbh, :$user, :$entry, :$comment
    );

    say 'Bookmarked ' ~ $entry.url ~ ($comment.chars ?? (' with comment ' ~ $comment) !! '');
}

multi MAIN($user-name, 'list') {
    my $user = get-or-create-user($user-name);
    my @bookmarks = Intern::Bookmark::Service::Bookmark.search-by-user(
        $dbh, :$user
    );

    Intern::Bookmark::Service::Entry.search-by-ids-and-embed-to-bookmarks($dbh, @bookmarks);

    my constant $formatter = "%-30s\t%-25s\t%s";
    say sprintf($formatter,'url', 'created', 'comment');
    for @bookmarks -> $bookmark {
        say sprintf($formatter, $bookmark.entry.url, $bookmark.created.local, $bookmark.comment);
    }
}

multi MAIN($user-name, 'delete', $url) {
    my $user = get-or-create-user($user-name);

    my $entry = Intern::Bookmark::Service::Entry.find-by-url($dbh, $url);
    without $entry {
        say 'No entry found for' ~ $url;
        return;
    }

    my $bookmark = Intern::Bookmark::Service::Bookmark.find-by-user-and-entry(
        $dbh, :$user, :$entry
    );
    without $bookmark {
        say $user.name ~ '\'s bookmark for ' ~ $url ~ ' is not found.';
        return;
    }

    Intern::Bookmark::Service::Bookmark.delete-by-id(
        $dbh, :bookmark-id($bookmark.bookmark_id)
    );
    say 'Deleted ' ~ $user.name ~ '\'s bookmark for ' ~ $url;
}
