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
DEF_SWPS=`cat /proc/sys/vm/swappiness`
SWPS=100
echo "$SWPS" > /proc/sys/vm/swappiness

# swap_ratio_enable
DEF_SWPRE=`cat /proc/sys/vm/swap_ratio_enable`
SWPRE=1
echo "$SWPRE" > /proc/sys/vm/swap_ratio_enable

# swap_ratio
DEF_SWPR=`cat /proc/sys/vm/swap_ratio`
SWPR=100
echo "$SWPR" > /proc/sys/vm/swap_ratio

# zram
DEF_DISKSIZE=`cat /sys$ZRAM/disksize`
DISKSIZE=3G
#%MemTotalStr=`cat /proc/meminfo | grep MemTotal`
#%MemTotal=${MemTotalStr:16:8}
#%let VALUE="$MemTotal * VAR / 100"
#%DISKSIZE=$VALUE\K
swapoff /dev$ZRAM
echo 1 > /sys$ZRAM/reset
DEF_ALGO=`cat /sys$ZRAM/comp_algorithm`
ALGO=
if [ "$ALGO" ]; then
  echo "$ALGO" > /sys$ZRAM/comp_algorithm
fi
#oecho "$DISKSIZE" > /sys$ZRAM/disksize
#omkswap /dev$ZRAM
PRIO=0
#o/system/bin/swapon /dev$ZRAM -p "$PRIO"\
#o|| /vendor/bin/swapon /dev$ZRAM -p "$PRIO"\
#o|| /system/vendor/bin/swapon /dev$ZRAM -p "$PRIO"\
#o|| swapon /dev$ZRAM

# function
lmk_prop() {
resetprop -n ro.lmk.swap_free_low_percentage "$SFLP"
resetprop -n ro.lmk.swap_util_max "$SUM"
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
if [ "$DEF" != null ] || [ "$DEF2" ]\
|| [ "$DEF3" != null ] || [ "$DEF4" ]; then
  device_config delete lmkd_native swap_free_low_percentage
  resetprop -p --delete persist.device_config.lmkd_native.swap_free_low_percentage
  device_config delete lmkd_native swap_util_max
  resetprop -p --delete persist.device_config.lmkd_native.swap_util_max
  resetprop lmkd.reinit 1
fi
sleep 300
lmk_config
}

# prop
DEF_SFLP=`getprop ro.lmk.swap_free_low_percentage`
SFLP=0
DEF_SUM=`getprop ro.lmk.swap_util_max`
SUM=100
lmk_prop
lmk_config










