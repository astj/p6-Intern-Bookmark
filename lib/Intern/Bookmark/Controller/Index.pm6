unit class Intern::Bookmark::Controller::Index;

need Crust::Request;
use Intern::Bookmark::Web::Response;
use Intern::Bookmark::View::Template6;
use Intern::Bookmark::Web::Helper;
use Intern::Bookmark::DBI;

method index (Crust::Request $req!, %match --> Intern::Bookmark::Web::Response) {
    my $dbh = connect-to-db;
    my $visitor = visitor($req, $dbh);

    my $visitor-hash = do given $visitor {
        when Intern::Bookmark::Model::User { .as-hash }
        default { Nil }
    }
    my $body = Intern::Bookmark::View::Template6.render(
        'index',
        {:visitor($visitor-hash), :message<Hello, Template>}
    );
    Intern::Bookmark::Web::Response.html-response($body);
}
