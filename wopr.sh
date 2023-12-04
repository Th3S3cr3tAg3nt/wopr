#!/bin/sh

calc_wt_size() {
  WT_HEIGHT=18
  WT_WIDTH=$(tput cols)

  if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
    WT_WIDTH=80
  fi
  if [ "$WT_WIDTH" -gt 178 ]; then
    WT_WIDTH=120
  fi
  WT_MENU_HEIGHT=$((WT_HEIGHT - 7))
}

do_choose_wireless_interface() {
  wifi_interfaces=$(iw dev 2>&1 | awk '/Interface/ {print $2}')

  if [ -z "$wifi_interfaces" ]; then
    whiptail --msgbox "No WiFi interfaces found." 20 60 2
    return 0
  fi
  #echo ${wireless_interfaces}

  # Create an array for whiptail menu options
  menu_options=""
  menu_options="$menu_options \"none\" \"No source defined\" "
  for interface in $wifi_interfaces; do
    menu_options="$menu_options \"$interface\" \"WiFi interface $interface\" "
  done

  # Use whiptail to create a selection menu
  selected_interface=$(eval "whiptail --title \"WiFi Interface Selection\" --backtitle \"Kismet Options\" --menu \"Choose a WiFi source:\" 20 60 4 $menu_options 3>&1 1>&2 2>&3")

  # Check if the user canceled the selection
  if [ $? -ne 0 ]; then
    whiptail --msgbox "Selection canceled." 20 60 2
    #echo "Selection canceled."
    return 1
  else
    return ${selected_interface}
  fi
}

do_update() {
  cd ~
  git clone https://github.com/Th3S3cr3tAg3nt/wopr.git
  cd wopr
  exec wopr.sh
}


do_kismet() {
  wifi_interfaces=$(iw dev 2>&1 | awk '/Interface/ {print $2}')

  if [ -z "$wifi_interfaces" ]; then
    whiptail --msgbox "No WiFi interfaces found." 20 60 2
    return 0
  fi

  # Create an array for whiptail menu options
  menu_options=""
  menu_options="$menu_options \"none\" \"No source defined\" "
  for interface in $wifi_interfaces; do
    menu_options="$menu_options \"$interface\" \"WiFi interface $interface\" "
  done

  # Use whiptail to create a selection menu
  selected_interface=$(eval "whiptail --title \"Kismet Interface Selection\" --backtitle \"Hack The Planet!\" --menu \"Choose a WiFi data source:\" 20 60 4 $menu_options 3>&1 1>&2 2>&3")

  # Check if the user canceled the selection
  if [ $? -ne 0 ]; then
    return 0
  fi

  if [ "$selected_interface" = "none" ]; then
    exec kismet --no-ncurses
  else
    exec kismet --no-ncurses -c ${selected_interface} 
  fi
}

do_wifite() {
  FUN=$(whiptail --title "War Operation Plan Response" --backtitle "Hack The Planet!" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
    "1 WiFite" "Just Launch WiFite" \
    "2 WiFite All" "Attack All Targets" \
    "3 WiFite 20db" "Attack Any Close Target" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0;
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      1\ *) exec sudo wifite ;;
      2\ *) exec sudo wifite -inf ;;
      3\ *) exec sudo wifite -pow 20 -p 20 ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  else
    exit 1
  fi
  exec sudo wifite
}

do_deauth() {
  echo "Not implemented"
  sleep 5
}

do_finish() {
  exit 0
}


calc_wt_size
while true; do
  FUN=$(whiptail --title "War Operation Plan Response" --backtitle "Hack The Planet!" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
    "1 WiFite" "Crack Wireless Networks" \
    "2 Deauth" "Disrupt Wireless Networks" \
    "3 Kismet" "Start Kismet Monitoring" \
    "4 Network Recon" "Launch Network Recon Scripts" \
    "8 Update" "Update this tool to the latest version" \
    "9 Sync Loot" "Securely Upload Loot" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    do_finish
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      1\ *) do_wifite ;;
      2\ *) do_deauth ;;
      3\ *) do_kismet ;;
      4\ *) do_recon ;;
      8\ *) do_update ;;
      9\ *) do_sync ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  else
    exit 1
  fi
done
