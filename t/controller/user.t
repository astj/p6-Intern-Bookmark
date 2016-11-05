use v6;
use Test;
use InternTest;

use HTTP::Request;
use HTTP::Cookies;

use Intern::Bookmark::Web;

use Crust::Test;

my $test = Crust::Test.create(intern-bookmark-web-psgi);

{
    my $res = $test.request(HTTP::Request.new(GET => "/login"));
    is $res.field('X-Dispatch'), 'Intern::Bookmark::Controller::User#login';
}

{
    my $res = $test.request(HTTP::Request.new(POST => "/login"));
    is $res.field('X-Dispatch'), 'Intern::Bookmark::Controller::User#login';
    is $res.code, 400;
}

{
    my $user-name = random-strings-by-length(10);

    my $req = HTTP::Request.new(POST => "/login");
    $req.add-form-data({name => $user-name });

    my $res = $test.request($req);
    is $res.field('X-Dispatch'), 'Intern::Bookmark::Controller::User#login';
    is $res.code, 303;
    is $res.field('Location'), '/';

    # Follow redirect with Cookies
    my $next-req = $res.next-request;
    my $cookies = HTTP::Cookies.new;
    $cookies.extract-cookies($res);
    $next-req.add-cookies($cookies);

    my $redirected-res = $test.request($next-req);
    is $redirected-res.code, 200;
    ok $redirected-res.decoded-content.index($user-name).defined, 'Displayed use name on top page';
}

done-testing;
