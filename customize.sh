ui_print " "

# magisk
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
fi

# optionals
OPTIONALS=/sdcard/optionals.prop

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
ui_print " MagiskVersion=$MAGISK_VER"
ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
ui_print " "

# sdk
NUM=14
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API. You have to upgrade your"
  ui_print "  Android version at least SDK API $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# sepolicy.rule
if [ "$BOOTMODE" != true ]; then
  mount -o rw -t auto /dev/block/bootdevice/by-name/persist /persist
  mount -o rw -t auto /dev/block/bootdevice/by-name/metadata /metadata
fi
FILE=$MODPATH/sepolicy.sh
DES=$MODPATH/sepolicy.rule
if [ -f $FILE ] && [ "`grep_prop sepolicy.sh $OPTIONALS`" != 1 ]; then
  mv -f $FILE $DES
  sed -i 's/magiskpolicy --live "//g' $DES
  sed -i 's/"//g' $DES
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
permissive() {
  SELINUX=`getenforce`
  if [ "$SELINUX" == Enforcing ]; then
    setenforce 0
    SELINUX=`getenforce`
    if [ "$SELINUX" == Enforcing ]; then
      ui_print "  ! Your device can't be turned to Permissive state."
    fi
    setenforce 1
  fi
  sed -i '1i\
SELINUX=`getenforce`\
if [ "$SELINUX" == Enforcing ]; then\
  setenforce 0\
fi\' $MODPATH/post-fs-data.sh
}

# permissive
if [ "`grep_prop permissive.mode $OPTIONALS`" == 1 ]; then
  ui_print "- Using permissive method"
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
fi

# zram
PROP=`grep_prop zram.resize $OPTIONALS`
if [ "$PROP" == 1 ]; then
  ui_print "- Activating ZRAM resize disk to 1 GB..."
  sed -i 's/#1//g' $MODPATH/post-fs-data.sh
  sed -i 's/#1//g' $MODPATH/service.sh
  ui_print " "
elif [ "$PROP" == 2 ]; then
  ui_print "- Activating ZRAM resize disk to 2 GB..."
  sed -i 's/#2//g' $MODPATH/post-fs-data.sh
  sed -i 's/#2//g' $MODPATH/service.sh
  ui_print " "
elif [ "$PROP" == 3 ]; then
  ui_print "- Activating ZRAM resize disk to 3 GB..."
  sed -i 's/#3//g' $MODPATH/post-fs-data.sh
  sed -i 's/#3//g' $MODPATH/service.sh
  ui_print " "
elif [ "$PROP" == 4 ]; then
  ui_print "- Activating ZRAM resize disk to 4 GB..."
  sed -i 's/#4//g' $MODPATH/post-fs-data.sh
  sed -i 's/#4//g' $MODPATH/service.sh
  ui_print " "
elif [ "$PROP" == 75% ]; then
  ui_print "- Activating ZRAM resize disk to 75% of RAM..."
  sed -i 's/#75%//g' $MODPATH/post-fs-data.sh
  sed -i 's/#75%//g' $MODPATH/service.sh
  ui_print " "
fi


