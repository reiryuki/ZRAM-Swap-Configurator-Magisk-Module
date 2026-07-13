#!/system/bin/sh

# var
LMKD=/system/bin/lmkd

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
echo "- $FILE"
echo "  = $CUR Byte"
echo " "
echo "- $FILE2"
echo "  = $CUR2"
echo " "

# swappiness
FILE=/proc/sys/vm/swappiness
CUR=`cat $FILE`
echo "- $FILE"
echo "  = $CUR"
echo " "
if [ ! -f $FILE ]; then
  echo "- This kernel does not support"
  echo "  $FILE"
  echo " "
fi

# swap_ratio_enable
FILE=/proc/sys/vm/swap_ratio_enable
CUR=`cat $FILE`
echo "- $FILE"
echo "  = $CUR"
echo " "
if [ ! -f $FILE ]; then
  echo "- This kernel does not support"
  echo "  $FILE"
  echo " "
fi

# swap_ratio
FILE=/proc/sys/vm/swap_ratio
CUR=`cat $FILE`
echo "- $FILE"
echo "  = $CUR"
echo " "
if [ ! -f $FILE ]; then
  echo "- This kernel does not support"
  echo "  $FILE"
  echo " "
fi

# swap_free_low_percentage
NAME=swap_free_low_percentage
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
echo "- $PROP"
echo "  = $CUR"
echo " "
if ! grep -q $PROP $LMKD; then
  echo "- This ROM does not support"
  echo "  lmk $NAME parameter"
  echo " "
fi

# swap_util_max
NAME=swap_util_max
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
echo "- $PROP"
echo "  = $CUR"
echo " "
if ! grep -q $PROP $LMKD; then
  echo "- This ROM does not support"
  echo "  lmk $NAME parameter"
  echo " "
fi

# swap_compression_ratio
NAME=swap_compression_ratio
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
echo "- $PROP"
echo "  = $CUR"
echo " "
if ! grep -q $PROP $LMKD; then
  echo "- This ROM does not support"
  echo "  lmk $NAME parameter"
  echo " "
fi

# swap_compression_ratio_div
NAME=swap_compression_ratio_div
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
echo "- $PROP"
echo "  = $CUR"
echo " "
if ! grep -q $PROP $LMKD; then
  echo "- This ROM does not support"
  echo "  lmk $NAME parameter"
  echo " "
fi

# min_free_kbytes
FILE=/proc/sys/vm/min_free_kbytes
CUR=`cat $FILE`
echo "- $FILE"
echo "  = $CUR"
echo " "
if [ ! -f $FILE ]; then
  echo "- This kernel does not support"
  echo "  $FILE"
  echo " "
fi

# extra_free_kbytes
FILE=/proc/sys/vm/extra_free_kbytes
CUR=`cat $FILE`
echo "- $FILE"
echo "  = $CUR"
echo " "
if [ ! -f $FILE ]; then
  echo "- This kernel does not support"
  echo "  $FILE"
  echo " "
fi

# medium
NAME=medium
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
echo "- $PROP"
echo "  = $CUR"
echo " "
if ! grep -q $PROP $LMKD; then
  echo "- This ROM does not support"
  echo "  lmk $NAME parameter"
  echo " "
fi

# low
NAME=low
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
echo "- $PROP"
echo "  = $CUR"
echo " "
if ! grep -q $PROP $LMKD; then
  echo "- This ROM does not support"
  echo "  lmk $NAME parameter"
  echo " "
fi

# space
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "





