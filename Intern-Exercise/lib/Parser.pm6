grammar LTSVLog {
    token TOP { <field>+%\t }
    token field { <label>\:<field-value> }
    token label { <[0..9A..Za..z_.-]>+ }
    token field-value { \T* } # too simple???
}

class LTSVRecordActions {
    method TOP   ($/) { $/.make: $<field>>>.made.Hash }
    method field ($/) { $/.make: $<field-value>.Str eq '-' ?? () !! $<label>.Str => $<field-value>.Str }
}

class Parser {
    use Log;

    has Str $.filename;
    has @!lines;
    has @!logs;
    method parse () {
        # TODO error handling
        @!lines = $!filename.IO.lines;
        @!logs = @!lines.map: {
            my %ltsv-log = LTSVLog.parse($_, :actions(LTSVRecordActions)).made;
            Log.new:
                :host(%ltsv-log<host>),
                :user(%ltsv-log<user>),
                :req(%ltsv-log<req>),
                :referer(%ltsv-log<referer>),
                # numeric fields needs conversion
                :epoch(+%ltsv-log<epoch>),
                :status(+%ltsv-log<status>),
                :size(+%ltsv-log<size>),
                ;
        }
        @!logs
    };
}