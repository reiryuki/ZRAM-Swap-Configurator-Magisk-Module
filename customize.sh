# space
ui_print " "

# var
UID=`id -u`
[ ! "$UID" ] && UID=0
DEFFILE=/data/adb/modules/$MODID/debug.log
LMKD=/system/bin/lmkd

# log
if [ "$BOOTMODE" != true ]; then
  FILE=/data/media/"$UID"/$MODID\_recovery.log
  ui_print "- Log will be saved at $FILE"
  exec 2>$FILE
  ui_print " "
fi

# optionals
OPTIONALS=/data/media/"$UID"/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# debug
if [ "`grep_prop debug.log $OPTIONALS`" == 1 ]; then
  ui_print "- The install log will contain detailed information"
  set -x
  ui_print " "
fi

# recovery
if [ "$BOOTMODE" != true ]; then
  MODPATH_UPDATE=`echo $MODPATH | sed 's|modules/|modules_update/|g'`
  rm -f $MODPATH/update
  rm -rf $MODPATH_UPDATE
fi

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
if [ "$KSU" == true ]; then
  ui_print " KSUVersion=$KSU_VER"
  ui_print " KSUVersionCode=$KSU_VER_CODE"
  ui_print " KSUKernelVersionCode=$KSU_KERNEL_VER_CODE"
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# cleaning
rm -rf $MODPATH/image

# free
ui_print "- Current free:"
/system/bin/free
ui_print " "

# swaps
FILE=/proc/swaps
ui_print "- Current $FILE:"
cat $FILE
ui_print " "

# disksize
VAL=`grep_prop zram.resize $OPTIONALS`
ZRAM=/block/zram0
FILE=/sys$ZRAM/disksize
FILE2=/sys$ZRAM/comp_algorithm
CUR=`cat $FILE`
CUR2=`cat $FILE2`
ui_print "- Current $FILE"
ui_print "  = $CUR Byte"
ui_print " "
ui_print "- Current $FILE2"
ui_print "  = $CUR2"
ui_print " "
if [ "$VAL" == 0 ]; then
  ui_print "- Disables ZRAM Swap."
  if [ "$BOOTMODE" == true ]; then
    ui_print "  This change requires reboot."
  fi
  ui_print " "
else
  MemTotal=`awk '/MemTotal/ {print $2}' /proc/meminfo`
  ui_print "- Changes $FILE"
  sed -i 's|#o||g' $MODPATH/service.sh
  if echo "$VAL" | grep -q %; then
    ui_print "  to $VAL of RAM size."
    VAL=`echo "$VAL" | sed 's|%||g'`
    let RES="$MemTotal * $VAL / 100 * 1024"
    ui_print "  ($RES Byte)"
    sed -i "s|VAR|$VAL|g" $MODPATH/service.sh
    sed -i 's|#%||g' $MODPATH/service.sh
  elif [ "$VAL" ]; then
    ui_print "  to $VAL Byte."
    sed -i "s|DISKSIZE=|DISKSIZE=$VAL|g" $MODPATH/service.sh
  else
    ui_print "  to 100% of RAM size."
    let RES="$MemTotal * 1024"
    ui_print "  ($RES Byte)"
    sed -i "s|VAR|100|g" $MODPATH/service.sh
    sed -i 's|#%||g' $MODPATH/service.sh
  fi
  if [ "$BOOTMODE" == true ]; then
    ui_print "  This change requires reboot."
  fi
  ui_print " "
  VAL=`grep_prop zram.algo $OPTIONALS`
  if [ "$VAL" ]; then
    if grep -q "$VAL" $FILE2; then
      ui_print "- Changes $FILE2"
      ui_print "  to $VAL"
      if [ "$BOOTMODE" == true ]; then
        ui_print "  This change requires reboot."
      fi
      sed -i "s|ALGO=|ALGO=$VAL|g" $MODPATH/service.sh
    else
      ui_print "! $VAL is unsupported"
      ui_print "  in $FILE2"
    fi
    ui_print " "
  fi
  VAL=`grep_prop zram.prio $OPTIONALS`
  if [ "$VAL" ]; then
    ui_print "- Sets swap priority to $VAL"
    sed -i "s|PRIO=|PRIO=$VAL|g" $MODPATH/service.sh
  else
    ui_print "- Sets swap priority to 0"
    sed -i 's|PRIO=|PRIO=0|g' $MODPATH/service.sh
  fi
  if [ "$BOOTMODE" == true ]; then
    ui_print "  This change requires reboot."
  fi
  ui_print " "
