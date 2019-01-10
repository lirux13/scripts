#!/usr/bin/perl -w

########################################################################
#
# by lirux @2014
#
# plutommi\Customer\CustResource\mte_img_resource.h
# plutommi\Customer\ResGenerator\debug\image_resource_usage.txt
# plutommi\Customer\ResGenerator\debug\audio_resource_usage.txt
########################################################################

use strict;
use warnings;

########################################################################
my %macro_list;
my %make_ini_list;
my $custom;
my $project;

my $check_type = "ALL";

if(0 == @ARGV || 1 == @ARGV) {
	&read_make_ini;
	$custom = $make_ini_list{"custom"};
	$project = $make_ini_list{"project"};
	print "custom = ", $custom, "\tproject = ", $project, "\n";
}
elsif (2 == @ARGV || 3 == @ARGV) {
	$custom = $ARGV[0];
	$project = $ARGV[1];
}
else {
	print "\@ARGV = @ARGV\n";
	die "参数错误\n";
}

if(1 == @ARGV || 3 == @ARGV) {
	$check_type = uc($ARGV[-1]);
}

if("AUD" eq $check_type) {
	$check_type = "AUDIO";
}
elsif ("IMG" eq $check_type){
	$check_type = "IMAGE";
}
elsif ("RES" eq $check_type){
	$check_type = "RESOURCE";
}
elsif ("MAK" ne $check_type){
	$check_type = "ALL";
}

my $check_log = ".\\tlb_tools\\~check_".$custom.".txt";

if(-e $check_log) {
  unlink $check_log;
}
open (LOG_HANDLE, ">$check_log") or die "cannot open $check_log\n";

&check_output_line("项目", $custom);

&read_custom_make($custom, $project);

if("ALL" eq $check_type || "MAK" eq $check_type) {
	&mtk_check_mak;
}

if("ALL" eq $check_type || "RESOURCE" eq $check_type || "AUDIO" eq $check_type) {
	&read_audio_resource_usage;
}

if("ALL" eq $check_type || "RESOURCE" eq $check_type || "IMAGE" eq $check_type) {
	&read_image_resource_usage;
}
close(LOG_HANDLE);

system("explorer $check_log");
########################################################################
#sub begin
########################################################################
sub read_custom_make {
	((2 == @_)||(3 == @_)) or die "参数错误\n";
	my $cst = $_[0];
	my $prj = $_[1];
	my $path = ".";
	
	if(3 == @_) {
		$path = $_[2];
	}
	my $mak_file = "make\\$cst\_$prj.mak";

    if (-e $mak_file) {
      open (FILE_HANDLE, "<$mak_file") or die "cannot open $mak_file\n";
      while (<FILE_HANDLE>) {

        if (/^(\S+)\s*=\s*(\S+)/) {
          my $keyname = uc($1); 
          my $keyvalue = uc($2);
          
          $macro_list{$keyname} = $keyvalue;
        }
      }
      
      close FILE_HANDLE;
    }
}

sub read_make_ini {
	my $ini = ".\\make.ini";

    open (FILE_HANDLE, "<$ini") or die "cannot open $ini\n";
    while (<FILE_HANDLE>) {
	        if (/^(\S+)\s*=\s*(\S+)/) {
				my $keyname = lc($1);
		     	$make_ini_list{$keyname} = uc($2);
	        }
      	}
    close FILE_HANDLE;
}

sub mtk_check_mak {
	&check_output_line("功能开关");
	&show_function_status("蓝牙", "BLUETOOTH_SUPPORT",   "开", "关");
	&show_function_status("触屏", "TOUCH_PANEL_SUPPORT", "开", "关");
	&show_function_status("手写", "HAND_WRITING",        "开", "关");
	&show_function_status("录音", "AUD_RECORD");
	&show_function_status("魔音", "VOICE_CHANGER_SUPPORT");
	&show_function_status("字体", "BIRD_BIG_FONT");
	my $mainmenu_style = $macro_list{"BIRD_MAINMENU_STYLE"};
	my $style_string;
	if($mainmenu_style =~ m/PAGE/) {
		$style_string = "页式";
	}
	else {
		$style_string = "宫格";
	}
	print "主菜单     | $style_string ($mainmenu_style)\n";
	&check_output_line("主菜单", $mainmenu_style);
	#print "------------------------------------------\n";

	&show_function_status("输入法", "INPUT_METHOD");
	#&show_function_status("分辨率", "MAIN_LCD_SIZE");
	&show_function_status("来电秀", "INCOMING_CALL_SHOW_SUPPORT_FILE", "外置", "内置");
	&show_function_status("假语音王", "FAKE_HUMANTONE");
	&show_function_status("整点报时", "TLB_HOURLY_CHIME_REPORT");
	&show_function_status("主菜单播报", "BIRD_MAIN_MENU_REPORT_VOICE");
}

