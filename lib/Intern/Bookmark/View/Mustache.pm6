unit class Intern::Bookmark::View::Mustache;

use Template::Mustache;

# /templates/
constant TEMPLATE-DIR = $?FILE.IO.parent.parent.parent.parent.parent.child('templates');

my $mustache = Template::Mustache.new(:from(TEMPLATE-DIR));

method render (Str $template-name, %args --> Str) {
    $mustache.render($template-name, %args, :!literal);
}
