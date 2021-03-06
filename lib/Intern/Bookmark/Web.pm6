unit module Intern::Bookmark::Web;

use Crust::Builder;
use Crust::Middleware::Session;
use Crust::Request;
use Crust::Response;
use Router::Boost;
use Intern::Bookmark::Web::Response;
use MONKEY-SEE-NO-EVAL;

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
    $router.add('/',          ['Intern::Bookmark::Controller::Index',    'index']);
    $router.add('/login',     ['Intern::Bookmark::Controller::User',     'login']);
    $router.add('/bookmarks', ['Intern::Bookmark::Controller::Bookmark', 'list']);
    $router;
}();

sub intern-bookmark-web-psgi is export {
    my $app = -> $env {
        my $req = Crust::Request.new($env);
        handle-request($req).finalize
    };

    my $store = Crust::Middleware::Session::Store::Memory.new();

    builder {
        enable "AccessLog", format => "combined";
        enable "ContentLength";
        enable 'Session', :store($store), :cookie-name("intern_bookmark_session");
        $app;
    };
}

sub handle-request (Crust::Request $req! --> Crust::Response) {
    my $match = ROUTER.match($req.path-info);

    without $match<stuff> {
        return Intern::Bookmark::Web::Exception.notfound($req);
    }

    my ($package, $method) = $match<stuff>;
    # FIXME: https://rt.perl.org/Public/Bug/Display.html?id=130535
    # related: https://github.com/tokuhirom/p6-Crust/pull/85
    EVAL "use $package"; # maybe this runtime load is SO slow

    # To modify headers, Intern::Bookmark::Web::Response is necessary
    my Intern::Bookmark::Web::Response $res = ::($package)."$method"($req, $match<captured>);
    $res.headers.field(:X-Dispatch( $package ~ '#' ~ $method));

    $res.crustify;
}