sub show_function_status {
	my $func_name = $_[0];
	my $macro_name = $_[1];
	my $status_on = "开";
	my $status_off = "关";
	my $use_define = 0;
	my $status;
	my $title_max_len = 10;
	my $title_len = 0;

	if(defined($_[2]) && defined($_[3])) {
		$status_on = $_[2];
		$status_off = $_[3];
		$use_define = 1;
	}

	if(!defined($macro_list{$macro_name}) ||
		"NONE" eq $macro_list{$macro_name} ||
		"FALSE" eq $macro_list{$macro_name}) {
		$status = $status_off;
	}
	elsif ("TRUE" eq $macro_list{$macro_name} || 1 == $use_define) {
		$status = $status_on;
	}
	else {
		$status = $macro_list{$macro_name};
	}

	#if($status_off ne $status) {
		$title_len = length($func_name);
		print "$func_name";
		for(my $i = $title_len; $i < $title_max_len; $i++) {
			print " ";
		}
		
		print " | ", $status, "\n";
		#print "------------------------------------------\n";
	#}
	&check_output_line($func_name, $status);
}

sub get_file_size_KB {
	my $file = $_[0];
	my @file_info = stat($file);

	my $file_size = $file_info[7];
	my $file_size_KB = $file_size / 1024;
	
	my $len = length($file_size_KB);
	my $point_index = rindex($file_size_KB, ".");

	if($len - $point_index > 2) {
		$file_size_KB = substr($file_size_KB, 0, $point_index+3);
	}
	return $file_size_KB."KB";
}

sub get_file_size_byte {
	my $file = $_[0];
	my @file_info = stat($file);

	my $file_size = $file_info[7];

	return $file_size;
}


sub read_audio_resource_usage {
	my $file = "plutommi\\Customer\\ResGenerator\\debug\\audio_resource_usage.txt";
	my @audio_id_list;
	my %audio_res_list;
	my %audio_size_list;
	my $total_size = 0;
	my $id_count = 0;
	my $valid_id_count = 0;
	
	my @mainmenu_id_list;
	my $mainmenu_res_size = 0;

	print "------------------------------------------\n";
	print "音频资源信息\n";
	&check_output_line("");
	&check_output_line("音频资源信息");	
    open (FILE_HANDLE, "<$file") or die "cannot open $file\n";
    while (<FILE_HANDLE>) {
		my @list = split /\t/, $_;
		next if($list[0] eq "APP_name");

		my $id_name = uc($list[3]);
		my $size = $list[4];
		my $res_filename = uc($list[5]);

		push(@audio_id_list, $id_name);
		if($res_filename =~ m/MAINMENU/) {
			push(@mainmenu_id_list, $id_name);
			$mainmenu_res_size += $size;
		}

		$audio_res_list{$id_name} = $res_filename;
		$audio_size_list{$id_name} = $size;
		$total_size += $size;
		$id_count++;
		if($size > 8) {
			$valid_id_count++;
		}
    }
    close FILE_HANDLE;

    &print_size("总大小", $total_size);

	my $poon_id = "AUD_ID_PROF_TONE1";
    &print_size("开机铃声", $audio_size_list{$poon_id});

    my $pooff_id = "AUD_ID_PROF_TONE2";
    if($audio_res_list{$poon_id} ne $audio_res_list{$pooff_id}) {
		&print_size("关机铃声", $audio_size_list{$pooff_id});
	}

    my $s1imy05 = "AUD_ID_PROF_RING5";
    &print_size("试听音乐", $audio_size_list{$s1imy05});

	if($mainmenu_res_size > 0) {
    	&print_size("主菜单播报", $mainmenu_res_size);
    }
}


