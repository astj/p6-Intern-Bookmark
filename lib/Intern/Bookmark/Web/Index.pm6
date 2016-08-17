unit class Intern::Bookmark::Web::Index;

use Crust::Request;
use Crust::Response;
use HTTP::Headers;
use Intern::Bookmark::Web::Response;
use Intern::Bookmark::View::Mustache;
use Intern::Bookmark::Web::Helper;
use Intern::Bookmark::DBI;

method index (Crust::Request $req!, %match --> Intern::Bookmark::Web::Response) {
    my $dbh = connect-to-db;
    my $visitor = visitor($req, $dbh);

    my $body = Intern::Bookmark::View::Mustache.render(
        'index',
        {:visitor($visitor.as-hash), :message<Hello, Mustache>}
    );
    Intern::Bookmark::Web::Response.html-response($body);
}
