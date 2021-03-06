unit module Intern::Bookmark::Web::Helper;

use Intern::Bookmark::Model::User;
need DBDish::Connection;
need Crust::Request;

sub visitor (Crust::Request $req!, DBDish::Connection $dbh! --> Intern::Bookmark::Model::User) is export {
    use Intern::Bookmark::Service::User;
    my $user-name = $req.session.get("username");
    with $user-name {
        Intern::Bookmark::Service::User.find-or-create($dbh, $user-name);
    } else {
        Nil;
    }
}
