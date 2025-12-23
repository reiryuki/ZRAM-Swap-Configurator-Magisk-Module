MODPATH=${0%/*}

# log
LOGFILE=$MODPATH/debug.log
exec 2>$LOGFILE
set -x

# var
ZRAM=/block/zram0

# disable zram
swapoff /dev$ZRAM

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

# zram
DISKSIZEDEF=`cat /sys$ZRAM/disksize`
DISKSIZE=
#%MemTotalStr=`cat /proc/meminfo | grep MemTotal`
#%MemTotal=${MemTotalStr:16:8}
#%let VALUE="$MemTotal * VAR / 100"
#%DISKSIZE=$VALUE\K
swapoff /dev$ZRAM
echo 1 > /sys$ZRAM/reset
ALGODEF=`cat /sys$ZRAM/comp_algorithm`
ALGO=
[ "$ALGO" ] && echo "$ALGO" > /sys$ZRAM/comp_algorithm
#oecho "$DISKSIZE" > /sys$ZRAM/disksize
#omkswap /dev$ZRAM
PRIO=
#o/system/bin/swapon /dev$ZRAM -p "$PRIO"\
#o|| /vendor/bin/swapon /dev$ZRAM -p "$PRIO"\
#o|| /system/vendor/bin/swapon /dev$ZRAM -p "$PRIO"\
#o|| swapon /dev$ZRAM

# function
lmk_prop() {
[ "$SFLP" ] && resetprop -n ro.lmk.swap_free_low_percentage "$SFLP"
[ "$SUM" ] && resetprop -n ro.lmk.swap_util_max "$SUM"
[ "$SCR" ] && resetprop -n ro.lmk.swap_compression_ratio "$SCR"
resetprop lmkd.reinit 1
}
stop_log() {
SIZE=`du $LOGFILE | sed "s|$LOGFILE||g"`
if [ "$LOG" != stopped ] && [ "$SIZE" -gt 25 ]; then
  exec 2>/dev/null
  set +x
  LOG=stopped
fi
}
lmk_config() {
stop_log
DEF=`device_config get lmkd_native swap_free_low_percentage`
DEF2=`getprop persist.device_config.lmkd_native.swap_free_low_percentage`
DEF3=`device_config get lmkd_native swap_util_max`
DEF4=`getprop persist.device_config.lmkd_native.swap_util_max`
DEF5=`device_config get lmkd_native swap_compression_ratio`
DEF6=`getprop persist.device_config.lmkd_native.swap_compression_ratio`
if [ "$DEF" != null ] || [ "$DEF2" ]\
|| [ "$DEF3" != null ] || [ "$DEF4" ]\
|| [ "$DEF5" != null ] || [ "$DEF6" ]; then
  device_config delete lmkd_native swap_free_low_percentage
  resetprop -p --delete persist.device_config.lmkd_native.swap_free_low_percentage
  device_config delete lmkd_native swap_util_max
  resetprop -p --delete persist.device_config.lmkd_native.swap_util_max
  device_config delete lmkd_native swap_compression_ratio
  resetprop -p --delete persist.device_config.lmkd_native.swap_compression_ratio
  resetprop lmkd.reinit 1
fi
sleep 300
lmk_config
}

# prop
SFLPDEF=`getprop ro.lmk.swap_free_low_percentage`
SFLP=
SUMDEF=`getprop ro.lmk.swap_util_max`
SUM=
SCRDEF=`getprop ro.lmk.swap_compression_ratio`
SCR=
if [ "$SFLP" ] || [ "$SUM" ] || [ "$SCR" ]; then
  lmk_prop
  lmk_config
fi










