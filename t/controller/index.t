use v6;
use Test;
use InternTest;

use Intern::Bookmark::Web;

use Crust::Test;
use HTTP::Request;

my $test = Crust::Test.create(intern-bookmark-web-psgi);

{
    my $res = $test.request(HTTP::Request.new(GET => "/"));
    ok $res.decoded-content.index("Guest !").defined;
    ok $res.decoded-content.index(q|<a href="/login">|).defined;
    is $res.field('X-Dispatch'), 'Intern::Bookmark::Controller::Index#index';
}

# TODO How can we create request with login session? Do POST?

done-testing;
