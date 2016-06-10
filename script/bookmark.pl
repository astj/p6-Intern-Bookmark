#!/usr/bin/env perl6
use v6;

use Intern::Bookmark::DBI;
use Intern::Bookmark::Model::User;
use Intern::Bookmark::Model::Entry;
use Intern::Bookmark::Model::Bookmark;

my $dbh = Intern::Bookmark::DBI.connect-to-db;

sub get-or-create-user ($user-name --> Intern::Bookmark::Model::User) {
    my $row = do {
        my $sth = $dbh.prepare('SELECT user_id, name, created FROM user WHERE name = ?');
        $sth.execute($user-name);
        $sth.row(:hash);
    };
    unless $row {
        say "User not found: $user-name";

        $dbh.prepare('INSERT INTO user (name, created) VALUES (?, ?)').execute($user-name, DateTime.now);
        my $sth = $dbh.prepare('SELECT user_id, name, created FROM user WHERE user_id = LAST_INSERT_ID()');
        $sth.execute;
        $row = $sth.row(:hash);
    }
    return Intern::Bookmark::Model::User.new(|$row); # Not good way?
}

# Maybe[Entry]
sub find-entry-by-url ($url --> Intern::Bookmark::Model::Entry) {
    my $row = do {
        my $sth = $dbh.prepare('SELECT entry_id, url, title, created, updated FROM entry WHERE url = ?');
        $sth.execute($url);
        $sth.row(:hash);
    };
    return unless $row;
    return Intern::Bookmark::Model::Entry.new(|$row);
}

sub find-or-create-entry-by-url ($url --> Intern::Bookmark::Model::Entry) {
    my $entry = find-entry-by-url($url);

    return $entry // do {
        my $title = 'created by p6-intern-bookmark'; # TODO
        $dbh.prepare('INSERT INTO entry (url, title, created, updated) VALUES (?, ?, ?, ?)').execute($url, $title, DateTime.now, DateTime.now);
        my $sth = $dbh.prepare('SELECT entry_id, url, title, created, updated FROM entry WHERE entry_id = LAST_INSERT_ID()');
        $sth.execute;
        my $row = $sth.row(:hash);
        Intern::Bookmark::Model::Entry.new(|$row);
    };
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

sub find-entries (@entry-ids) {
    return unless @entry-ids.elems;

    # If @entry-ids has 5 elems, it should be '?, ?, ?, ?, ?'
    my $placeholder = @entry-ids.map({"?"}).join(", ");

    my $sth = $dbh.prepare('SELECT entry_id, url, title, created, updated FROM entry WHERE entry_id IN ( ' ~ $placeholder ~ ' )');
    $sth.execute(@entry-ids);

    my @entries = $sth.allrows(:array-of-hash).map({ Intern::Bookmark::Model::Entry.new(|$_) });
    return @entries;
}

sub find-entries-and-embed-to-bookmarks (@bookmarks) {
    my @entries = find-entries(@bookmarks.map({ $_.entry_id }));
    my %entries-by-entry-id = @entries.classify({ $_.entry_id });

    for @bookmarks -> $bookmark {
        $bookmark.entry = %entries-by-entry-id{$bookmark.entry_id}.first;
    }
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
