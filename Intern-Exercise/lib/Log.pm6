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
    has Str $.method = @!parsed-req[0];
    has Str $.path = @!parsed-req[1];
    has Str $.protocol = @!parsed-req[2];

    has Str $.uri = 'http://' ~ $!host ~ $!path;
    has Str $.time = DateTime.new($!epoch).Str;
}
