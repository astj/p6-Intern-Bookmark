unit class Intern::Bookmark::Web::Index;

use Crust::Request;
use Crust::Response;
use HTTP::Headers;
use Intern::Bookmark::Web::Response;
use Intern::Bookmark::View::Mustache;

method index (Crust::Request $req!, %match --> Crust::Response) {
    my $body = Intern::Bookmark::View::Mustache.render('index', {:message<Hello, Mustache>});
    Intern::Bookmark::Web::Response.html-response($body);
}
