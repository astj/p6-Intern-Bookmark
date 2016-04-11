use v6;

use Parser;

my $parser = Parser.new( filename => './sample_data/log.ltsv' );
$parser.parse.say;
