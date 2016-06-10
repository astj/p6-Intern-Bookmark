use v6;

unit class Intern::Bookmark::Service::Entry;

use Intern::Bookmark::Model::Entry;
need DBDish::Connection;

method find-entry-by-url(DBDish::Connection $dbh!, Str $url! --> Intern::Bookmark::Model::Entry) {
    my $row = do {
        my $sth = $dbh.prepare('SELECT entry_id, url, title, created, updated FROM entry WHERE url = ?');
        $sth.execute($url);
        $sth.row(:hash);
    };
    return unless $row;
    return Intern::Bookmark::Model::Entry.new(|$row);
}

method find-or-create-entry-by-url(DBDish::Connection $dbh!, Str $url! --> Intern::Bookmark::Model::Entry) {
    my $entry = self.find-entry-by-url($dbh, $url);

    return $entry // do {
        my $title = 'created by p6-intern-bookmark'; # TODO
        $dbh.prepare('INSERT INTO entry (url, title, created, updated) VALUES (?, ?, ?, ?)').execute($url, $title, DateTime.now, DateTime.now);
        my $sth = $dbh.prepare('SELECT entry_id, url, title, created, updated FROM entry WHERE entry_id = LAST_INSERT_ID()');
        $sth.execute;
        my $row = $sth.row(:hash);
        Intern::Bookmark::Model::Entry.new(|$row);
    };
}

method find-entries (DBDish::Connection $dbh!, @entry-ids! where *.elems > 0) {
    # If @entry-ids has 5 elems, it should be '?, ?, ?, ?, ?'
    my $placeholder = @entry-ids.map({"?"}).join(", ");
    my $sth = $dbh.prepare('SELECT entry_id, url, title, created, updated FROM entry WHERE entry_id IN ( ' ~ $placeholder ~ ' )');
    $sth.execute(@entry-ids);

    my @entries = $sth.allrows(:array-of-hash).map({ Intern::Bookmark::Model::Entry.new(|$_) });
    return @entries;
}

method find-entries-and-embed-to-bookmarks (DBDish::Connection $dbh!, @bookmarks! where *.elems > 0) {
    my @entries = self.find-entries($dbh, @bookmarks.map({ $_.entry_id }));
    my %entries-by-entry-id = @entries.classify({ $_.entry_id });

    for @bookmarks -> $bookmark {
        $bookmark.entry = %entries-by-entry-id{$bookmark.entry_id}.first;
    }
}
