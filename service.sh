MODPATH=${0%/*}

# log
LOGFILE=$MODPATH/debug.log
exec 2>$LOGFILE
set -x

# disable zram
swapoff /dev/block/zram0

# wait
until [ "`getprop sys.boot_completed`" == 1 ]; do
  sleep 1
done

# default
DEF=`cat /sys/block/zram0/disksize`
DEF=`cat /sys/block/zram0/comp_algorithm`
DEF=`cat /proc/sys/vm/swappiness`
DEF=`getprop ro.lmk.swap_free_low_percentage`

# zram
ZRAM=3G
#%MemTotalStr=`cat /proc/meminfo | grep MemTotal`
#%MemTotal=${MemTotalStr:16:8}
#%let VALUE="$MemTotal * VAR / 100"
#%ZRAM=$VALUE\K
swapoff /dev/block/zram0
echo 1 > /sys/block/zram0/reset
ALGO=
if [ "$ALGO" ]; then
  echo "$ALGO" > /sys/block/zram0/comp_algorithm
fi
#oecho "$ZRAM" > /sys/block/zram0/disksize
#omkswap /dev/block/zram0
#oswapon /dev/block/zram0

# swappiness
SWPS=100
echo "$SWPS" > /proc/sys/vm/swappiness

# function
lmk_prop() {
resetprop -n ro.lmk.swap_free_low_percentage "$SFLP"
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
sleep 300
DEF=`device_config get lmkd_native swap_free_low_percentage`
DEF2=`getprop persist.device_config.lmkd_native.swap_free_low_percentage`
if [ "$DEF" != null ] || [ "$DEF2" ]; then
  device_config delete lmkd_native swap_free_low_percentage
  resetprop -p --delete persist.device_config.lmkd_native.swap_free_low_percentage
  resetprop lmkd.reinit 1
fi
lmk_config
}

# prop
SFLP=0
lmk_prop
lmk_config










