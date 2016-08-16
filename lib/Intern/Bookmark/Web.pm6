unit module Intern::Bookmark::Web;

use Crust::Request;
use Crust::Response;
use Router::Boost;

my class Intern::Bookmark::Web::Exception {
    method notfound (Crust::Request $req! --> Crust::Response) {
        Crust::Response.new(
            :status(404),
            :headers([]),
            :body(["Requested URI " ~ $req.uri ~ " is not found\n"])
        );
    }
}

constant ROUTER = {
    my $router = Router::Boost.new();
    $router.add('/',    ['Intern::Bookmark::Web::Index', 'index']);
    $router;
}();

sub intern-bookmark-web-psgi (--> Block) is export {
    -> $env {
        my $req = Crust::Request.new($env);
        handle_request($req).finalize
    };
}

sub handle_request (Crust::Request $req! --> Crust::Response) {
    my $match = ROUTER.match($req.path-info);

    without $match<stuff> {
        return Intern::Bookmark::Web::Exception.notfound($req);
    }

    my ($package, $method) = $match<stuff>;
    require ::($package); # maybe this runtime load is SO slow
    return ::($package)."$method"($req, $match<captured>);
}