fi

# default
if [ "$BOOTMODE" == true ]; then
  mkdir -p `dirname $DEFFILE`
  FILE=/proc/sys/vm/swappiness
  if [ -f $FILE ] && ! grep -q SWPSDEF= $DEFFILE; then
    echo "+ SWPSDEF=`cat $FILE`" >> $DEFFILE
  fi
  FILE=/proc/sys/vm/swap_ratio_enable
  if [ -f $FILE ] && ! grep -q SWPREDEF= $DEFFILE; then
    echo "+ SWPREDEF=`cat $FILE`" >> $DEFFILE
  fi
  FILE=/proc/sys/vm/swap_ratio
  if [ -f $FILE ] && ! grep -q SWPRDEF= $DEFFILE; then
    echo "+ SWPRDEF=`cat $FILE`" >> $DEFFILE
  fi
  FILE=/proc/sys/vm/min_free_kbytes
  if [ -f $FILE ] && ! grep -q MFKBDEF= $DEFFILE; then
    echo "+ MFKBDEF=`cat $FILE`" >> $DEFFILE
  fi
  FILE=/proc/sys/vm/extra_free_kbytes
  if [ -f $FILE ] && ! grep -q EFKBDEF= $DEFFILE; then
    echo "+ EFKBDEF=`cat $FILE`" >> $DEFFILE
  fi
  NAME=swap_free_low_percentage
  PROP=persist.device_config.lmkd_native.$NAME
  PROP2=ro.lmk.$NAME
  if ! grep -q $PROP $LMKD\
  && grep -q $PROP2 $LMKD; then
    PROP=$PROP2
  fi
  CUR=`getprop $PROP`
  if [ "$CUR" ] && ! grep -q SFLPDEF= $DEFFILE; then
    echo "+ SFLPDEF=$CUR" >> $DEFFILE
  fi
  NAME=swap_util_max
  PROP=persist.device_config.lmkd_native.$NAME
  PROP2=ro.lmk.$NAME
  if ! grep -q $PROP $LMKD\
  && grep -q $PROP2 $LMKD; then
    PROP=$PROP2
  fi
  CUR=`getprop $PROP`
  if [ "$CUR" ] && ! grep -q SUMDEF= $DEFFILE; then
    echo "+ SUMDEF=$CUR" >> $DEFFILE
  fi
  NAME=swap_compression_ratio
  PROP=persist.device_config.lmkd_native.$NAME
  PROP2=ro.lmk.$NAME
  if ! grep -q $PROP $LMKD\
  && grep -q $PROP2 $LMKD; then
    PROP=$PROP2
  fi
  CUR=`getprop $PROP`
  if [ "$CUR" ] && ! grep -q SCRDEF= $DEFFILE; then
    echo "+ SCRDEF=$CUR" >> $DEFFILE
  fi
  NAME=swap_compression_ratio_div
  PROP=persist.device_config.lmkd_native.$NAME
  PROP2=ro.lmk.$NAME
  if ! grep -q $PROP $LMKD\
  && grep -q $PROP2 $LMKD; then
    PROP=$PROP2
  fi
  CUR=`getprop $PROP`
  if [ "$CUR" ] && ! grep -q SCRDDEF= $DEFFILE; then
    echo "+ SCRDDEF=$CUR" >> $DEFFILE
  fi
  NAME=medium
  PROP=persist.device_config.lmkd_native.$NAME
  PROP2=ro.lmk.$NAME
  if ! grep -q $PROP $LMKD\
  && grep -q $PROP2 $LMKD; then
    PROP=$PROP2
  fi
  CUR=`getprop $PROP`
  if [ "$CUR" ] && ! grep -q MEDDEF= $DEFFILE; then
    echo "+ MEDDEF=$CUR" >> $DEFFILE
  fi
  NAME=low
  PROP=persist.device_config.lmkd_native.$NAME
  PROP2=ro.lmk.$NAME
  if ! grep -q $PROP $LMKD\
  && grep -q $PROP2 $LMKD; then
    PROP=$PROP2
  fi
  CUR=`getprop $PROP`
  if [ "$CUR" ] && ! grep -q LOWDEF= $DEFFILE; then
    echo "+ LOWDEF=$CUR" >> $DEFFILE
  fi
fi

