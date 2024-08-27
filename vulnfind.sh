#!/bin/bash
echo "Attempting to find full-permission subdirectories."

check_permissions() {
  local dir="$1"
  local processed="$2"

  # Ignore volumes directories so that we don't enter an infinite loop
  if [[ "$dir" == *"/System/Volumes/"* ]]; then
    return
  fi
  if [[ "$dir" == *"/Volumes/"* ]]; then
    return
  fi
  
  # Check if the executing user has read, write, and execute privileges on the current directory.

  # Note that often there will be a bunch of directories that appear to have the correct 
  # permissions, but are protected via antivirus software, such as csr. An example would be your current user.
  # These directories are quite bothersome, and the only real way to check if they are functional would be dropping a
  # test executable in there, but this is not effecient I/O wise, so they are just included in the output.
  if [ -r "$dir" ] && [ -w "$dir" ] && [ -x "$dir" ]; then
    echo "$dir"
    processed=true
  fi
  
  # Recursive loop throughout directories
  if [ "$processed" == true ]; then
    return
  fi
  
  for sub_dir in "$dir"/*; do
    if [ -d "$sub_dir" ]; then
      check_permissions "$sub_dir" "$processed"
    fi
  done
}

check_permissions . false
