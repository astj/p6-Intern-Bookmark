unit class Intern::Bookmark::View::Template6;

use Template6;

# /templates/
constant TEMPLATE-DIR = $?FILE.IO.parent.parent.parent.parent.parent.child('templates');

my $t6 = Template6.new;
$t6.add-path: TEMPLATE-DIR;

method render(Str $template-name, %args --> Str) {
    $t6.process($template-name, |%args);
}
