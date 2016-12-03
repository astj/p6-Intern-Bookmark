unit class Intern::Bookmark::Controller::Bookmark;

need Crust::Request;
use Intern::Bookmark::Service::Bookmark;
use Intern::Bookmark::Service::Entry;
use Intern::Bookmark::Web::Response;
use Intern::Bookmark::View::Template6;
use Intern::Bookmark::Web::Helper;
use Intern::Bookmark::DBI;

method list (Crust::Request $req!, %match --> Intern::Bookmark::Web::Response) {
    given $req.method {
        when 'GET' { self.do_list($req, %match); }
        default    { Intern::Bookmark::Web::Response.error-response(405); }
    }
}

method do_list (Crust::Request $req!, %match --> Intern::Bookmark::Web::Response) {
    my $dbh = connect-to-db;
    my $visitor = visitor($req, $dbh);

    # TODO redirect to login page?
    return Intern::Bookmark::Web::Response.error-response(403, 'Login required') unless $visitor;

    my $bookmarks = Intern::Bookmark::Service::Bookmark.search-by-user($dbh, :user($visitor));
    Intern::Bookmark::Service::Entry.search-by-ids-and-embed-to-bookmarks($dbh, $bookmarks);

    my $body = Intern::Bookmark::View::Template6.render(
        'bookmarks', { bookmarks => $bookmarks }
    );
    Intern::Bookmark::Web::Response.html-response($body);
}