# swappiness
VAL=`grep_prop zram.swps $OPTIONALS`
if [ "$VAL" ]; then
  if [ "$VAL" -gt 100 ]; then
    VAL=100
  elif [ "$VAL" -lt 0 ]; then
    unset VAL
  fi
fi
FILE=/proc/sys/vm/swappiness
CUR=`cat $FILE`
ui_print "- Current $FILE"
ui_print "  = $CUR"
ui_print " "
if [ "$VAL" == def ]; then
  if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
    SWPSDEF=`awk '/SWPSDEF/ {print $2}' $DEFFILE | sed 's|SWPSDEF=||g'`
    if [ "$SWPSDEF" ] && [ "$SWPSDEF" != "$CUR" ]; then
      ui_print "- Restores $FILE"
      ui_print "  to default ROM setting ($SWPSDEF)"
      echo "$SWPSDEF" > $FILE
      ui_print "  This change does not require reboot."
      ui_print " "
    fi
  fi
else
  if [ -f $FILE ]; then
    ui_print "- Changes $FILE"
    if [ "$VAL" ]; then
      ui_print "  to $VAL"
      [ "$BOOTMODE" == true ] && echo "$VAL" > $FILE
      sed -i "s|SWPS=|SWPS=$VAL|g" $MODPATH/service.sh
    else
      ui_print "  to 100"
      [ "$BOOTMODE" == true ] && echo 100 > $FILE
      sed -i 's|SWPS=|SWPS=100|g' $MODPATH/service.sh
    fi
    if [ "$BOOTMODE" == true ]; then
      ui_print "  This change does not require reboot."
    fi
    ui_print " "
  else
    ui_print "- This kernel does not support"
    ui_print "  $FILE"
    ui_print " "
  fi
fi

# swap_ratio_enable & swap_ratio
VAL=`grep_prop zram.swpre $OPTIONALS`
FILE=/proc/sys/vm/swap_ratio_enable
FILE2=/proc/sys/vm/swap_ratio
CUR=`cat $FILE`
CUR2=`cat $FILE2`
ui_print "- Current $FILE"
ui_print "  = $CUR"
ui_print " "
ui_print "- Current $FILE2"
ui_print "  = $CUR2"
ui_print " "
if [ "$VAL" == 0 ]; then
  if [ -f $FILE ]; then
    ui_print "- Changes $FILE"
    ui_print "  to 0"
    [ "$BOOTMODE" == true ] && echo 0 > $FILE
    sed -i 's|SWPRE=|SWPRE=0|g' $MODPATH/service.sh
    if [ "$BOOTMODE" == true ]; then
      ui_print "  This change does not require reboot."
    fi
    ui_print " "
  else
    ui_print "- This kernel does not support"
    ui_print "  $FILE"
    ui_print " "
  fi
elif [ "$VAL" == 1 ]; then
  if [ -f $FILE ]; then
    ui_print "- Changes $FILE"
    ui_print "  to 1"
    [ "$BOOTMODE" == true ] && echo 1 > $FILE
    sed -i 's|SWPRE=|SWPRE=1|g' $MODPATH/service.sh
    if [ "$BOOTMODE" == true ]; then
      ui_print "  This change does not require reboot."
    fi
    ui_print " "
    VAL=`grep_prop zram.swpr $OPTIONALS`
    if [ "$VAL" ]; then
      if [ "$VAL" -gt 100 ]; then
        VAL=100
      elif [ "$VAL" -lt 0 ]; then
        unset VAL
      fi
    fi
    if [ "$VAL" ] && [ "$VAL" != def ]; then
      if [ -f $FILE2 ]; then
        ui_print "- Changes $FILE2"
        ui_print "  to $VAL"
        [ "$BOOTMODE" == true ] && echo "$VAL" > $FILE2
        sed -i "s|SWPR=|SWPR=$VAL|g" $MODPATH/service.sh
        if [ "$BOOTMODE" == true ]; then
          ui_print "  This change does not require reboot."
        fi
        ui_print " "
      else
        ui_print "- This kernel does not support"
        ui_print "  $FILE2"
        ui_print " "
      fi
    else
      if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
        SWPRDEF=`awk '/SWPRDEF/ {print $2}' $DEFFILE | sed 's|SWPRDEF=||g'`
        if [ "$SWPRDEF" ] && [ "$SWPRDEF" != "$CUR2" ]; then
          ui_print "- Restores $FILE2"
          ui_print "  to default ROM setting ($SWPRDEF)"
          echo "$SWPRDEF" > $FILE2
          ui_print "  This change does not require reboot."
          ui_print " "
        fi
      fi
    fi
  else
    ui_print "- This kernel does not support"
    ui_print "  $FILE"
    ui_print " "
  fi
