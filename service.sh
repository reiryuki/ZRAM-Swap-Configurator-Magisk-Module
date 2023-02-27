MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# debug
exec 2>$MODPATH/debug.log
set -x

# wait
until [ "`getprop sys.boot_completed`" == "1" ]; do
  sleep 10
done

# zram
#oZRAM=2G
#1ZRAM=1G
#3ZRAM=3G
#4ZRAM=4G
#75%MemTotalStr=`cat /proc/meminfo | grep MemTotal`
#75%MemTotal=${MemTotalStr:16:8}
#75%let VALUE="$MemTotal * 3 / 4"
#75%ZRAM=$VALUE\K
#rMemTotalStr=`cat /proc/meminfo | grep MemTotal`
#rZRAM=${MemTotalStr:16:8}\K
swapoff /dev/block/zram0
echo 1 > /sys/block/zram0/reset
#oecho $ZRAM > /sys/block/zram0/disksize
#omkswap /dev/block/zram0
#oswapon /dev/block/zram0













