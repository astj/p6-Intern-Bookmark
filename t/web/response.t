use v6;
use Test;
use InternTest;

use Intern::Bookmark::Web::Response;
use HTTP::Headers;
use Crust::Response;

use-ok('Intern::Bookmark::Web::Response');

# basic
{
    my $headers = HTTP::Headers.new;
    $headers.header("Foo") = "bar";
    my $normal = Intern::Bookmark::Web::Response.new(:body(['hello']), :headers($headers), :status(303));

    my Crust::Response $crustified = $normal.crustify;
    is $crustified.body, $normal.body;
    is $crustified.status, $normal.status;
    is $crustified.headers, Array.new($headers.for-P6SGI);
}

my $plain-ok = Intern::Bookmark::Web::Response.text-response('foobar');
is $plain-ok.body, 'foobar';
is $plain-ok.status, 200;
is $plain-ok.headers.Content-Type, 'text/plain';

my $html-ok = Intern::Bookmark::Web::Response.html-response('some html');
is $html-ok.body, 'some html';
is $html-ok.status, 200;
is $html-ok.headers.Content-Type, 'text/html';

my $error404 = Intern::Bookmark::Web::Response.error-response(404);
is $error404.body, 'Not Found';
is $error404.status, 404;
is $error404.headers.Content-Type, 'text/plain';

my $error-custom-body = Intern::Bookmark::Web::Response.error-response(400, 'Oops, 400...');
is $error-custom-body.body, 'Oops, 400...';
is $error-custom-body.status, 400;

my $redirect = Intern::Bookmark::Web::Response.redirect-response(302, 'http://example.com/');
is $redirect.status, 302;
is $redirect.headers.Location, 'http://example.com/';

done-testing;
