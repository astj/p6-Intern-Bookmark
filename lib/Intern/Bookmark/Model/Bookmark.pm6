class Intern::Bookmark::Model::Bookmark {
    has Int $.bookmark_id;
    has Int $.user_id;
    has Int $.entry_id;
    has Str $.comment;
    has DateTime $.created;
    has DateTime $.updated;
}
