need Crust::Response;
unit class Intern::Bookmark::Web::Response;

use HTTP::Headers;
use HTTP::Status;

has Array $.body;
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

method error-response(Int $status, Str $text?){
    my $body = $text // get_http_status_msg($status);

    my $res = self.new(:status($status), :body([$body]));
    $res.headers.Content-Type = 'text/plain';

    $res;
}

method redirect-response(Int $status, Str $location){
    my $res = self.new(:status($status));
    $res.headers.Location = $location;

    $res;
}

### instance method
method crustify() {
    # XXX Crust::Middleware::Session requires headers to be an Array, but HTTP::Headers#for-P6SGI is Seq
    Crust::Response.new(:status($.status), :headers(Array.new($.headers.for-P6SGI)), :body($.body));
}

=begin pod

=head1 NAME

Intern::Bookmark::Web::Response - A customized Crust::Response

=head1 DESCRIPTION

though C<Crust::Response#headers> is an Array, C<Intern::Bookmark::Web::Response#headers> is an instance of C<HTTP::Headers>, so that you can modify response headers afterwards.
=end pod
