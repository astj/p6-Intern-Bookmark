use v6;

class Bookmark {
    has Str $.user-name;
    has Str $.url;
    has Str $.comment;
}

class User {
    has Str $.name;
    has @.bookmarks = ();

    method add_bookmark (:url($url), :comment($comment)) {
        my $bookmark = Bookmark.new(
            user-name => $!name,
            url       => $url,
            comment   => $comment,
        );

        @!bookmarks.push($bookmark);
        $bookmark;
    }
}

my $user1 = User.new(name => 'John');

# An instance of Bookmark
my $bookmark1 = $user1.add_bookmark(
    url     => 'http://developer.hatenastaff.com/',
    comment => 'benri',
);

say $bookmark1.comment; # benri

say $user1.bookmarks[0].url; # http://developer.hatenastaff.com/
