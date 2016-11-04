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

done-testing;
