use v6;
use Test;
use InternTest;

use Intern::Bookmark::Web::Response;
use HTTP::Header;
use Crust::Response;

use-ok('Intern::Bookmark::Web::Response');

# basic
{
    my $headers = HTTP::Header.new;
    $headers.field(:Foo("bar"), :Hoge(("fuga", "piyo")));
    my $normal = Intern::Bookmark::Web::Response.new(:body(['hello']), :headers($headers), :status(303));

    is $normal.headers-as-array, ( Foo => "bar", Hoge => "fuga", Hoge => "piyo");

    my Crust::Response $crustified = $normal.crustify;
    is $crustified.body, $normal.body;
    is $crustified.status, $normal.status;
    is $crustified.headers, $normal.headers-as-array
}

my $plain-ok = Intern::Bookmark::Web::Response.text-response('foobar');
is $plain-ok.body, 'foobar';
is $plain-ok.status, 200;
is $plain-ok.headers.field('Content-Type'), 'text/plain';

my $html-ok = Intern::Bookmark::Web::Response.html-response('some html');
is $html-ok.body, 'some html';
is $html-ok.status, 200;
is $html-ok.headers.field('Content-Type'), 'text/html';

my $error404 = Intern::Bookmark::Web::Response.error-response(404);
is $error404.body, 'Not Found';
is $error404.status, 404;
is $error404.headers.field('Content-Type'), 'text/plain';

my $error-custom-body = Intern::Bookmark::Web::Response.error-response(400, 'Oops, 400...');
is $error-custom-body.body, 'Oops, 400...';
is $error-custom-body.status, 400;

my $redirect = Intern::Bookmark::Web::Response.redirect-response(302, 'http://example.com/');
is $redirect.status, 302;
is $redirect.headers.field('Location'), 'http://example.com/';

done-testing;
