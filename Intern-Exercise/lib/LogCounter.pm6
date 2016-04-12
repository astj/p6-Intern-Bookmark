class LogCounter {
    has @.logs;
    method count_error ( --> Int) {
      @!logs.grep({ 500 <= .status < 600 }).elems;
    }
    method group_by_user () {
      my %grouped-logs;
      for @.logs -> $log {
          %grouped-logs{$log.display-user-name} //= [];
          %grouped-logs{$log.display-user-name}.push($log);
      }
      %grouped-logs;
    }
}
