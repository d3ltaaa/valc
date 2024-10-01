#!/bin/bash
#########################################################
# exclude
exclude=("/home/falk/.cache" "/home/falk/.local")

# origin
origins=("/home/falk/")
#########################################################

function get_excludes() {
  exclude_string=""
  # add comma between excludes
  for ((i = 0; i < ${#exclude[@]}; i++)); do
    exclude_string+="${exclude[$i]},"
  done
  # remove last comma
  if [ ${#exclude[@]} -ge 1 ]; then
    exclude_string=${exclude_string:0:-1}
  fi
  echo $exclude_string
}

function get_origins() {
  origin_string=""
  for ((i = 0; i < ${#origins[@]}; i++)); do
    origin_string+="${origins[$i]}\n"
  done

  origin=$(printf "$origin_string" | rofi -dmenu -p "Origin:")

  if [ ! -f "${origin}" ] && [ ! -d "${origin}" ]; then
    echo "${origin} is not a file or directory!"
    dunstify "${origin} is not a file or directory!"
    return 1
  fi

  echo "$origin"
  # echo ${origin// /'\ '}
}

function get_destinations() {
  lsblk="$(lsblk -o NAME,MOUNTPOINTS -ln | awk '{print $2}')"

  destination="$(printf "%s\n" ${lsblk[@]} | rofi -dmenu -p "Destination:")"

  if [ ! -f "${destination}" ] && [ ! -d "${destination}" ]; then
    echo "${destination} is not a file or directory!"
    dunstify "${destination} is not a file or directory!"
    return 1
  fi

  echo $destination
}

function execute_rsync() {
  exclude=$(get_excludes) # get exclude
  origin=$(get_origins)   # get origin
  retval=$?
  [ $retval -ne 0 ] && exit 1     # if get_origins returns 1, then exit
  destination=$(get_destinations) #get destination
  retval=$?
  [ $retval -ne 0 ] && exit 1 # if get_destinations returns 1, then exit

  if [[ $1 == 1 ]]; then
    # if execute
    echo rsync -s -aAXvh --delete --info=progress2 --exclude={${exclude}} \"${origin}\" ${destination}
    # open new terminal and execute rsync command
    foot -H rsync -s -aAXvh --delete --info=progress2 --exclude={${exclude}} "${origin}" "${destination}"
    if [ $? -eq 0 ]; then
      dunstify "Execute returns successfully"
    else
      dunstify "Error: Execute failed"
    fi

  else
    # if dry-run
    echo rsync -s --dry-run -aAXvh --delete --info=progress2 --exclude={${exclude}} \"${origin}\" ${destination}
    # open new terminal and execute dry-run command
    foot rsync -s --dry-run -aAXvh --delete --info=progress2 --exclude={${exclude}} "${origin}" "${destination}"
    if [ $? -eq 0 ]; then
      # if it succeeds
      dunstify "Dry-Run returns successfully"

      # new menu
      options=("Start Backup" "Close")
      selected=$(printf "%s\n" "${options[@]}" | rofi -dmenu -p "Backup:")

      if [[ "$selected" == "Start Backup" ]]; then
        # if start backup
        echo rsync -s -aAXvh --delete --info=progress2 --exclude={${exclude}} \"${origin}\" ${destination}
        # open new terminal and execute rsync command
        foot -H rsync -s -aAXvh --delete --info=progress2 --exclude={${exclude}} "${origin}" "${destination}"

        if [ $? -eq 0 ]; then
          dunstify "Execute returns successfully"
        else
          dunstify "Error: Execute failed"
        fi
      fi
    else
      dunstify "Error: Dry-Run failed"
    fi
  fi
}

function menu() {
  options=("Start" "Close")
  selected=$(printf "$options" | rofi -dmenu -p "Backup:")
  if [[ "$selected" == "Start" ]]; then
    options2=("Dry-Run" "Execute")
    selected2=$(printf "%s\n" ${options2[@]} | rofi -dmenu -p "Backup:")
    if [[ "$selected2" == "Dry-Run" ]]; then
      execute_rsync 0
    elif [[ "$selected2" == "Execute" ]]; then
      execute_rsync 1
    else
      exit 1
    fi
  else
    exit 1
  fi
}

menu
