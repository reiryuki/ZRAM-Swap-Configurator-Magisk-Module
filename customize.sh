# space
ui_print " "

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

# optionals
OPTIONALS=/sdcard/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# mount
if [ "$BOOTMODE" != true ]; then
  if [ -e /dev/block/bootdevice/by-name/vendor ]; then
    mount -o rw -t auto /dev/block/bootdevice/by-name/vendor /vendor
  else
    mount -o rw -t auto /dev/block/bootdevice/by-name/cust /vendor
  fi
  mount -o rw -t auto /dev/block/bootdevice/by-name/persist /persist
  mount -o rw -t auto /dev/block/bootdevice/by-name/metadata /metadata
fi

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# cleaning
ui_print "- Cleaning..."
rm -rf /metadata/magisk/$MODID
rm -rf /mnt/vendor/persist/magisk/$MODID
rm -rf /persist/magisk/$MODID
rm -rf /data/unencrypted/magisk/$MODID
rm -rf /cache/magisk/$MODID
ui_print " "

# function
permissive_2() {
sed -i '1i\
SELINUX=`getenforce`\
if [ "$SELINUX" == Enforcing ]; then\
  magiskpolicy --live "permissive *"\
fi\' $MODPATH/post-fs-data.sh
}
permissive() {
SELINUX=`getenforce`
if [ "$SELINUX" == Enforcing ]; then
  setenforce 0
  SELINUX=`getenforce`
  if [ "$SELINUX" == Enforcing ]; then
    ui_print "  Your device can't be turned to Permissive state."
    ui_print "  Using Magisk Permissive mode instead."
    permissive_2
  else
    setenforce 1
    sed -i '1i\
SELINUX=`getenforce`\
if [ "$SELINUX" == Enforcing ]; then\
  setenforce 0\
fi\' $MODPATH/post-fs-data.sh
  fi
fi
}

# permissive
if [ "`grep_prop permissive.mode $OPTIONALS`" == 1 ]; then
  ui_print "- Using device Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
elif [ "`grep_prop permissive.mode $OPTIONALS`" == 2 ]; then
  ui_print "- Using Magisk Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive_2
  ui_print " "
fi

# zram
PROP=`grep_prop zram.resize $OPTIONALS`
if [ "$PROP" == 0 ]; then
  ui_print "- ZRAM swap will be disabled"
  ui_print " "
else
  FILE=/sys/block/zram0/disksize
  ui_print "- Changes $FILE"
  sed -i 's/#o//g' $MODPATH/service.sh
  if echo "$PROP" | grep -Eq %; then
    ui_print "  to $PROP of RAM size"
    PROP=`echo "$PROP" | sed 's/%//'`
    sed -i "s/VAR/$PROP/g" $MODPATH/service.sh
    sed -i 's/#%//g' $MODPATH/service.sh
  elif [ "$PROP" ]; then
    ui_print "  to $PROP Byte"
    sed -i "s/ZRAM=3G/ZRAM=$PROP/g" $MODPATH/service.sh
  else
    ui_print "  to 3G Byte"
  fi
  ui_print " "
  PROP=`grep_prop zram.algo $OPTIONALS`
  if [ "$PROP" ]; then
    FILE=/sys/block/zram0/comp_algorithm
    if grep -Eq "$PROP" $FILE; then
      ui_print "- Changes $FILE"
      ui_print "  to $PROP"
      sed -i "s/#ALGO=/ALGO=$PROP/g" $MODPATH/service.sh
    else
      ui_print "! $PROP is unsupported"
      ui_print "  in $FILE"
    fi
    ui_print " "
  fi
fi














