MODPATH=${0%/*}

# log
LOGFILE=$MODPATH/debug.log
exec 2>$LOGFILE
set -x

# zram
ZRAM=/block/zram0
DISKSIZEDEF=`cat /sys$ZRAM/disksize`
DISKSIZE=
#%MemTotal=`awk '/MemTotal/ {print $2}' /proc/meminfo`
#%let VALUE="$MemTotal * VAR / 100"
#%DISKSIZE=$VALUE\K
SWAPOFF=false
if grep -q /dev$ZRAM /proc/swaps; then
  for i in `seq 1 20`; do
    if swapoff /dev$ZRAM; then
      SWAPOFF=true
      break
    fi
    sleep 3
  done
  if grep -q /dev$ZRAM /proc/swaps; then
    SWAPOFF=false
  fi
else
  SWAPOFF=true
fi
ALGODEF=`cat /sys$ZRAM/comp_algorithm`
ALGO=
PRIODEF=`cat /proc/swaps | awk 'NR>1 {print $5}'`
PRIO=
if $SWAPOFF; then
  echo 1 > /sys$ZRAM/reset
  [ "$ALGO" ] && echo "$ALGO" > /sys$ZRAM/comp_algorithm
#o  echo "$DISKSIZE" > /sys$ZRAM/disksize
#o  mkswap /dev$ZRAM
#o  /system/bin/swapon /dev$ZRAM -p "$PRIO"\
#o  || /vendor/bin/swapon /dev$ZRAM -p "$PRIO"\
#o  || /system/vendor/bin/swapon /dev$ZRAM -p "$PRIO"\
#o  || swapon /dev$ZRAM
fi

# wait
until [ "`getprop sys.boot_completed`" == 1 ]; do
  sleep 1
done

# swappiness
FILE=/proc/sys/vm/swappiness
SWPSDEF=`cat $FILE`
SWPS=
[ "$SWPS" ] && echo "$SWPS" > $FILE

# swap_ratio_enable
FILE=/proc/sys/vm/swap_ratio_enable
SWPREDEF=`cat $FILE`
SWPRE=
[ "$SWPRE" ] && echo "$SWPRE" > $FILE

# swap_ratio
FILE=/proc/sys/vm/swap_ratio
SWPRDEF=`cat $FILE`
SWPR=
[ "$SWPR" ] && echo "$SWPR" > $FILE

# min_free_kbytes
FILE=/proc/sys/vm/min_free_kbytes
MFKBDEF=`cat $FILE`
MFKB=
[ "$MFKB" ] && echo "$MFKB" > $FILE

# extra_free_kbytes
FILE=/proc/sys/vm/extra_free_kbytes
EFKBDEF=`cat $FILE`
EFKB=
[ "$EFKB" ] && echo "$EFKB" > $FILE

# prop
NAME=swap_free_low_percentage
SFLPDEF=`getprop ro.lmk.$NAME`
SFLP=
if [ "$SFLP" ]; then
  resetprop -n ro.lmk.$NAME "$SFLP"
  device_config delete lmkd_native $NAME
  resetprop -p --delete persist.device_config.lmkd_native.$NAME
fi
NAME=swap_util_max
SUMDEF=`getprop ro.lmk.$NAME`
SUM=
if [ "$SUM" ]; then
  resetprop -n ro.lmk.$NAME "$SUM"
  device_config delete lmkd_native $NAME
  resetprop -p --delete persist.device_config.lmkd_native.$NAME
fi
NAME=swap_compression_ratio
SCRDEF=`getprop ro.lmk.$NAME`
SCR=
if [ "$SCR" ]; then
  resetprop -n ro.lmk.$NAME "$SCR"
  device_config delete lmkd_native $NAME
  resetprop -p --delete persist.device_config.lmkd_native.$NAME
fi
NAME=medium
MEDDEF==`getprop ro.lmk.$NAME`
MED=
if [ "$MED" ]; then
  resetprop -n ro.lmk.$NAME "$MED"
  device_config delete lmkd_native $NAME
  resetprop -p --delete persist.device_config.lmkd_native.$NAME
fi
if [ "$SFLP" ] || [ "$SUM" ]\
|| [ "$SCR" ] || [ "$MED" ]; then
  resetprop lmkd.reinit 1
fi





