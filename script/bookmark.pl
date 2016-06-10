#!/usr/bin/env perl6
use v6;

use Intern::Bookmark::DBI;
use Intern::Bookmark::Model::User;
use Intern::Bookmark::Model::Entry;
use Intern::Bookmark::Model::Bookmark;

use Intern::Bookmark::Service::Entry;
use Intern::Bookmark::Service::User;

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
    my $sth = $dbh.prepare('
      SELECT bookmark_id, user_id, entry_id, comment, created, updated
             FROM bookmark
             WHERE user_id = ? AND entry_id = ?
    ');
    $sth.execute($user.user_id, $entry.entry_id);
    my $row = $sth.row(:hash);
    return unless $row;
    return Intern::Bookmark::Model::Bookmark.new(|$row);
}

sub create-or-update-bookmark (:user($user), :url($url), :comment($comment) --> Intern::Bookmark::Model::Bookmark) {
    my $entry = find-or-create-entry-by-url($url);
    $comment //= '';

    my $bookmark = find-bookmark(user => $user, entry => $entry);
    if ($bookmark) {
        my $sth = $dbh.prepare('
          UPDATE bookmark SET comment = ?, updated = ?
                 WHERE bookmark_id = ?
        ');
        $sth.execute($comment, DateTime.now, $bookmark.bookmark_id);
    } else {
        my $sth = $dbh.prepare('INSERT INTO bookmark (user_id, entry_id, comment, created, updated) VALUES (?, ?, ?, ?, ?)');
        $sth.execute($user.user_id, $entry.entry_id, $comment, DateTime.now, DateTime.now);
    }
    return find-bookmark(user => $user, entry => $entry);
}

sub delete-bookmark-by-id ($bookmark_id!) {
    my $sth = $dbh.prepare('DELETE FROM bookmark WHERE bookmark_id = ?');
    $sth.execute($bookmark_id);
}

sub find-bookmarks-for-user ($user) {
    my $sth = $dbh.prepare('SELECT * FROM bookmark WHERE user_id=?');
    $sth.execute($user.user_id);

    my @bookmarks = $sth.allrows(:array-of-hash).map({ Intern::Bookmark::Model::Bookmark.new(|$_) });
    return @bookmarks;
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
