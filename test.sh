#!/bin/bash

exe="../lab"
test_dir="tests"
data_dir="$(pwd)/data"

trace() {
  echo >&2 "$@"
}

run=0
okay=0

while read path_in; do
  IFS="/" read _ suite fixture <<< "$path_in"
  IFS="_" read id _ <<< "$fixture"

  trace "Found suite=$suite fixture=$fixture id=$id"

  while read path_check; do
    IFS="/" read _ _ check <<< "$path_check"

    case "$check" in
      *_diffcmd)
        res=0
        cmd1="$(cat "$path_in")"
        cmd2="$(cat "$path_check")"
        (
          cd "$data_dir" || exit 2
          # compare stdout
          diff -u <(bash -c "$cmd1" 2>/dev/null) <(bash -c "$cmd2" 2>/dev/null)
          # compare stderr
          diff -u <(bash -c "$cmd1" 2>&1 1>/dev/null) <(bash -c "$cmd2" 2>&1 1>/dev/null)
        ) && ((++okay)) || res=$?
        trace "  {$res} Ran check=$check type=diff_command"
        ((++run))
        ;;
      *_errmatch)
        res=0
        (
          cd "$data_dir" || exit 2
          "$exe" "../$path_in" 2>&1 1>/dev/null | grep -qf "../$path_check"
        ) && ((++okay)) || res=$?
        trace "  {$res} Ran check=$check type=stderr_match"
        ((++run))
        ;;
    esac
  done < <(find "${test_dir}/${suite}" -type f -name "${id}*" -and -not -name "*_in")
  trace
done < <(find "${test_dir}" -type f -name '*_in')

trace "Ran ${run} test(s)."
trace

[[ "$okay" = "$run" ]]; ret=$?
[[ "$ret" = 0 ]] && trace 'OK'

exit $ret
