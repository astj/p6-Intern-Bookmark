use v6;

unit class Intern::Bookmark::Service::Bookmark;

use Intern::Bookmark::Model::Bookmark;
need DBDish::Connection;

method find-by-user-and-entry (DBDish::Connection $dbh!, :$user, :$entry --> Intern::Bookmark::Model::Bookmark) {
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

method search-by-user (DBDish::Connection $dbh!, :$user!) {
    my $sth = $dbh.prepare('
      SELECT bookmark_id, user_id, entry_id, comment, created, updated
             FROM bookmark
              WHERE user_id= ?
    ');
    $sth.execute($user.user_id);

    my @bookmarks = $sth.allrows(:array-of-hash).map({ Intern::Bookmark::Model::Bookmark.new(|$_) });
    return @bookmarks;
}

method create-or-update (DBDish::Connection $dbh!, :$user!, :$entry!, Str :$comment = '' --> Intern::Bookmark::Model::Bookmark) {
    my $bookmark = self.find-by-user-and-entry($dbh, :$user, :$entry);
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
    return self.find-by-user-and-entry($dbh, :$user, :$entry);
}

method delete-by-id (DBDish::Connection $dbh!, Int :$bookmark-id) {
    my $sth = $dbh.prepare('DELETE FROM bookmark WHERE bookmark_id = ?');
    $sth.execute($bookmark-id);
}
