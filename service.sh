(

MODPATH=${0%/*}

# debug
exec 2>$MODPATH/debug.log
set -x

# prevent soft reboot
echo 0 > /proc/sys/kernel/panic
echo 0 > /proc/sys/kernel/panic_on_oops
echo 0 > /proc/sys/kernel/panic_on_rcu_stall
echo 0 > /proc/sys/kernel/panic_on_warn
echo 0 > /proc/sys/vm/panic_on_oom

# wait
sleep 60

# zram
#1ZRAM=1G
#2ZRAM=2G
#3ZRAM=3G
#4ZRAM=4G
#75%MemTotalStr=`cat /proc/meminfo | grep MemTotal`
#75%MemTotal=${MemTotalStr:16:8}
#75%let VALUE="$MemTotal * 3 / 4"
#75%ZRAM=$VALUE\K
if [ "$ZRAM" ]; then
  swapoff /dev/block/zram0
  echo 1 > /sys/block/zram0/reset
  echo $ZRAM > /sys/block/zram0/disksize
  mkswap /dev/block/zram0
  swapon /dev/block/zram0
fi

# grant
PKG=me.kuder.diskinfo
pm grant $PKG android.permission.READ_EXTERNAL_STORAGE
pm grant $PKG android.permission.ACCESS_MEDIA_LOCATION

) 2>/dev/null


