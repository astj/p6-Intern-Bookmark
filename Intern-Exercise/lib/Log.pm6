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
    has Str $.method = @!parsed-req[0] // '';
    has Str $.path = @!parsed-req[1] // '';
    has Str $.protocol = @!parsed-req[2] // '';

    has Str $.uri = 'http://' ~ $!host ~ $!path;
    # XXX In p5 exercise specified Str, but in p6 maybe we can keep DateTime..
    has Str $.time = DateTime.new($!epoch).Str;
    has Str $.display-user-name = $!user // 'guest';

    constant @HASH-KEYS = qw/user status size referer method uri time/;
    method to-hash ( --> Hash ) {
        @HASH-KEYS.grep({ self."$_"().defined }).map({
          $_ => self."$_"()
        }).Hash;
    }
}