else
  if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
    SWPREDEF=`awk '/SWPREDEF/ {print $2}' $DEFFILE | sed 's|SWPREDEF=||g'`
    if [ "$SWPREDEF" ] && [ "$SWPREDEF" != "$CUR" ]; then
      ui_print "- Restores $FILE"
      ui_print "  to default ROM setting ($SWPREDEF)"
      echo "$SWPREDEF" > $FILE
      ui_print "  This change does not require reboot."
      ui_print " "
    fi
  fi
fi

# swap_free_low_percentage
VAL=`grep_prop zram.sflp $OPTIONALS`
if [ "$VAL" ]; then
  if [ "$VAL" -gt 100 ]; then
    VAL=100
  elif [ "$VAL" -lt 0 ]; then
    unset VAL
  fi
fi
NAME=swap_free_low_percentage
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
ui_print "- Current $PROP"
ui_print "  = $CUR"
ui_print " "
if [ "$VAL" ] && [ "$VAL" != def ]; then
  if grep -q $PROP $LMKD; then
    ui_print "- Changes $PROP"
    ui_print "  to $VAL"
    if [ "$BOOTMODE" == true ]; then
      resetprop -p --delete $PROP
      resetprop -n $PROP "$VAL"
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
    fi
    sed -i "s|SFLP=|SFLP=$VAL|g" $MODPATH/service.sh
    ui_print " "
  else
    ui_print "- This ROM does not support"
    ui_print "  lmk $NAME parameter"
    ui_print " "
  fi
else
  if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
    SFLPDEF=`awk '/SFLPDEF/ {print $2}' $DEFFILE | sed 's|SFLPDEF=||g'`
    if [ "$SFLPDEF" != "$CUR" ]; then
      ui_print "- Restores $PROP"
      ui_print "  to default ROM setting ($SFLPDEF)"
      resetprop -p --delete $PROP
      if [ "$SFLPDEF" ]; then
        resetprop -n $PROP "$SFLPDEF"
      fi
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
      ui_print " "
    fi
  fi
fi

# swap_util_max
VAL=`grep_prop zram.sum $OPTIONALS`
if [ "$VAL" ]; then
  if [ "$VAL" -gt 100 ]; then
    VAL=100
  elif [ "$VAL" -lt 0 ]; then
    unset VAL
  fi
fi
NAME=swap_util_max
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
ui_print "- Current $PROP"
ui_print "  = $CUR"
ui_print " "
if [ "$VAL" ] && [ "$VAL" != def ]; then
  if grep -q $PROP $LMKD; then
    ui_print "- Changes $PROP"
    ui_print "  to $VAL"
    if [ "$BOOTMODE" == true ]; then
      resetprop -p --delete $PROP
      resetprop -n $PROP "$VAL"
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
    fi
    sed -i "s|SUM=|SUM=$VAL|g" $MODPATH/service.sh
    ui_print " "
  else
    ui_print "- This ROM does not support"
    ui_print "  lmk $NAME parameter"
    ui_print " "
  fi
else
  if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
    SUMDEF=`awk '/SUMDEF/ {print $2}' $DEFFILE | sed 's|SUMDEF=||g'`
    if [ "$SUMDEF" != "$CUR" ]; then
      ui_print "- Restores $PROP"
      ui_print "  to default ROM setting ($SUMDEF)"
      resetprop -p --delete $PROP
      if [ "$SUMDEF" ]; then
        resetprop -n $PROP "$SUMDEF"
      fi
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
      ui_print " "
    fi
  fi
fi

# swap_compression_ratio
VAL=`grep_prop zram.scr $OPTIONALS`
if [ "$VAL" ]; then
  if [ "$VAL" -gt 100 ]; then
    VAL=100
  elif [ "$VAL" -lt 0 ]; then
    VAL=0
  fi
