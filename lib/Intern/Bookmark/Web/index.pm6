unit class Intern::Bookmark::Web::Index;

use Crust::Request;
use Crust::Response;

method index (Crust::Request $req!, %match --> Crust::Response) {
    Crust::Response.new(
        :status(200),
        :headers([]),
        :body(["this is dispatched engine\n"])
    );
}
