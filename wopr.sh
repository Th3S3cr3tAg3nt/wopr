#!/bin/sh

calc_wt_size() {
  # NOTE: it's tempting to redirect stderr to /dev/null, so supress error
  # output from tput. However in this case, tput detects neither stdout or
  # stderr is a tty and so only gives default 80, 24 values
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

do_update() {
  cd ~
  git clone https://github.com/Th3S3cr3tAg3nt/wopr.git
  cd wopr
  exec wopr.sh
}

do_finish() {
  exit 0
}


calc_wt_size
  while true; do
    FUN=$(whiptail --title "War Operation Plan Response" --backtitle "$(cat /proc/device-tree/model)" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
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

