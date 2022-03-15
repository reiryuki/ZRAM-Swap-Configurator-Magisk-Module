(

mount /data
mount -o rw,remount /data
MODDIR=${0%/*}

# run
FILE=$MODDIR/sepolicy.sh
if [ -f $FILE ]; then
  sh $FILE
fi

# zram
chmod 0644 /sys/block/zram0/disksize
#1echo 1G > /sys/block/zram0/disksize
#2echo 2G > /sys/block/zram0/disksize
#3echo 3G > /sys/block/zram0/disksize
#4echo 4G > /sys/block/zram0/disksize
#75%MemTotalStr=`cat /proc/meminfo | grep MemTotal`
#75%MemTotal=${MemTotalStr:16:8}
#75%let ZRAM="$MemTotal * 3 / 4"
#75%echo $ZRAM\K > /sys/block/zram0/disksize

# cleaning
FILE=$MODDIR/cleaner.sh
if [ -f $FILE ]; then
  sh $FILE
  rm -f $FILE
fi

) 2>/dev/null


