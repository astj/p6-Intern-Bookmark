use v6;

unit class Intern::Bookmark::Service::Entry;

use Intern::Bookmark::Model::Entry;
need DBDish::Connection;

method find-by-url(DBDish::Connection $dbh!, Str $url! --> Intern::Bookmark::Model::Entry) {
    my $row = $dbh.retrieve-row('SELECT entry_id, url, title, created, updated FROM entry WHERE url = ?', $url);
    return unless $row;
    return Intern::Bookmark::Model::Entry.new(|$row);
}

method find-or-create-by-url(DBDish::Connection $dbh!, Str $url! --> Intern::Bookmark::Model::Entry) {
    my $entry = self.find-by-url($dbh, $url);

    return $entry // do {
        my $title = 'created by p6-intern-bookmark'; # TODO
        $dbh.query(
            'INSERT INTO entry (url, title, created, updated) VALUES (?, ?, ?, ?)',
            $url, $title, DateTime.now, DateTime.now
        );
        my $row = $dbh.retrieve-row('SELECT entry_id, url, title, created, updated FROM entry WHERE entry_id = LAST_INSERT_ID()');
        Intern::Bookmark::Model::Entry.new(|$row);
    };
}

method search-by-ids (DBDish::Connection $dbh!, @entry-ids!) {
    return [] unless @entry-ids.elems;

    # If @entry-ids has 5 elems, it should be '?, ?, ?, ?, ?'
    my $placeholder = @entry-ids.map({"?"}).join(", ");
    return $dbh.retrieve-allrows(
        'SELECT entry_id, url, title, created, updated FROM entry WHERE entry_id IN ( :entry_id )',
        {:entry_id(@entry-ids)}
    ).map({ Intern::Bookmark::Model::Entry.new(|$_) });
}

method search-by-ids-and-embed-to-bookmarks (DBDish::Connection $dbh!, @bookmarks!) {
    my @entries = self.search-by-ids($dbh, @bookmarks.map({ $_.entry_id }));
    my %entries-by-entry-id = @entries.classify({ $_.entry_id });

    for @bookmarks -> $bookmark {
        my $entry = %entries-by-entry-id{$bookmark.entry_id}.first;
        $bookmark.entry = $entry if $entry.defined;
    }
}
