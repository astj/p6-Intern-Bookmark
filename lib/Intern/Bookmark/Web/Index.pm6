unit class Intern::Bookmark::Web::Index;

use Crust::Request;
use Crust::Response;
use HTTP::Headers;
use Intern::Bookmark::Web::Response;

method index (Crust::Request $req!, %match --> Crust::Response) {
    Intern::Bookmark::Web::Response.text-response("this is dispatched engine\n");
}
