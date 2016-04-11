class Log {
    # Thos are all optional!!
    has $.host;
    has $.user;
    has $.epoch;
    has $.req;
    has $.status;
    has $.size;
    has $.referer;

    # composed from req
    has @!parsed-req =  split(' ', $!req, 3);
    has Str $.method = @!parsed-req[0] // '';
    has Str $.path = @!parsed-req[1] // '';
    has Str $.protocol = @!parsed-req[2] // '';

    has Str $.uri = 'http://' ~ $!host ~ $!path;
    # XXX In p5 exercise specified Str, but in p6 maybe we can keep DateTime..
    has Str $.time = DateTime.new($!epoch).Str;

    constant @HASH-KEYS = qw/user status size referer method uri time/;
    method to-hash ( --> Hash ) {
        @HASH-KEYS.grep({ self."$_"().defined }).map({
          $_ => self."$_"()
        }).Hash;
    }
}
