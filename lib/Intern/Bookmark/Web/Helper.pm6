unit module Intern::Bookmark::Web::Helper;

use Intern::Bookmark::Model::User;
need DBDish::Connection;
need Crust::Request;

sub visitor (Crust::Request $req!, DBDish::Connection $dbh! --> Intern::Bookmark::Model::User) is export {
    # TODO handle by session
    use Intern::Bookmark::Service::User;
    Intern::Bookmark::Service::User.find-or-create($dbh, "astj");
}
