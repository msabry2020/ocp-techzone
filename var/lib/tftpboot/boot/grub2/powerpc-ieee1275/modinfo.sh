#!/bin/sh

# User-controllable options
grub_modinfo_target_cpu=powerpc
grub_modinfo_platform=ieee1275
grub_disk_cache_stats=0
grub_boot_time_stats=1
grub_have_font_source=1

# Autodetected config
grub_have_asm_uscore=0
grub_bss_start_symbol=""
grub_end_symbol=""

# Build environment
grub_target_cc='gcc'
grub_target_cc_version='gcc (GCC) 8.5.0 20210514 (Red Hat 8.5.0-20)'
grub_target_cflags='	 -fno-strict-aliasing -fno-strict-aliasing -g -pipe -Wall -Werror=format-security -Wp,-D_GLIBCXX_ASSERTIONS -grecord-gcc-switches  -mcpu=power6 -mtune=power8 -funwind-tables -fstack-clash-protection -Wall -W -Wshadow -Wpointer-arith -Wundef -Wchar-subscripts -Wcomment -Wdeprecated-declarations -Wdisabled-optimization -Wdiv-by-zero -Wfloat-equal -Wformat-extra-args -Wformat-security -Wformat-y2k -Wimplicit -Wimplicit-function-declaration -Wimplicit-int -Wmain -Wmissing-braces -Wmissing-format-attribute -Wmultichar -Wparentheses -Wreturn-type -Wsequence-point -Wshadow -Wsign-compare -Wswitch -Wtrigraphs -Wunknown-pragmas -Wunused -Wunused-function -Wunused-label -Wunused-parameter -Wunused-value  -Wunused-variable -Wwrite-strings -Wnested-externs -Wstrict-prototypes -g -Wredundant-decls -Wmissing-prototypes -Wmissing-declarations -Wcast-align  -Wextra -Wattributes -Wendif-labels -Winit-self -Wint-to-pointer-cast -Winvalid-pch -Wmissing-field-initializers -Wnonnull -Woverflow -Wvla -Wpointer-to-int-cast -Wstrict-aliasing -Wvariadic-macros -Wvolatile-register-var -Wpointer-sign -Wmissing-include-dirs -Wmissing-prototypes -Wmissing-declarations -Wformat=2 -mbig-endian -m32 -freg-struct-return -fno-dwarf2-cfi-asm -fno-asynchronous-unwind-tables -fno-unwind-tables -Qn -fno-stack-protector -Wtrampolines'
grub_target_cppflags='-I/builddir/build/BUILD/grub-2.02/grub-powerpc-ieee1275-2.02 -Wall -W  -DGRUB_MACHINE_IEEE1275=1 -DGRUB_MACHINE=POWERPC_IEEE1275 -mbig-endian -m32 -nostdinc -isystem /usr/lib/gcc/ppc64le-redhat-linux/8/include -I$(top_srcdir)/include -I$(top_builddir)/include'
grub_target_ccasflags=' -g -mbig-endian  -m32'
grub_target_ldflags='	-Wl,-z,relro -static -mbig-endian -m32 -Wl,--build-id=none'
grub_cflags=''
grub_cppflags=''
grub_ccasflags=''
grub_ldflags=''
grub_target_strip='strip'
grub_target_nm='nm'
grub_target_ranlib='ranlib'
grub_target_objconf=''
grub_target_obj2elf=''
grub_target_img_base_ldopt='-Wl,-Ttext'
grub_target_img_ldflags='@TARGET_IMG_BASE_LDFLAGS@'

# Version
grub_version="2.03"
grub_package="grub"
grub_package_string="GRUB 2.03"
grub_package_version="2.03"
grub_package_name="GRUB"
grub_package_bugreport="bug-grub@gnu.org"
