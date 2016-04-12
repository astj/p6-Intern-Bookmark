use v6;

use Parser;
use LogCounter;

my $parser = Parser.new( filename => './sample_data/log.ltsv' );
my $counter = LogCounter.new( logs => $parser.parse() );

say 'total error size: ' ~ $counter.count_error;

say $counter.group_by_user;
