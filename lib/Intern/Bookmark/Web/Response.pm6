need Crust::Response;
unit class Intern::Bookmark::Web::Response is Crust::Response;

use HTTP::Headers;

has HTTP::Headers $.headers = HTTP::Headers.new;

method finalize() {
    return $.status, $.headers.for-P6SGI, $.body;
}

=begin pod

=head1 NAME

Intern::Bookmark::Web::Response - A customized Crust::Response

=head1 DESCRIPTION

though C<Crust::Response#headers> is an Array, C<Intern::Bookmark::Web::Response#headers> is an instance of C<HTTP::Headers>, so that you can modify response headers afterwards.
=end pod
