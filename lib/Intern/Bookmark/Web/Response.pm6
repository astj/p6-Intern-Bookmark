need Crust::Response;
unit class Intern::Bookmark::Web::Response;

use HTTP::Header;
use HTTP::Status;

has Array $.body;
has Int $.status = 200;
has HTTP::Header $.headers = HTTP::Header.new;

### constructors
method text-response(Str $text) {
    my $res = self.new(:body([$text]));
    $res.headers.field(:Content-Type<text/plain>);

    $res;
}

method html-response(Str $text) {
    my $res = self.new(:body([$text]));
    $res.headers.field(:Content-Type<text/html>);

    $res;
}

method error-response(Int $status, Str $text?){
    my $body = $text // get_http_status_msg($status);

    my $res = self.new(:status($status), :body([$body]));
    $res.headers.field(:Content-Type<text/plain>);

    $res;
}

method redirect-response(Int $status, Str $location){
    my $res = self.new(:status($status));
    $res.headers.field(:Location($location));

    $res;
}

### instance method
method headers-as-array( --> Array) {
    # { a => ['b' 'c'] ... }
    # => { (b => 'a' c => 'a') ... }
    # => { (a => 'b' a => 'c') ... }
    # => (a => 'b' a => 'c' ... )
    Array.new($.headers.hash.map({ .invert.invert }).flat)
}

method crustify() {
    Crust::Response.new(:status($.status), :headers($.headers-as-array), :body($.body));
}

=begin pod

=head1 NAME

Intern::Bookmark::Web::Response - A customized Crust::Response

=head1 DESCRIPTION

though C<Crust::Response#headers> is an Array, C<Intern::Bookmark::Web::Response#headers> is an instance of C<HTTP::Header>, so that you can modify response headers afterwards.
=end pod
