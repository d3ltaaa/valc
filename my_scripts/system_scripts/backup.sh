#!/bin/bash
#########################################################
# exclude
exclude=("/home/falk/.cache" "/home/falk/.local")

# origin
origins=("/home/falk/")

# destination
destinations=("/home/falk/Test/" "/home/falk/")

# phone origin
phone_origins=("/storage/emulated/0/")

# phone destination

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

  pre_origin=$(printf "$origin_string" | rofi -dmenu -p "Origin:")

  origin="$(rofi -dmenu -p "Origin:" -filter $pre_origin)"

  if [ ! -f "${origin}" ] && [ ! -d "${origin}" ]; then
    echo "${origin} is not a file or directory!"
    dunstify "${origin} is not a file or directory!"
    return 1
  fi

  echo "$origin"
  # echo ${origin// /'\ '}
}

function get_destinations() {
  pre_destination="Reload"

  while [[ "$pre_destination" == "Reload" ]]; do
    lsblk="Reload ${destinations[@]} $(lsblk -o NAME,MOUNTPOINTS -ln | awk '{print $2}')"
    pre_destination="$(printf "%s\n" ${lsblk[@]} | rofi -dmenu -p "Destination:")"
  done

  destination="$(rofi -dmenu -p "Destination:" -filter $pre_destination)"

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

  echo DEBUG
  if [[ $1 == 1 ]]; then
    # if execute
    echo rsync -s -aAXvh --delete --info=progress2 --exclude={${exclude}} \"${origin}\" ${destination}
    # open new terminal and execute rsync command
    foot -H sudo rsync -s -aAXvh --delete --info=progress2 --exclude={${exclude}} "${origin}" "${destination}"
    if [ $? -eq 0 ]; then
      dunstify "Execute returns successfully"
    else
      dunstify "Error: Execute failed"
    fi

  else
    # if dry-run
    echo rsync -s --dry-run -aAXvh --delete --info=progress2 --exclude={${exclude}} \"${origin}\" ${destination}
    # open new terminal and execute dry-run command
    foot sudo rsync -s --dry-run -aAXvh --delete --info=progress2 --exclude={${exclude}} "${origin}" "${destination}"
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
        foot -H sudo rsync -s -aAXvh --delete --info=progress2 --exclude={${exclude}} "${origin}" "${destination}"

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

function get_phone_string() {

  selected2="Reload"
  while [[ "$selected2" == "Reload" ]]; do
    output="$(adb devices -l | tail -n +2)"
    line=""
    options2=$'Reload\n'
    for ((i = 0; i < ${#output}; i++)); do
      if [[ "${output[$i]}" == $'\n' ]]; then
        device_string=$(echo "$line" | cut -d ' ' -f 1)
        device_model=$(echo "$line" | grep -o "model:[^ ]*" | cut -d ':' -f 2)

        # Append device_string=device_model to options
        options2+="${device_string}=${device_model} "
        line=""
      else
        line+="${output[$i]}"
      fi
    done

    # last character is not \n therefore we need one more
    if [[ "$line" != "" ]]; then
      device_string=$(echo "$line" | cut -d ' ' -f 1)
      device_model=$(echo "$line" | grep -o "model:[^ ]*" | cut -d ':' -f 2)

      # Append device_string=device_model to options
      options2+="${device_string}=${device_model} "
      line=""
    # else
    #   dunstify "No phone connected"
    #   exit 1
    fi

    selected2="$(printf "%s\n" "${options2[@]}" | rofi -dmenu -p "Backup:")"
  done

  if [[ "$selected2" == "Close" ]]; then
    exit 0
  else
    device_string=$(echo $selected2 | cut -d '=' -f 1)
  fi
}

function get_origins_phone() {
  origin_string=""
  for ((i = 0; i < ${#phone_origins[@]}; i++)); do
    origin_string+="${phone_origins[$i]}\n"
  done

  pre_origin=$(printf "$origin_string" | rofi -dmenu -p "Origin:")

  origin="$(rofi -dmenu -p "Origin:" -filter $pre_origin)"

  echo "$origin"
  # echo ${origin// /'\ '}
}

function get_destinations_phone() {
  pre_destination="Reload"

  while [[ "$pre_destination" == "Reload" ]]; do
    lsblk="Reload ${destinations[@]} $(lsblk -o NAME,MOUNTPOINTS -ln | awk '{print $2}')"
    pre_destination="$(printf "%s\n" ${lsblk[@]} | rofi -dmenu -p "Destination:")"
  done

  destination="$(rofi -dmenu -p "Destination:" -filter $pre_destination)"

  if [ ! -f "${destination}" ] && [ ! -d "${destination}" ]; then
    echo "${destination} is not a file or directory!"
    dunstify "${destination} is not a file or directory!"
    return 1
  fi

  echo $destination

}

function execute_adb() {
  origin=$(get_origins_phone) # get origin
  retval=$?
  [ $retval -ne 0 ] && exit 1           # if get_origins returns 1, then exit
  destination=$(get_destinations_phone) #get destination
  retval=$?
  [ $retval -ne 0 ] && exit 1 # if get_destinations returns 1, then exit

  if [[ $1 == 1 ]]; then
    # if execute
    echo adb pull -a "${origin}" "${destination}"
    foot -H adb pull -a "${origin}" "${destination}"
    if [ $? -eq 0 ]; then
      dunstify "Execute returns successfully"
    else
      dunstify "Error: Execute failed"
    fi
  fi
}

function menu() {
  options2=("Close" "Dry-Run" "Execute")
  selected2=$(printf "%s\n" ${options2[@]} | rofi -dmenu -p "Backup:")
  if [[ "$selected2" == "Dry-Run" ]]; then
    execute_rsync 0
  elif [[ "$selected2" == "Execute" ]]; then
    execute_rsync 1
  else
    exit 0
  fi
}

function menu_phone() {
  device_string=""
  get_phone_string

  options2=("Close" "Execute")
  selected=$(printf "%s\n" ${options2[@]} | rofi -dmenu -p "Backup:")

  if [[ "$selected" == "Execute" ]]; then
    execute_adb 1
  else
    exit 1
  fi

}

function backup_what() {
  options=("Close" "PC" "Phone")
  selected=$(printf "%s\n" "${options[@]}" | rofi -dmenu -p "Backup:")
  if [[ "$selected" == "PC" ]]; then
    menu
  elif [[ "$selected" == "Phone" ]]; then
    menu_phone
  fi
}

backup_what
