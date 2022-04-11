# dir
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { block_device mnt_vendor_file mnt_media_rw_file } dir search"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { block_device mnt_vendor_file mnt_media_rw_file } dir search"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } block_device dir { read open }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } block_device dir { read open }"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { mnt_vendor_file adsprpcd_file block_device mnt_media_rw_file firmware_file system_bootstrap_lib_file linkerconfig_file mirror_data_file } dir getattr"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { mnt_vendor_file adsprpcd_file block_device mnt_media_rw_file firmware_file system_bootstrap_lib_file linkerconfig_file mirror_data_file } dir getattr"

# file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { vendor_file proc proc_swaps proc_dirty proc_dirty_ratio sysfs } file read"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { vendor_file proc proc_swaps proc_dirty proc_dirty_ratio sysfs } file read"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { proc proc_swaps proc_dirty proc_dirty_ratio sysfs } file open"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { proc proc_swaps proc_dirty proc_dirty_ratio sysfs } file open"
#magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { proc proc_swaps sysfs unlabeled hal_dms_default_exec hal_audio_default_exec hal_bluetooth_qti_exec hal_camera_default_exec hal_cas_default_exec hal_configstore_default_exec hal_health_default_exec hal_drm_default_exec hal_drm_clearkey_exec } file getattr"
#magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { proc proc_swaps sysfs unlabeled hal_dms_default_exec hal_audio_default_exec hal_bluetooth_qti_exec hal_camera_default_exec hal_cas_default_exec hal_configstore_default_exec hal_health_default_exec hal_drm_default_exec hal_drm_clearkey_exec } file getattr"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } * file getattr"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } * file getattr"

# blk_file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { persist_block_device block_device userdata_block_device cache_block_device system_block_device } blk_file getattr"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { persist_block_device block_device userdata_block_device cache_block_device system_block_device } blk_file getattr"

# filesystem
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { firmware_file adsprpcd_file } filesystem getattr"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { firmware_file adsprpcd_file } filesystem getattr"

# chr_file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } fuse_device chr_file getattr"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } fuse_device chr_file getattr"


