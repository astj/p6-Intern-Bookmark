#!/usr/bin/env perl6
use v6;

use DBIish;
use Intern::Bookmark::Model::User;
use Intern::Bookmark::Model::Entry;
use Intern::Bookmark::Model::Bookmark;

my $dbh = DBIish.connect(
    'mysql',
    :host<localhost>,
    :port(3306),
    :database<intern_bookmark>,
    :user<nobody>,
    :password<nobody>,
    :RaiseError
);
$dbh.do('SET NAMES utf8mb4');

# refs: http://astj.hatenablog.com/entry/2016/06/10/234024
my $tz =  sprintf '%s%02d:%02d',
$*TZ < 0 ?? '-' !! '+',
($*TZ.abs / 60 / 60).floor,
($*TZ.abs / 60 % 60).floor;
$dbh.do("SET time_zone = '$tz'");

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
        $sth.row(:hash);
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
    say "hello";
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
