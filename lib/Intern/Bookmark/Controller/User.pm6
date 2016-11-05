unit class Intern::Bookmark::Controller::User;

use Crust::Request;
use Crust::Response;
use Intern::Bookmark::Service::User;
use Intern::Bookmark::Web::Response;
use Intern::Bookmark::View::Mustache;
use Intern::Bookmark::Web::Helper;
use Intern::Bookmark::DBI;

method login (Crust::Request $req!, %match --> Intern::Bookmark::Web::Response) {
    given $req.method {
        when 'GET'  { self.login_form($req, %match); }
        when 'POST' { self.do_login($req, %match); }
    }
}

method login_form (Crust::Request $req!, %match --> Intern::Bookmark::Web::Response) {
    my $dbh = connect-to-db;
    my $visitor = visitor($req, $dbh);

    my $body = Intern::Bookmark::View::Mustache.render(
        'login', {}
    );
    Intern::Bookmark::Web::Response.html-response($body);
}

method do_login (Crust::Request $req!, %match --> Intern::Bookmark::Web::Response) {
    my $dbh = connect-to-db;

    my $user-name = $req.body-parameters<name>;
    return Intern::Bookmark::Web::Response.error-response(400, 'name required') unless $user-name.defined;

    # XXX This is NoAuth!
    my $user = Intern::Bookmark::Service::User.find-or-create($dbh, $user-name);
    $req.session.set('username', $user-name);

    Intern::Bookmark::Web::Response.redirect-response(303, '/');
}
