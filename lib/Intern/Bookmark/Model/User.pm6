unit class Intern::Bookmark::Model::User;

has Int $.user_id;
has Str $.name;
has DateTime $.created;

method as-hash (--> Hash) {
    {
        user_id => $!user_id,
        name    => $!name,
        created => $!created.Str
    };
}
