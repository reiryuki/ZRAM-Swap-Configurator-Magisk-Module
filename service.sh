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
[ "$SWAPOFF" == true ] && echo 1 > /sys$ZRAM/reset
ALGODEF=`cat /sys$ZRAM/comp_algorithm`
ALGO=
[ "$ALGO" ] && echo "$ALGO" > /sys$ZRAM/comp_algorithm
PRIO=
#oif [ "$SWAPOFF" == true ]; then
#o  echo "$DISKSIZE" > /sys$ZRAM/disksize
#o  mkswap /dev$ZRAM
#o  /system/bin/swapon /dev$ZRAM -p "$PRIO"\
#o  || /vendor/bin/swapon /dev$ZRAM -p "$PRIO"\
#o  || /system/vendor/bin/swapon /dev$ZRAM -p "$PRIO"\
#o  || swapon /dev$ZRAM
#ofi

# wait
until [ "`getprop sys.boot_completed`" == 1 ]; do
  sleep 1
done

# swappiness
SWPSDEF=`cat /proc/sys/vm/swappiness`
SWPS=
[ "$SWPS" ] && echo "$SWPS" > /proc/sys/vm/swappiness

# swap_ratio_enable
SWPREDEF=`cat /proc/sys/vm/swap_ratio_enable`
SWPRE=
[ "$SWPRE" ] && echo "$SWPRE" > /proc/sys/vm/swap_ratio_enable

# swap_ratio
SWPRDEF=`cat /proc/sys/vm/swap_ratio`
SWPR=
[ "$SWPR" ] && echo "$SWPR" > /proc/sys/vm/swap_ratio

# min_free_kbytes
MFKBDEF=`cat /proc/sys/vm/min_free_kbytes`
MFKB=
[ "$MFKB" ] && echo "$MFKB" > /proc/sys/vm/min_free_kbytes

# extra_free_kbytes
EFKBDEF=`cat /proc/sys/vm/extra_free_kbytes`
EFKB=
[ "$EFKB" ] && echo "$EFKB" > /proc/sys/vm/extra_free_kbytes

# prop
SFLPDEF=`getprop ro.lmk.swap_free_low_percentage`
SFLP=
SUMDEF=`getprop ro.lmk.swap_util_max`
SUM=
SCRDEF=`getprop ro.lmk.swap_compression_ratio`
SCR=
if [ "$SFLP" ]; then
  resetprop -n ro.lmk.swap_free_low_percentage "$SFLP"
  device_config delete lmkd_native swap_free_low_percentage
  resetprop -p --delete persist.device_config.lmkd_native.swap_free_low_percentage
fi
if [ "$SUM" ]; then
  resetprop -n ro.lmk.swap_util_max "$SUM"
  device_config delete lmkd_native swap_util_max
  resetprop -p --delete persist.device_config.lmkd_native.swap_util_max
fi
if [ "$SCR" ]; then
  resetprop -n ro.lmk.swap_compression_ratio "$SCR"
  device_config delete lmkd_native swap_compression_ratio
  resetprop -p --delete persist.device_config.lmkd_native.swap_compression_ratio
fi
if [ "$SFLP" ] || [ "$SUM" ] || [ "$SCR" ]; then
  resetprop lmkd.reinit 1
fi





