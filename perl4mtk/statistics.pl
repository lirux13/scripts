#!/usr/local/bin/perl

use warnings;
#use strict;

# config begin
my $enable_sort = 1;
my $ignore_mtk = 1;
# config end

my @all_mak_files;
my $mak_files_total;

my @macro_array;
my @macro_value_array;

my @para = @ARGV;

&find_all_mak_file(".\\make");
$mak_files_total = @all_mak_files;
print "Total mak files: $mak_files_total\n";

my $no_bt_total = 0;
my $no_tp_total = 0;
my $no_hw_total = 0;

my $log_file = ".\\mtk_statistics.log";
if(-e $log_file) {
	system("del $log_file");
}

foreach my $custom(@all_mak_files) {
	&read_custom_make($custom, "GPRS");
}

if(1 == $enable_sort) {
	@macro_array = sort sort_macro @macro_array;
}

open (LOG_HANDLE, ">$log_file") or die "cannot open $log_file\n";
open (OUT_HANDLE, ">.\\tlb_tools\\macro_total.mak") or die "cannot open tlb_tools\\macro_total.mak\n";
foreach my $macro(@macro_array) {
	if(defined($para[0])) {
		$para[0] = uc($para[0]);
		next unless ($macro =~ m/$para[0]/);
	}
    my $value_count = "$macro\_value_count";
    my $usage_count = "$macro\_usage_count";

    if($$usage_count > 0) {
    #if($$value_count == 1 && $$usage_count > 300) {
    	my $out = "$macro \t $$value_count \t $$usage_count\n";
    	print $out;
        print LOG_HANDLE $out;
    }

	if($$value_count < 1) {

	}
	elsif($$value_count <= 2) {
    	print OUT_HANDLE "$macro = TRUE\n";
    }
    else {
		print OUT_HANDLE "$macro = NONE\n";
    }
}

close LOG_HANDLE;
#system("explorer $log_file");

###
sub read_custom_make {
	(2 == @_) or die "参数错误，请输入项目名";

	my $tlb_macro = 0;
	my $custom = $_[0];
	my $mak = ".\\make\\$_[0]_$_[1].mak";

    if (-e $mak) {
      open (FILE_HANDLE, "<$mak") or die "cannot open $mak\n";
      while (<FILE_HANDLE>) {

        if (/^(\S+)\s*=\s*(\S+)/) {
        	next if $1=~/^#/;
        	next if $2=~/^#/;
        	next if $1=~/^CUSTOM_OPTION/;
        	next if $1=~/^COM_DEFS/;
        	next if $1=~/^EXISTED_CUS_REL_TRACE_DEFS/;
			
			my $value = $2;
			my $pound_index = index($2, "#");
        	if(-1 ne $pound_index) {
				$value = substr($2, 0, $pound_index);
        		#print "$value\n";
			}

			$keyname = $1;
			if($keyname eq "IMAGE_TYPE") {
				$tlb_macro = 1;
			}
	
			next if (1 == $ignore_mtk && $tlb_macro == 0);
			
            $keyname_value_count  = "$keyname\_value_count";
            $keyname_value_array  = "$keyname\_value_array";
            $keyname_usage_count  = "$keyname\_usage_count";
            
            
            if(!defined($${keyname_value_count})) {
                $${keyname_value_count} = 0;
                push(@macro_array, $keyname);
                push(@${keyname_value_array}, $value);
            }
            
			$keyname_value_exist = "$keyname\_$value\_exist";
			$$keyname_usage_count++;
            if(!defined($${keyname_value_exist})) {
                $${keyname_value_exist} = "TRUE";
                $${keyname_value_count}++;
            } 

			$${keyname} = $value;
			
        }
      }
      close FILE_HANDLE;
    }

    #if($BLUETOOTH_SUPPORT eq "NONE") {
    #	$no_bt_total++;
    #}

    #if($TOUCH_PANEL_SUPPORT eq "NONE") {
    #	$no_tp_total++;
    #}

    #if($HAND_WRITING eq "NONE") {
    #	$no_hw_total++;
    #}
}


sub find_all_mak_file {
	my $path = $_[0];
	
	opendir(HDL_FOLDER, "$path") or die "Cannot open $path\n";
	#my @all_files = readdir HDL_FOLDER;
	my @all_files = grep {/\.bld$/}  readdir HDL_FOLDER;
	#my @all_files = grep {/^Verno_.*.\.bld$/}  readdir HDL_FOLDER;
	close HDL_FOLDER;

	foreach my $file(@all_files) {
		$file = uc($file);
		#next unless $file=~/\.BLD$/;
		$file =~ s/\.BLD$//;
		$file =~ s/^VERNO_//;
		
		#print "[$file]\n";
		if(-e "$path\\$file\_GPRS.mak" || -e  "$path\\$file\_GSM.mak") {
			push(@all_mak_files, $file);
		}
	}
}