fi
NAME=swap_compression_ratio
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
ui_print "- Current $PROP"
ui_print "  = $CUR"
ui_print " "
if [ "$VAL" ] && [ "$VAL" != def ]; then
  if grep -q $PROP $LMKD; then
    ui_print "- Changes $PROP"
    ui_print "  to $VAL"
    if [ "$BOOTMODE" == true ]; then
      resetprop -p --delete $PROP
      resetprop -n $PROP "$VAL"
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
    fi
    sed -i "s|SCR=|SCR=$VAL|g" $MODPATH/service.sh
    ui_print " "
  else
    ui_print "- This ROM does not support"
    ui_print "  lmk $NAME parameter"
    ui_print " "
  fi
else
  if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
    SCRDEF=`awk '/SCRDEF/ {print $2}' $DEFFILE | sed 's|SCRDEF=||g'`
    if [ "$SCRDEF" != "$CUR" ]; then
      ui_print "- Restores $PROP"
      ui_print "  to default ROM setting ($SCRDEF)"
      resetprop -p --delete $PROP
      if [ "$SCRDEF" ]; then
        resetprop -n $PROP "$SCRDEF"
      fi
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
      ui_print " "
    fi
  fi
fi

# swap_compression_ratio_div
VAL=`grep_prop zram.scrd $OPTIONALS`
if [ "$VAL" ]; then
  if [ "$VAL" -gt 100 ]; then
    VAL=100
  elif [ "$VAL" -lt 1 ]; then
    VAL=1
  fi
fi
NAME=swap_compression_ratio_div
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
ui_print "- Current $PROP"
ui_print "  = $CUR"
ui_print " "
if [ "$VAL" ] && [ "$VAL" != def ]; then
  if grep -q $PROP $LMKD; then
    ui_print "- Changes $PROP"
    ui_print "  to $VAL"
    if [ "$BOOTMODE" == true ]; then
      resetprop -p --delete $PROP
      resetprop -n $PROP "$VAL"
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
    fi
    sed -i "s|SCRD=|SCRD=$VAL|g" $MODPATH/service.sh
    ui_print " "
  else
    ui_print "- This ROM does not support"
    ui_print "  lmk $NAME parameter"
    ui_print " "
  fi
else
  if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
    SCRDDEF=`awk '/SCRDDEF/ {print $2}' $DEFFILE | sed 's|SCRDDEF=||g'`
    if [ "$SCRDDEF" != "$CUR" ]; then
      ui_print "- Restores $PROP"
      ui_print "  to default ROM setting ($SCRDDEF)"
      resetprop -p --delete $PROP
      if [ "$SCRDDEF" ]; then
        resetprop -n $PROP "$SCRDDEF"
      fi
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
      ui_print " "
    fi
  fi
fi

# min_free_kbytes
VAL=`grep_prop zram.mfkb $OPTIONALS`
if [ "$VAL" ]; then
  if [ "$VAL" -lt 0 ]; then
    unset VAL
  fi
fi
FILE=/proc/sys/vm/min_free_kbytes
CUR=`cat $FILE`
ui_print "- Current $FILE"
ui_print "  = $CUR"
ui_print " "
if [ "$VAL" ] && [ "$VAL" != def ]; then
  if [ -f $FILE ]; then
    ui_print "- Changes $FILE"
    ui_print "  to $VAL"
    [ "$BOOTMODE" == true ] && echo "$VAL" > $FILE
    sed -i "s|MFKB=|MFKB=$VAL|g" $MODPATH/service.sh
    if [ "$BOOTMODE" == true ]; then
      ui_print "  This change does not require reboot."
    fi
    ui_print " "
  else
    ui_print "- This kernel does not support"
    ui_print "  $FILE"
    ui_print " "
  fi
else
  if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
    MFKBDEF=`awk '/MFKBDEF/ {print $2}' $DEFFILE | sed 's|MFKBDEF=||g'`
    if [ "$MFKBDEF" ] && [ "$MFKBDEF" != "$CUR" ]; then
      ui_print "- Restores $FILE"
      ui_print "  to default ROM setting ($MFKBDEF)"
      echo "$MFKBDEF" > $FILE
      ui_print "  This change does not require reboot."
      ui_print " "
    fi
  fi
fi

# extra_free_kbytes
VAL=`grep_prop zram.efkb $OPTIONALS`
if [ "$VAL" ]; then
  if [ "$VAL" -lt 0 ]; then
    unset VAL
  fi
