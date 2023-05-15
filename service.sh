MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# debug
exec 2>$MODPATH/debug.log
set -x

# disable zram
swapoff /dev/block/zram0

# wait
until [ "`getprop sys.boot_completed`" == "1" ]; do
  sleep 1
done

# zram
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
#oecho "$ZRAM" > /sys/block/zram0/disksize
#omkswap /dev/block/zram0
#oswapon /dev/block/zram0













