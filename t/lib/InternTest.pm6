use v6;

unit module InternTest;

BEGIN {
    %*ENV<INTERN_BOOKMARK_ENV> = 'test';
}

# XXX I miss String::Random ...

# 0-9a-zA-Z
my constant RANDOM-STRING-SOURCE = (0x30..0x39,0x41..0x5a,0x61..0x7a).flat.list;

sub random-strings-by-length (Int $len --> Str) is export {
    (1..$len).map({ RANDOM-STRING-SOURCE[ RANDOM-STRING-SOURCE.elems.rand.floor ].chr }).join;
}

sub random-url (--> Str) is export {
    'http://' ~ random-strings-by-length(15) ~ '.com/' ~ random-strings-by-length(5)
}
