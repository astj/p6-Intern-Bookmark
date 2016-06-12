use v6;

unit module Intern::Bookmark::Config;

use YAMLish;

my %config-declaretions;
my %common-config;

# /config/
constant CONFIG-DIR = $?FILE.IO.parent.parent.parent.parent.child('config');
constant CONFIG-ENV-NAME = 'INTERN_BOOKMARK_ENV';

my $config-env = %*ENV{CONFIG-ENV-NAME};

# TODO: support inheritance using some key like `parent`...
my $config = sub {
    my $default = CONFIG-DIR.child('default.yml');
    without $config-env {
        die sprintf('%s is empty and default config file %s is not found!', CONFIG-ENV-NAME, $default.path) unless $default.e;
        return load-yaml($default.slurp);
    }

    my $file = CONFIG-DIR.child($config-env ~ '.yml');
    die sprintf('config file %s is not found!', $file.path, $config-env) unless $file.e;
    return load-yaml($file.slurp);
}();

sub config-param (Str $key) is export {
    die "config '$key' is not found!" without $config{$key};
    return $config{$key};
}

