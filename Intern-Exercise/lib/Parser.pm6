grammar LTSVRecord {
    token TOP { <field>+%\t }
    token field { <label>\:<field-value> }
    token label { <[0..9A..Za..z_.-]>+ }
    token field-value { \T* } # too simple???
}

class LTSVRecordActions {
    method TOP   ($/) { $/.make: $<field>>>.made.Hash }
    method field ($/) { $/.make: $<field-value>.Str eq '-' ?? :{} !! :{$<label>.Str => $<field-value>.Str} }
}

class Parser {
    use Log;

    has Str $.filename;
    constant $STR-LABELS = "host"|"user"|"req"|"referer";
    constant $INT-LABELS = "epoch"|"status"|"size";
    constant $ALL-LABELS = $STR-LABELS|$INT-LABELS;
    method parse () {
        unless $!filename.IO.e { die; }
        $!filename.IO.lines.map: {
            my %ltsv-record = LTSVRecord.parse($_, :actions(LTSVRecordActions)).made;
            # Drop undefined fields and convert numeric fields to construct an instance of Log
            my %construct-params = %ltsv-record.grep({.key eq $ALL-LABELS}).map({ .key => (.key eq $INT-LABELS ?? +.value !! ~.value) });
            # Use `|%FOO` to be treated as a named arguments
            Log.new(|%construct-params);
        }
    };
}