sub read_image_resource_usage {
	my $file = "plutommi\\Customer\\ResGenerator\\debug\\image_resource_usage.txt";

	my @image_id_list;
	my %image_res_list;
	my %image_size_list;
	my $total_size = 0;
	my $id_count = 0;
	my $valid_id_count = 0;

	my @mainmenu_id_list;
	my $mainmenu_size = 0;

	my @dialer_id_list;
	my $dialer_size = 0;

	my @multimedia_id_list;
	my $multimedia_size = 0;

	my $wp_size = 0;

	my $idle_time_size = 0;

	print "------------------------------------------\n";
	print "图片资源信息:\n";
	&check_output_line("");
	&check_output_line("图片资源信息");
    open (FILE_HANDLE, "<$file") or die "cannot open $file\n";
    while (<FILE_HANDLE>) {
		my @list = split /\t/, $_;
		next if($list[0] eq "APP_name");

		my $id_name = uc($list[3]);

		

		my $size = $list[4];
		my $res_filename = uc($list[5]);

		my $img_reusing = 0;
		if($id_count > 1) {
			foreach my $id (@image_id_list) {
				if($res_filename eq $image_res_list{$id})
				{
					$img_reusing = 1;
					last;
				}
			}
			if(0 == $img_reusing) {
				$total_size += $size;
			}
			else {
				$total_size += 8;
			}
		}
		
		$image_size_list{$id_name} = $size;

		#待机墙纸
		#Wallpaper ID is  (IMG_ID_PHNSET_WP_START + i)
		if($id_name =~ m/IMG_ID_PHNSET_WP_START/) {
			#$id_name =~ s/\(|\ \+\ I\)//g;
			$wp_size += $size;
		}

		#待机时间
		if($res_filename =~ m/DIGITAL_TIME/ || 
		($res_filename =~ m/ANOLE_IDLE/ && $id_name =~ m/IMG_ANOLE_IDLE_TIME/)) {
			#if(0 == $img_reusing) {
				$idle_time_size += $size;
			#}
		}

		#主菜单
		push(@image_id_list, $id_name);
		if($res_filename =~ m/MAINLCD\\\\MAINMENU\\\\/) {
			push(@mainmenu_id_list, $id_name);
			if(0 == $img_reusing) {
				$mainmenu_size += $size;
			}
		}

		#拨号
		if($res_filename =~ m/MAINLCD\\\\DIALINGSCREEN\\\\/) {
			push(@dialer_id_list, $id_name);
			#print $id_name, " = ", $size, "\n";
			$dialer_size += $size;
		}

		#多媒体
		if($res_filename =~ m/MAINLCD\\\\MULTIMEDIA\\\\/) {
			push(@multimedia_id_list, $id_name);
			if(0 == $img_reusing) {
				#print $id_name, " = ", $size, "\n";
				$multimedia_size += $size;
			}
		}
	
		$image_res_list{$id_name} = $res_filename;
		$id_count++;
		if($size > 8) {
			$valid_id_count++;
		}
    }
    close FILE_HANDLE;

    &print_size("图片总大小", $total_size);

	my $image_folder = "plutommi\\Customer\\Images\\PLUTO".$macro_list{MAIN_LCD_SIZE}."\\MainLCD";
	my $logo_file = $image_folder."\\Active\\Poweronoff\\logo.bmp";
	my $logo_size = 0;
	$logo_size = &get_file_size_byte($logo_file);
	&print_size("开机Logo", $logo_size);

    my $poon_id = "IMG_ID_PHNSET_ON_START";
    my $pooff_id = "IMG_ID_PHNSET_OFF_START";
    my $pooff_size = 0;
    unless(defined($image_size_list{$poon_id})) {
		$poon_id = "IMG_ID_PHNSET_ON_ANIMATION_DEFAULT";
		$pooff_id = "IMG_ID_PHNSET_OFF_ANIMATION_DEFAULT";
    }
	&print_size("开机动画", $image_size_list{$poon_id});
	if($image_res_list{$poon_id} ne $image_res_list{$pooff_id}) {
		$pooff_size = $image_size_list{$pooff_id};
	}
	&print_size("关机动画", $pooff_size);

	#my $wp_id = "IMG_ID_PHNSET_WP_START";
	&print_size("待机墙纸", $wp_size);
	&print_size("待机时间", $idle_time_size);
	&print_size("拨号界面", $dialer_size);
	&print_size("主菜单", $mainmenu_size);
	&print_size("多媒体", $multimedia_size);
}

sub print_size {
	my $title_len_max = 10;
	my $title = $_[0];
	my $file_size = $_[1];
	my $file_size_KB = $file_size / 1024;
	
	my $len = length($file_size_KB);
	my $point_index = rindex($file_size_KB, ".");

	if($len - $point_index > 2) {
		$file_size_KB = substr($file_size_KB, 0, $point_index+3);
	}

	print "    ", $title;
	for (my $i = length($title); $i < $title_len_max; $i++) {
		print " ";
	}
	print " : ", $file_size_KB, "KB\n";
	&check_output_line($title, $file_size);
}

sub check_output_line {
	foreach (@_) {
		print LOG_HANDLE $_, "\t";
	}
	print LOG_HANDLE "\n";
}
