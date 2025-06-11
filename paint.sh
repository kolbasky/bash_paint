#!/usr/bin/env bash
#set -x
shopt -s extglob 2> /dev/null
setopt extended_glob 2> /dev/null
setopt KSH_ARRAYS 2> /dev/null
trap "tput cnorm; tput sgr0; stty echo; tput rmcup; echo -e \"\e[?1002l\"; echo -e "\e[?6l"; echo -e "\e[?7l"; exit 1" SIGINT SIGTERM EXIT

stty -echo
tput smcup
tput civis
x_pos=33
y_pos=33
scr_width=64 #`tput cols`
scr_height=45 #`tput lines`

tputseta="setab";
bound_color=0
draw_color=1
draw_char=" "

draw_boundaries() {
    tput sgr0
    tput civis
    width=$scr_width
    height=$scr_height
    i=0
    clear
    while [[ $i -le $width ]];do
        tput cup 1 $i
        printf -- "$(tput $tputseta $bound_color)$(tput setaf $bound_color)#"
        tput cup $height $i
        printf -- "$(tput $tputseta $bound_color)$(tput setaf $bound_color)#"
        i=$((i+1))
    done
    i=1
    while [[ $i -le $height ]];do
        tput cup $i 0
        printf -- "$(tput $tputseta $bound_color)$(tput setaf $bound_color)#"
        tput cup $i $width
        printf -- "$(tput $tputseta $bound_color)$(tput setaf $bound_color)#"
        i=$((i+1))
    done
}
draw_boundaries

echo -e "\e[?1002h"
echo -e "\e[?6h"
echo -e "\e[?7h"
while : ; do
  read -sd "#" -n 2 CURPOS
  if [[ $(echo $CURPOS | head -c1) == "=" ]];then
    draw_color=$(((draw_color+1)))
  elif [[ $(echo $CURPOS | head -c1) == "-" ]];then
    draw_color=$(((draw_color-1)))
  fi
  if [[ $draw_color -lt 0 ]];then
    draw_color=7
  elif [[ $draw_color -gt 7 ]];then
    draw_color=0
  fi

  CURPOS=${CURPOS#*[}
  tput cup 1 1
  echo "CURPOS=$CURPOS"
  CURPOS=${CURPOS#* }
  x_pos=$(echo $CURPOS | head -c1)
  x_pos=$(printf '%d\n' "'$x_pos")
  x_pos=$(($x_pos - 33))
  y_pos=$(echo $CURPOS | tr -d "\n" | tail -c1)
  y_pos=$(printf '%d\n' "'$y_pos")
  y_pos=$(($y_pos - 33))
  tput cup 2 1
  echo "$x_pos $y_pos"
  if [[ ! -z $x_pos ]] && [[ ! -z $y_pos ]]; then
    if [[ $x_pos -gt -1 ]] || [[ $y_pos -gt 1 ]] && [[ $x_pos -lt $scr_width ]] && [[ $y_pos -lt $scr_height ]]; then
      tput cup $y_pos $x_pos 2> /dev/null || true
      #printf X
      printf -- "$(tput setab $draw_color)${draw_char}$(tput sgr0)"
      unset x_pos
      unset y_pos
    fi
  fi
done
