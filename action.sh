# free
echo "- Free:"
/system/bin/free
echo " "

# swaps
FILE=/proc/swaps
echo "- $FILE:"
cat $FILE
echo " "

# disksize
ZRAM=/block/zram0
FILE=/sys$ZRAM/disksize
FILE2=/sys$ZRAM/comp_algorithm
CUR=`cat $FILE`
CUR2=`cat $FILE2`
echo "- $FILE = $CUR Byte"
echo " "
echo "- $FILE2 = $CUR2"
echo " "

# swappiness
FILE=/proc/sys/vm/swappiness
CUR=`cat $FILE`
echo "- $FILE = $CUR"
echo " "
if [ ! -f $FILE ]; then
  echo "- This kernel does not support"
  echo "  $FILE"
  echo " "
fi

# swap_ratio_enable
FILE=/proc/sys/vm/swap_ratio_enable
CUR=`cat $FILE`
echo "- $FILE = $CUR"
echo " "
if [ ! -f $FILE ]; then
  echo "- This kernel does not support"
  echo "  $FILE"
  echo " "
fi

# swap_ratio
FILE=/proc/sys/vm/swap_ratio
CUR=`cat $FILE`
echo "- $FILE = $CUR"
echo " "
if [ ! -f $FILE ]; then
  echo "- This kernel does not support"
  echo "  $FILE"
  echo " "
fi

# swap_free_low_percentage
NAME=swap_free_low_percentage
CUR=`getprop persist.device_config.lmkd_native.$NAME`
[ ! "$CUR" ] && CUR=`getprop ro.lmk.$NAME`
echo "- $NAME = $CUR"
echo " "
if ! grep -q ro.lmk.$NAME /system/bin/lmkd; then
  echo "- This ROM does not support"
  echo "  $NAME parameter"
  echo " "
fi

# swap_util_max
NAME=swap_util_max
CUR=`getprop persist.device_config.lmkd_native.$NAME`
[ ! "$CUR" ] && CUR=`getprop ro.lmk.$NAME`
echo "- $NAME = $CUR"
echo " "
if ! grep -q ro.lmk.$NAME /system/bin/lmkd; then
  echo "- This ROM does not support"
  echo "  $NAME parameter"
  echo " "
fi

# swap_compression_ratio
NAME=swap_compression_ratio
CUR=`getprop persist.device_config.lmkd_native.$NAME`
[ ! "$CUR" ] && CUR=`getprop ro.lmk.$NAME`
echo "- $NAME = $CUR"
echo " "
if ! grep -q ro.lmk.$NAME /system/bin/lmkd; then
  echo "- This ROM does not support"
  echo "  $NAME parameter"
  echo " "
fi

# min_free_kbytes
FILE=/proc/sys/vm/min_free_kbytes
CUR=`cat $FILE`
echo "- $FILE = $CUR"
echo " "
if [ ! -f $FILE ]; then
  echo "- This kernel does not support"
  echo "  $FILE"
  echo " "
fi

# extra_free_kbytes
FILE=/proc/sys/vm/extra_free_kbytes
CUR=`cat $FILE`
echo "- $FILE = $CUR"
echo " "
if [ ! -f $FILE ]; then
  echo "- This kernel does not support"
  echo "  $FILE"
  echo " "
fi







