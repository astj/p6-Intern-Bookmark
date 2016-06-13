# p6-Intern-Bookmark (and Intern-Exercise)

Ref: https://github.com/hatena/perl-Intern-Bookmark

## setup

```
mysql -unobody -pnobody -e 'create database intern_bookmark;'
mysql -unobody -pnobody intern_bookmark < db/schema.sql
panda installdeps .
```

And for testing,

```
mysql -unobody -pnobody -e 'create database intern_bookmark_test;'
mysql -unobody -pnobody intern_bookmark_test < db/schema.sql
```

## CLI

```
perl6 -Ilib script/bookmark.pl
```

## Testing

```
prove --exec 'perl6 -Ilib -It/lib' -vr t
```

## See also

- Textbook: https://github.com/hatena/Hatena-Textbook
- Intern-Exercise: https://github.com/hatena/Hatena-Intern-Exercise2015
