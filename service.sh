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
DEF=`cat /proc/sys/vm/swappiness`
SWPS=100
echo "$SWPS" > /proc/sys/vm/swappiness

# swap_ratio_enable
DEF=`cat /proc/sys/vm/swap_ratio_enable`
SWPRE=1
echo "$SWPRE" > /proc/sys/vm/swap_ratio_enable

# swap_ratio
DEF=`cat /proc/sys/vm/swap_ratio`
SWPR=100
echo "$SWPR" > /proc/sys/vm/swap_ratio

# zram
DEF=`cat /sys$ZRAM/disksize`
DISKSIZE=3G
#%MemTotalStr=`cat /proc/meminfo | grep MemTotal`
#%MemTotal=${MemTotalStr:16:8}
#%let VALUE="$MemTotal * VAR / 100"
#%DISKSIZE=$VALUE\K
swapoff /dev$ZRAM
echo 1 > /sys$ZRAM/reset
DEF=`cat /sys$ZRAM/comp_algorithm`
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
resetprop lmkd.reinit 1
}
thrashing_limit_critical_prop() {
resetprop --delete ro.lmk.thrashing_limit_critical
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
thrashing_limit_critical_config() {
DEF=`device_config get lmkd_native thrashing_limit_critical`
DEF2=`getprop persist.device_config.lmkd_native.thrashing_limit_critical`
DEF3=`getprop persist.device_config.aconfig_flags.lmkd_native.thrashing_limit_critical`
if [ "$DEF" != null ] || [ "$DEF2" ] || [ "$DEF3" ]; then
  device_config delete lmkd_native thrashing_limit_critical
  resetprop -p --delete persist.device_config.lmkd_native.thrashing_limit_critical
  resetprop -p --delete persist.device_config.aconfig_flags.lmkd_native.thrashing_limit_critical
  resetprop lmkd.reinit 1
fi
}
lmk_config() {
stop_log
DEF=`device_config get lmkd_native swap_free_low_percentage`
DEF2=`getprop persist.device_config.lmkd_native.swap_free_low_percentage`
if [ "$DEF" != null ] || [ "$DEF2" ]; then
  device_config delete lmkd_native swap_free_low_percentage
  resetprop -p --delete persist.device_config.lmkd_native.swap_free_low_percentage
  resetprop lmkd.reinit 1
fi
#thrashing_limit_critical_config
sleep 300
lmk_config
}

# prop
DEF=`getprop ro.lmk.swap_free_low_percentage`
SFLP=0
lmk_prop
#thrashing_limit_critical_prop
lmk_config










