MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# log
exec 2>$MODPATH/debug.log
set -x

# disable zram
swapoff /dev/block/zram0

# wait
until [ "`getprop sys.boot_completed`" == "1" ]; do
  sleep 1
done

# zram
DEF=`cat /sys/block/zram0/disksize`
DEF=`cat /sys/block/zram0/comp_algorithm`
DEF=`cat /proc/sys/vm/swappiness`
#ALGO=
#oZRAM=3G
#%MemTotalStr=`cat /proc/meminfo | grep MemTotal`
#%MemTotal=${MemTotalStr:16:8}
#%let VALUE="$MemTotal * VAR / 100"
#%ZRAM=$VALUE\K
swapoff /dev/block/zram0
echo 1 > /sys/block/zram0/reset
if [ "$ALGO" ]; then
  echo "$ALGO" > /sys/block/zram0/comp_algorithm
fi
#oecho 100 > /proc/sys/vm/swappiness
#oecho "$ZRAM" > /sys/block/zram0/disksize
#omkswap /dev/block/zram0
#oswapon /dev/block/zram0

# prop
resetprop ro.lmk.swap_free_low_percentage 1
resetprop --delete ro.lmk.thrashing_limit_critical
killall lmkd

# wait
sleep 240

# prop
resetprop -p --delete persist.device_config.lmkd_native.swap_free_low_percentage
resetprop -p --delete persist.device_config.lmkd_native.thrashing_limit_critical
killall lmkd












