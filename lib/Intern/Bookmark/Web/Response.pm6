need Crust::Response;
unit class Intern::Bookmark::Web::Response is Crust::Response;

use HTTP::Headers;

has Int $.status = 200;
has HTTP::Headers $.headers = HTTP::Headers.new;

### constructors
method text-response(Str $text) {
    my $res = self.new(:body([$text]));
    $res.headers.Content-Type = 'text/plain';

    $res;
}

method html-response(Str $text) {
    my $res = self.new(:body([$text]));
    $res.headers.Content-Type = 'text/html';

    $res;
}

### instance method
method finalize() {
    # XXX Crust::Middleware::Session requires headers to be an Array, but HTTP::Headers#for-P6SGI is Seq
    return $.status, Array.new($.headers.for-P6SGI), $.body;
}

=begin pod

=head1 NAME

Intern::Bookmark::Web::Response - A customized Crust::Response

=head1 DESCRIPTION

though C<Crust::Response#headers> is an Array, C<Intern::Bookmark::Web::Response#headers> is an instance of C<HTTP::Headers>, so that you can modify response headers afterwards.
=end pod