sub macro_ingore {
    my $para_in = $_[0];
    my @ingore_array = (
			 "BIRD_DISPLAY_WEEK",
			 "BIRD_MAIN_MENU_HIDE_STATUS_BAR",
			 "STATUSBAR_NOT_DISPLAY_IN_MAINMENU",
             "BIRD_HIDE_ONE_SIM_INFO",
             "BIRD_TP_ALERT",
             "BIRD_CHINESE_FOLDER_PATH_SUPPORT",
        	 "JY_CALL_HUMAN_TONE_MOD",
        	 "BIRD_LOCK_SCREEN_TURNOFF_BY_ENDKEY",
             "BIRD_RECORD_IN_CALL",
             "BIRD_BER_IDLE_SCREEN_MAIN",
             "SAVE_POWER_PROFILE", 
             "BIRD_SOUND_ENLARGE_HELPER",
             "MMI_CLICK_STATUS_BATTERY_ICON_SHOW_BATTERY",
             "WGUI_STATUS_ICON_BAR_SHOW_TIME_STYLE",
			 "M3GPMP4_FILE_FORMAT_SUPPORT",
			 "H264_DECODE_PROFILE",
			 "IMAGE_TYPE",
        	 "AUDIO_TYPE",
        	 "THEME_TYPE",
        	 "PCBA_CUSTOM",
        	 "DWS_CUSTOM",
        	 "AUDIO_PARA_CUSTOM",
			 "RF_MODULE",
			 "LED_DRIVER_IC",			
			 "MAIN_LCD_SIZE",
        	 "POWER_ON_LOGO_DISPLAY_COLOR",
        	 "ATA_SUPPORT",
        	 "BLUETOOTH_VERSION",
        	 "TLB_UI_DARK_STYLE",
        	 "BIRD_BATTERY_LEVEL",
        	 "BIRD_AT_COMMOND",
        	 "TOUCH_PANEL_SHORTCUT_SUPPORT",
        	 "SENSOR_ROTATE",
        	 "LCD_MODULE",
        	 "INTERNAL_ANTENNAL_SUPPORT",
        	 "PHONE_TYPE",
        	 "BIRD_KB_VIBRATION",
        	 "BES_EQ_SUPPORT",
        	 "TLB_FM_OUTPUT_MODE",
        	 "INTERNAL_CLASSK_SUPPORT",
        	 "BOARD_VER",
        	 "SIP_SERIAL_FLASH_SIZE",
            #硬件不占空间
        	 "FM_RADIO_I2S_PATH",
        	 "BIRD_FLASHLIGHT",
        	
        	 "BROWSER_SUPPORT",
        	 "OBIGO_FEATURE",

            #软件不占空间
        	 "BIRD_DIAL_SCREEN_HIDE_STATUS_BAR",
        	 "MMI_BIRD_LCD_BACKLIGHT_FULL_HALF_LIGHT_TIME",
        	 "MMI_BIRD_LCD_CLAM_OPEN_HALFLITE_TO_OFF_TIME",
        	 "BIRD_UNLOCK_STYLE",
        	 "BL_SETTING_LEVEL",
        	 "POWER_ON_DISPLAY_WHITE_COLOR",
        	 "SHUTDOWN_ANI_WAIT_FOR_AUDIO",
        	
        	 "TLB_CLIENT_CUSTOM",
        	 "BIRD_CHARGE_BABY",
        	 "HORIZONTAL_CAMERA",
        	 "SENDKEY_MODE",
        	 "BIRD_FOREIGN_SUPPORT_MAXTRON",
        	 "SAVE_POWER_PROFILE_WITH_KEYPAD_LIGHT",
        	 "MMI_BIRD_AUTO_REDIAL",
        	 "STATUSBAR_NOT_DISPLAY", 
        	 "BIRD_DUAL_IMEI",
        	 "BIRD_IDLE_STYLE_REMOVE_ALL_BY_END",
        	 "MMI_BIRD_PLAY_VIB_CALL_CONNECT",
        	 "BIRD_REMOVE_VIB_MENU",
        	 "BIRD_PRO_TARGET", 
        	 "FOREIGN_VERSION",
        	 "TLB_MAGNIFIER_FUNCKTION",
        	 "MMI_LONG_POUND_RUN_MEETING", 
        	 "TLB_TOGGLE_PROFILE_VIB",
        	 "TLB_CALENDAR_SHOW_CHINESE",
        	 "BIRD_LOCK_STYLE",
        	 "TLB_DAIL_TWO_LEVEL_14",
        	 "BIRD_IMEI_EDIT",
			 "MAINLINE_CUSTOM",
             "BIRD_PHB_NAME_AND_NUMBER_IN_ONE_LINE",
             "BIRD_MAIN_MENU_SHOW_STATUS_BAR",

         );


    if (($para_in=~/^BT_/) ||
		    $para_in=~/^CMOS_SENSOR/ ||
		    $para_in=~/^GBC_/ ||
			$para_in=~/_KEY/ ||
			$para_in=~/_AS_/ ||
			$para_in=~/_ENTRY/ ||
			$para_in=~/_LUNAR_/ ||
			$para_in=~/_SOS_/)
    {
        return 1;
    }

    foreach my $m (@ingore_array) {
        if($m eq $para_in) {
            return 1;
        }
    }
    return 0;
}

sub sort_macro {
 	"\U$a" cmp "\U$b"
}

sub sort_macro_by_usage {
	my $a_count = "$a\_value_count";
	my $b_count = "$b\_value_count";
	print ("$a $$a_count\n");
 	$$a_count > $$b_count
}

