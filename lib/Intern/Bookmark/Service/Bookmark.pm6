use v6;

unit class Intern::Bookmark::Service::Bookmark;

use Intern::Bookmark::Model::Bookmark;
need DBDish::Connection;

method find-by-user-and-entry (DBDish::Connection $dbh!, :$user, :$entry --> Intern::Bookmark::Model::Bookmark) {
    my $row = $dbh.retrieve-row(
        'SELECT bookmark_id, user_id, entry_id, comment, created, updated
                FROM bookmark
                WHERE user_id = ? AND entry_id = ?',
        { user_id => $user.user_id, entry_id => $entry.entry_id }
    );
    return unless $row;
    return Intern::Bookmark::Model::Bookmark.new(|$row);
}

method search-by-user (DBDish::Connection $dbh!, :$user!) {
    return $dbh.retrieve-allrows(
        'SELECT bookmark_id, user_id, entry_id, comment, created, updated
               FROM bookmark
               WHERE user_id = ?',
        $user.user_id
    ).map({ Intern::Bookmark::Model::Bookmark.new(|$_) });
}

method create-or-update (DBDish::Connection $dbh!, :$user!, :$entry!, Str :$comment = '' --> Intern::Bookmark::Model::Bookmark) {
    my $bookmark = self.find-by-user-and-entry($dbh, :$user, :$entry);
    if ($bookmark) {
        $dbh.query(
            'UPDATE bookmark SET comment = ?, updated = ?
                    WHERE bookmark_id = ?',
            $comment, DateTime.now, $bookmark.bookmark_id
        );
    } else {
        $dbh.query(
            'INSERT INTO bookmark (user_id, entry_id, comment, created, updated)
                         VALUES (?, ?, ?, ?, ?)',
            $user.user_id, $entry.entry_id, $comment, DateTime.now, DateTime.now
        );
    }
    return self.find-by-user-and-entry($dbh, :$user, :$entry);
}

method delete-by-id (DBDish::Connection $dbh!, Int :$bookmark-id) {
    $dbh.query('DELETE FROM bookmark WHERE bookmark_id = ?', $bookmark-id);
}
