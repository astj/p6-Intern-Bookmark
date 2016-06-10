unit class Intern::Bookmark::Model::Bookmark;

has Int $.bookmark_id;
has Int $.user_id;
has Int $.entry_id;
has Str $.comment;
has DateTime $.created;
has DateTime $.updated;

need Intern::Bookmark::Model::Entry;
has Intern::Bookmark::Model::Entry $.entry is rw;
