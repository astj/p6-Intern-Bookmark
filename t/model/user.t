use v6;
use Test;
use InternTest;

use Intern::Bookmark::Model::User;

use-ok('Intern::Bookmark::Model::User');

my $now = DateTime.now;
my $user = Intern::Bookmark::Model::User.new(
    :user_id(12345),
    :name<astj>,
    :created($now)
);

is $user.as-hash, {:user_id(12345), :name<astj>, :created($now.Str) };
isa-ok $user.as-hash<created>, Str, 'created is unblessed, not blessed DateTime';

done-testing;
