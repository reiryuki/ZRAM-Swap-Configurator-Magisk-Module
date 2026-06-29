# ZRAM Swap Configurator Magisk Module

## Descriptions
- Enables and resizes ZRAM swap to 100% of RAM size
- Configures ZRAM Swap settings
- Please read Optionals bellow if you want any different configurations
- What's ZRAM Swap? Read this: https://t.me/ryukinotes/58. For more detailed information, please read it at Android & Google documentation instead!
- This module is a tool for advanced users only. There will never recommendations nor restrictions. All at user respective policies. Do not use this if you don't even know what is this! DwYOR!

## Changelog

v3.1
- swapoff max try 20 times
- Fix failed swapon
- Shows /proc/swaps
- Restores swap_\* without reboot if the optionals are def or not set (I forgot to add this in v3.0)

v3.0
- BOOTMODE detection
- Parameters support detection
- Changes of swap_free_low_percentage, swap_util_max, & swap_compression_ratio does not require reboot
- Restores without reboot if the optionals are def or not set
- Remove loop service
- Resets module folder/files permissions at post-fs-data
- Move _uninstall.log to /data/adb/logs/

v2.9
- Fix wrong percentage swap method
- Retry method max 10 times if swapoff is fail
- Sets ZRAM size to 100% of RAM size by default
- Does not set swap configurations by default except swappiness
- Add some new Optionals

v2.8
- Add a new optional
- Does not change swap_ratio_enable and swap_ratio by default
- Optional zram.swpr can only be set if zram.swpre=1
- Sets swap_compression_ratio to 0 by default

v2.7
- Sets swap_free_low_percentage to 1 by default
- Sets swap_util_max to 99 by default
- Add new optionals

v2.6
- Delete thrashing_limit_critical removal (I think I misunderstood this property and removing it is not a good idea)
- Shows currents at installation
- Add Action button to see the results
- Sets swap_util_max to 100 by default to optimize ZRAM swap
- Add a new optional

v2.5
- Sets /proc/sys/vm/swap_ratio_enable to 1 and /proc/sys/vm/swap_ratio to 100 by default
- Add back thrashing_limit_critical removal
- Add new optionals

v2.4
- Re-sets swap_free_low_percentage to 0 by default (it seems freezing issue was not caused by that)

v2.3
- Sets swap_free_low_percentage to 2 as default (setting it 1 still makes freezing in low ram devices)
- Fix bug in uninstall.sh

v2.2
- Reverse back swap_free_low_percentage to 1 as default (setting it to 0 makes device hang and freezing sometimes lol)

## Requirements
Magisk or Kitsune Mask or KernelSU or Apatch installed

## Installation Guide & Download Link
- Install this module via Magisk app or Kitsune Mask app or KernelSU app or Apatch app or Recovery if Magisk or Kitsune Mask installed
- Reboot (/proc/sys/vm/ and swap_\* changes does not require reboot)
- Tap "Action" or run action.sh to see the results

## Optionals
- https://t.me/ryukinotes/6
- Global: https://t.me/ryukinotes/35

## Troubleshootings
Global: https://t.me/ryukinotes/34

## Support & Bug Report
- https://t.me/ryukinotes/54
- If you don't do above, issues will be closed immediately

## Credits and Contributors
- https://t.me/androidryukimodsdiscussions
- You can contribute ideas about this Magisk Module here: https://t.me/androidappsportdevelopment

## Sponsors
https://t.me/ryukinotes/25






