unit class Intern::Bookmark::Web::Index;

use Crust::Request;
use Crust::Response;
use HTTP::Headers;
use Intern::Bookmark::Web::Response;

method index (Crust::Request $req!, %match --> Crust::Response) {
    my $res = Intern::Bookmark::Web::Response.new(
        :status(200),
        :body(["this is dispatched engine\n"])
    );
    $res.headers.Content-Type = 'text/plain';

    return $res;
}
