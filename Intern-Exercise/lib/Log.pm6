class Log {
    has Str $.host;
    has Str $.user;
    has Int $.epoch;
    has Str $.req;
    has Int $.status;
    has Int $.size;
    has Str $.referer;

    # composed from req
    has @!parsed-req =  split(' ', $!req, 3);
    has $.method = @!parsed-req[0];
    has $.path = @!parsed-req[1];
    has $.protocol = @!parsed-req[2];

    has $.uri = 'http://' ~ $!host ~ $!path;
    has $.time = DateTime.new($!epoch).Str;
}