fi
FILE=/proc/sys/vm/extra_free_kbytes
CUR=`cat $FILE`
ui_print "- Current $FILE"
ui_print "  = $CUR"
ui_print " "
if [ "$VAL" ] && [ "$VAL" != def ]; then
  if [ -f $FILE ]; then
    ui_print "- Changes $FILE"
    ui_print "  to $VAL"
    [ "$BOOTMODE" == true ] && echo "$VAL" > $FILE
    sed -i "s|EFKB=|EFKB=$VAL|g" $MODPATH/service.sh
    if [ "$BOOTMODE" == true ]; then
      ui_print "  This change does not require reboot."
    fi
    ui_print " "
  else
    ui_print "- This kernel does not support"
    ui_print "  $FILE"
    ui_print " "
  fi
else
  if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
    EFKBDEF=`awk '/EFKBDEF/ {print $2}' $DEFFILE | sed 's|EFKBDEF=||g'`
    if [ "$EFKBDEF" ] && [ "$EFKBDEF" != "$CUR" ]; then
      ui_print "- Restores $FILE"
      ui_print "  to default ROM setting ($EFKBDEF)"
      echo "$EFKBDEF" > $FILE
      ui_print "  This change does not require reboot."
      ui_print " "
    fi
  fi
fi

# medium
VAL=`grep_prop zram.med $OPTIONALS`
NAME=medium
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
ui_print "- Current $PROP"
ui_print "  = $CUR"
ui_print " "
if [ "$VAL" ] && [ "$VAL" != def ]; then
  if grep -q $PROP $LMKD; then
    ui_print "- Changes $PROP"
    ui_print "  to $VAL"
    if [ "$BOOTMODE" == true ]; then
      resetprop -p --delete $PROP
      resetprop -n $PROP "$VAL"
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
    fi
    sed -i "s|MED=|MED=$VAL|g" $MODPATH/service.sh
    ui_print " "
  else
    ui_print "- This ROM does not support"
    ui_print "  lmk $NAME parameter"
    ui_print " "
  fi
else
  if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
    MEDDEF=`awk '/MEDDEF/ {print $2}' $DEFFILE | sed 's|MEDDEF=||g'`
    if [ "$MEDDEF" != "$CUR" ]; then
      ui_print "- Restores $PROP"
      ui_print "  to default ROM setting ($MEDDEF)"
      resetprop -p --delete $PROP
      if [ "$MEDDEF" ]; then
        resetprop -n $PROP "$MEDDEF"
      fi
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
      ui_print " "
    fi
  fi
fi

# low
VAL=`grep_prop zram.low $OPTIONALS`
NAME=low
PROP=persist.device_config.lmkd_native.$NAME
PROP2=ro.lmk.$NAME
if ! grep -q $PROP $LMKD\
&& grep -q $PROP2 $LMKD; then
  PROP=$PROP2
fi
CUR=`getprop $PROP`
ui_print "- Current $PROP"
ui_print "  = $CUR"
ui_print " "
if [ "$VAL" ] && [ "$VAL" != def ]; then
  if grep -q $PROP $LMKD; then
    ui_print "- Changes $PROP"
    ui_print "  to $VAL"
    if [ "$BOOTMODE" == true ]; then
      resetprop -p --delete $PROP
      resetprop -n $PROP "$VAL"
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
    fi
    sed -i "s|LOW=|LOW=$VAL|g" $MODPATH/service.sh
    ui_print " "
  else
    ui_print "- This ROM does not support"
    ui_print "  lmk $NAME parameter"
    ui_print " "
  fi
else
  if [ "$BOOTMODE" == true ] && [ -f $DEFFILE ]; then
    LOWDEF=`awk '/LOWDEF/ {print $2}' $DEFFILE | sed 's|LOWDEF=||g'`
    if [ "$LOWDEF" != "$CUR" ]; then
      ui_print "- Restores $PROP"
      ui_print "  to default ROM setting ($LOWDEF)"
      resetprop -p --delete $PROP
      if [ "$LOWDEF" ]; then
        resetprop -n $PROP "$LOWDEF"
      fi
      resetprop lmkd.reinit 1
      ui_print "  This change does not require reboot."
      ui_print " "
    fi
  fi
fi

# copy
if [ "$BOOTMODE" == true ]; then
  mkdir -p `dirname $DEFFILE`
  cp -f $MODPATH/action.sh `dirname $DEFFILE`
fi

# space
ui_print " "
ui_print " "
ui_print " "
ui_print " "
ui_print " "
ui_print " "
ui_print " "
ui_print " "
ui_print " "
ui_print " "





