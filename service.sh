MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# debug
exec 2>$MODPATH/debug.log
set -x

# wait
sleep 40

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

# wait
sleep 20

# grant
PKG=me.kuder.diskinfo
pm grant $PKG android.permission.READ_EXTERNAL_STORAGE
pm grant $PKG android.permission.ACCESS_MEDIA_LOCATION
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi


