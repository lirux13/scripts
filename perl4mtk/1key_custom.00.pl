#!/usr/local/bin/perl

#####################################
# File name:
# Command format:
#   tCustom [new_custom/new_mak] [src_custom/src_mak] {[src_path]}
#
#####################################

use Cwd;
use warnings;
use strict;

my $arg_num = @ARGV;
my ($new_mak, $sample_mak, $sample_source_path);
my $new_custom = "";
my $new_project = "GPRS";
my $sample_mak_path = ".";
my $CurrentPath = getcwd();

my @new_file_list;
my %sample_macro_list;
my %new_macro_list;

my @local_sample_buff;
my %local_mak_macro_list;

my ($new_dws, $new_ap, $new_theme, $new_image, $new_audio);
my ($sample_dws, $sample_ap, $sample_theme, $sample_image, $sample_audio);

my $multimedia_new = 0;

#system("cls");
$CurrentPath =~ s/\//\\/g;
#print "CurrentPath:$CurrentPath\n";
#print "$CurrentPath\\make\\make.bat\n";
(-e "$CurrentPath\\make.bat") || die("该脚本只能在MTK代码根目录执行\n");

# 判断主线
my $source_version = "UNKNOWN";
my $system_path = ".\\custom\\system\\";
if(-e "$system_path\\LEGEND61D_CN_11C_BB") {
	$source_version = "61D_11C";
}
elsif(-e "$system_path\\LEGEND61M_CN_11C_BB") {
	$source_version = "61M_11C";
}

# 
if("61D_11C" eq $source_version) {
	$multimedia_new = 1;
}

# 输入客制化信息
&custom_query;

print "---------------------------------------\n";
print "客制化开始:\n";

$new_mak = "$new_custom\_$new_project\.mak";

# 处理参考mak
$sample_mak =~ s/\.MAK$//;
unless($sample_mak =~ m/GSM/) {
	unless ($sample_mak =~ m/GPRS/) {
        $sample_mak = "$sample_mak\_GPRS";    
	}
}
$sample_mak = "$sample_mak\.mak";

$sample_mak_path = "$sample_source_path\\make\\$sample_mak";

unless(-e $sample_source_path) {
	print "\nSample source do not exist: [$sample_source_path]\n\n";
	exit(0);	
}
unless(-e $sample_mak_path) {
	print "\nSample mak do not exist: [$sample_mak_path]\n\n";
	exit(0);	
}

#print "new mak = [$new_mak]\n";
#print "new mak = [$new_mak]\nnew custom = [$new_custom]\nnew project = [$new_project]\n";
#print "sample = [$sample_mak]\nsample path = [$sample_source_path]\n\n";

if("." ne $sample_source_path) {
	&read_local_make();
}

#print "Reading sample mak\n";
my @sample_mak_buff;
&read_sample_make($sample_mak_path);
&custom_modify;

&create_custom_file;

&create_cusotm_mak;

&create_verno_file($new_custom);

&custom_add_to_svn;

&final_check;

print "\n客制化完成.\n\n";
system("pause");
#################################################
#
#################################################

sub read_sample_make {
	my $mak = "";
    if(1 == @_) {
        $mak = lc($_[0]);
        unless ($mak =~ m/\.mak/) {
            $mak = "$mak\.mak";
        }
    } 
    elsif(2 == @_) {
        $mak = "$_[0]\_$_[1]\.mak";
    }
    else {
        exit(0);
    }

    exit unless (-e $mak);
    
    open (FILE_HANDLE, "<$mak") or die "cannot open $mak\n";
    while (<FILE_HANDLE>) {
        push(@sample_mak_buff, $_);
        if (/^(\S+)\s*=\s*(\S+)/) {
            my $keyname = uc($1); 
            my $keyvalue = uc($2);
          
            $sample_macro_list{$keyname} = $keyvalue;
        }
    }

    close FILE_HANDLE;
}

sub read_local_make {
	my $local_sample_make = ".\\make\\MX263_D_ARES_A2482S_GPRS.mak";
	my $local_sample_make_end = "DRV\ END";
	my @mak_buff;

	if("61M_11C" eq $source_version) {
		if($new_custom =~ m/MX262/) {
			$local_sample_make = ".\\make\\MX262_QCIF_GRID.mak";
		}
		elsif("GSM" eq $new_project){
			$local_sample_make = ".\\make\\MX261_QCIF_PAGE_GSM.mak";
		}
		else {
			$local_sample_make = ".\\make\\MX261_M_FD_VB2008_GPRS.mak";
		}
	}

	#print "本地参考mak : $local_sample_make\n";
    (-e $local_sample_make) || die "找不到$local_sample_make";
    
    open (FILE_HANDLE, "<$local_sample_make") or die "cannot open $local_sample_make\n";
    while (<FILE_HANDLE>) {
        push(@mak_buff, $_);
        if (/^(\S+)\s*=\s*(\S+)/) {
            my $keyname = uc($1); 
            my $keyvalue = uc($2);
            $local_mak_macro_list{$keyname} = $keyvalue;
        }
        
        last if(uc($_) =~ m/$local_sample_make_end/);
    }

    close FILE_HANDLE;

    @local_sample_buff = @mak_buff;
}

sub read_sample_verno {
	my $sample_verno = "";
	my @buff;
	my $make_path = $CurrentPath.".\\make\\";
	
	opendir(MAKE_DIR, $make_path) || die("Error in opening $make_path\n");
	while((my $file_name = readdir(MAKE_DIR))) {
		$file_name = uc($file_name);
 		if($file_name =~ m/VERNO_.*.BLD/) {
 			$sample_verno = $file_name;
 			last;
		}
    }
	close(MAKE_DIR);

    $sample_verno = ".\\make\\$sample_verno";
    open (FILE_HANDLE, "<$sample_verno") or die "cannot open $sample_verno\n";
    @buff = <FILE_HANDLE>;
    close FILE_HANDLE;

    return @buff;
}

sub create_verno_file {
	my $new_verno = "";
	my $custom = uc($_[0]);
	my @verno_file_buff;
	
    if(1 == @_) {
		$new_verno = "make\\Verno_$custom\.bld";
    }
    else {
    	print "Wrong para!!!\n";
        exit(0);
    }

    if (-e $new_verno) {
		print "$new_verno exist!\n";
		exit(0);
    }

	
	foreach (&read_sample_verno) {
    	my $line_buff = $_;
        
        if (/^(\S+)\s*=\s*(\S+)/) {
            my $keyname = uc($1);
            
          	if("VERNO" eq $keyname) {
          		my $date = &get_date;
				my $verno = "V1_00_00_M".$date;
				$line_buff =~ s/$2/$verno/;
          	}
          	elsif("BRANCH" eq $keyname){
          		my $branch = "P00_".$custom;
				$line_buff =~ s/$2/$branch/;
          	}
        }
        push(@verno_file_buff, $line_buff);
    }
    open (FILE_HANDLE, ">$new_verno") or die "cannot open $new_verno\n";
    print FILE_HANDLE @verno_file_buff;
    close FILE_HANDLE;

	push(@new_file_list, $new_verno);
    print "创建vld   : $new_verno\n";
}

sub create_cusotm_mak {
	open (NEW_MAK_HDL, ">make\\$new_mak") or die "Open $new_mak fail!!!\n";
	print NEW_MAK_HDL (@sample_mak_buff);
	close NEW_MAK_HDL;

	push(@new_file_list, "make\\$new_mak");
	print "创建mak   : make\\$new_mak \n";

	#system("explorer /e,/select, make\\$new_mak");
}

sub create_custom_file{
	&find_source_custom_file;
	&find_new_custom_file;

	print "复制dws   [$sample_dws]\n";
	&system_copy($sample_dws, $new_dws);
	push @new_file_list, $new_dws;

	print "复制音参  [$sample_ap]\n";
	&system_copy($sample_ap, $new_ap);
	push @new_file_list, $new_ap;

	print "复制主题  [$sample_theme]\n";
	&system_copy($sample_theme, $new_theme);
	push @new_file_list, $new_theme;

	print "复制image [$sample_image]\n";
	&system_copy ($sample_image, $new_image);
	push @new_file_list, $new_image;

	print "复制audio [$sample_audio]\n";
	&system_copy($sample_audio, $new_audio);
	push @new_file_list, $new_audio;
}

sub custom_modify {
	#($new_dws, $new_ap, $new_theme, $new_image, $new_audio);
    #IMAGE_TYPE, AUDIO_TYPE, THEME_TYPE, PCBA_CUSTOM, DWS_CUSTOM, AUDIO_PARA_CUSTOM
    my @mak_buff;

	my @custom_macro_name = (
		"IMAGE_TYPE", 
		"AUDIO_TYPE", 
		"THEME_TYPE", 
		"PCBA_CUSTOM", 
		"DWS_CUSTOM", 
		"AUDIO_PARA_CUSTOM",
		"MAIN_LCD_SIZE",
		#TP
		"TOUCH_PANEL_SUPPORT",
		"HAND_WRITING",
		#BT
		"BLUETOOTH_SUPPORT",
		"BT_HFG_PROFILE",
		"BT_OPP_PROFILE",
		"BT_SSP_SUPPORT",
		"BLUETOOTH_VERSION",
		#FM
		"FM_RADIO_CHIP",
		"FM_RADIO_I2S_PATH",
		#手电筒
		"BIRD_FLASHLIGHT",
	);

	my @modify_macro_list2 = (
		"AUD_RECORD",
		"INTERNAL_ANTENNAL_SUPPORT",
		"TLB_FM_OUTPUT_MODE",
	);

	my @macro_remove = (
		"BIRD_ADOPLY_STYLE",
		"TLB_OLD_DISPLAY_MUSIC_PLAYER",
		"TLB_MAIN_DISPLAY_MUSIC_PLAYER",
		"BIRD_FM_STYLE",
		"TLB_OLD_FMRDO_DISPLAY",
		"TLB_MAIN_FMRDO_DISPLAY",
		"D_SHORTCUT_KEY_HANDLE",
	);

	my @audio_player_add = (
		"#Multimedia style",
		"MMI_TLB_MULTIMEDIA_STYLE = OLD_MEN_V2",
		"",
		"#Audip player",
		"MMI_TLB_AUDPLY_TIPS_IMAGE  = FALSE",
		"MMI_TLB_AUDPLY_KEY         = TRUE",
		"MMI_AUDPLY_VOL_KEY         = DOWN_AND_UP"
	);

	my @fm_radio_add = (
		"#FM Radio",
		"MMI_NUM_FM_IMG_ALONE  = TRUE",
		"MMI_TLB_FMRDO_TIPS_IMAGE = TRUE",
	);

	my @annotation_lines_remove = (
		"AUDIOPLYER SCREEN",
		"FM SCREEN",
		"shortcut key handle"
	);

	$new_macro_list{'IMAGE_TYPE'} = $new_custom;
	$new_macro_list{'AUDIO_TYPE'} = $new_custom; 
	$new_macro_list{'THEME_TYPE'} = $new_custom; 
  	$new_macro_list{'PCBA_CUSTOM'} = $new_custom;
	$new_macro_list{'DWS_CUSTOM'} = $new_custom;
	$new_macro_list{'AUDIO_PARA_CUSTOM'} = $new_custom;

	$new_macro_list{'MAIN_LCD_SIZE'} = $sample_macro_list{'MAIN_LCD_SIZE'};

	if("." ne $sample_source_path) {
		#TP = NONE
		if($sample_macro_list{"TOUCH_PANEL_SUPPORT"} eq "NONE") {
			$new_macro_list{"TOUCH_PANEL_SUPPORT"} = "NONE";
			$new_macro_list{"HAND_WRITING"} = "NONE";	
		}
		elsif($sample_macro_list{"HAND_WRITING"} eq "NONE") {
			$new_macro_list{"HAND_WRITING"} = "NONE";	
		}

		#BT = NONE
		if($sample_macro_list{"BLUETOOTH_SUPPORT"} eq "NONE") {
			$new_macro_list{"BLUETOOTH_SUPPORT"} = "NONE";
			$new_macro_list{"BT_HFG_PROFILE"} = "FALSE"; 
			$new_macro_list{"BT_OPP_PROFILE"} = "FALSE"; 
  			$new_macro_list{"BT_SSP_SUPPORT"} = "FALSE";
			$new_macro_list{"BLUETOOTH_VERSION"} = "NONE";		
		}

		#FM = NONE
		if($sample_macro_list{"FM_RADIO_CHIP"} eq "NONE") {
			$new_macro_list{"FM_RADIO_CHIP"} = "NONE";
			$new_macro_list{"FM_RADIO_I2S_PATH"} = "FALSE";
		}

		#CMOS_SENSOR

		#手电筒
		if(defined($sample_macro_list{"BIRD_FLASHLIGHT"})) {
			$new_macro_list{"BIRD_FLASHLIGHT"} = $sample_macro_list{"BIRD_FLASHLIGHT"};
		}
		else {
			$new_macro_list{"BIRD_FLASHLIGHT"} = "NONE";
		}

		#TRUE/FALSE 的修改
		foreach my $macro_name(@modify_macro_list2) {
			if(!defined($sample_macro_list{$macro_name})) {
				$sample_macro_list{$macro_name} = "FALSE";
			}
			$new_macro_list{$macro_name} = $sample_macro_list{$macro_name};
		}

		my $sample_custom_begin = 0;
		foreach (@sample_mak_buff) {
			my $line = uc($_);
			if($line =~ m/BIRD/ && $line =~ m/KEY/ && $line =~ m/BEGIN/) {
				$sample_custom_begin = 1;
			}

			if(1 == $sample_custom_begin) {
				push(@local_sample_buff, $_);
			}
		}

		@sample_mak_buff = @local_sample_buff;
		undef(@local_sample_buff)
	}
	
	foreach (@sample_mak_buff) {
	    my $line_buff = $_;
		my $remove_line = 0;

	    #删除注释
		if("61D_11C" eq $source_version) {
			foreach my $annot (@annotation_lines_remove) {
				if("#" eq substr($line_buff, 0, 1) && $line_buff =~ m/$annot/) {
					$remove_line = 1;
					last;
				}
			}

			#删除宏
			foreach my $macro_name (@macro_remove) {
				if($line_buff =~ m/^($macro_name)/) {
					$remove_line = 1;
					last;
				}
			}
		}

		if(1 == $remove_line) {
			next;
		}
        
        if (/^(\S+)\s*=\s*(\S+)/) {
            my $keyname = uc($1);

			# 修改宏值
			foreach my $macro_name (@custom_macro_name, @modify_macro_list2) {
				if($macro_name eq $keyname && defined($new_macro_list{$macro_name})) {
					$line_buff =~ s/$2/$new_macro_list{$macro_name}/;
					last;
				}
			}

			if(1 == $multimedia_new) {
				if("BIRD_ADOPLY_STYLE" eq $keyname) {
					# 音乐播放器增加宏
					foreach my $new_line(@audio_player_add) {
						$new_line = $new_line."\n";
						push(@mak_buff, $new_line);
					}
				}
				elsif("BIRD_FM_STYLE" eq $keyname) {
					# 收音机增加宏
					foreach my $new_line(@fm_radio_add) {
						$new_line = $new_line."\n";
						push(@mak_buff, $new_line);
					}
				}
			}
        }

        if(0 == $remove_line) {
        	push(@mak_buff, $line_buff);
        }
	}

	@sample_mak_buff = @mak_buff;
}

sub custom_query {
	my $input;

	do {
    	print "新建项目名称: ";
    	$input = &get_input;

		#print "[$input]\n";
		if($input =~ m/GPRS/) {
			$new_project = "GPRS";
		}
		elsif($input =~ m/GSM/){
			$new_project = "GSM";
		}
		else {
			$new_project = "";
		}

		$input =~ s/GPRS|GSM//;
		$input =~ s/\ |_$//;
		$new_custom = $input;
		#print "new_custom = [$new_custom]\n";
		#print "new_project = [$new_project]\n";

		if("" eq $new_project) {
			print "\n";
			print "请选择[1.GPRS/2.GSM]:";
			$input = &get_input;
			if("2" eq $input || "GSM" eq $input) {
				$new_project = "GSM";
			}
			elsif ("1" eq $input || "GPRS" eq $input) {
				$new_project = "GPRS";
			}
			else {
				print "默认GPRS\n";
				$new_project = "GPRS";
			}
		}

		$new_mak = "$new_custom"."_".$new_project."mak";
		my $new_mak_path = "make"."\\".$new_mak;
    	$input =~ s/[A-Z]|[0-9]|_//g;
		if("" eq $new_custom || "" ne $input){
			print "项目名不能包含字符[$input]\n";
			$new_custom = "";
			$new_project = "";
		}
		elsif(-e $new_mak_path) {
			print "[$new_mak]已存在! \n";
			$new_custom = "";
			$new_project = "";
		}
	}while("" eq $new_custom);

	print "\n";
	print "参考mak:";
	$input = &get_input;

	if($input =~ m/\\MAKE\\/ && $input =~ m/\.MAK$/) {
		my $idx = rindex($input, "\\MAKE\\");
		$sample_source_path = substr($input, 0, $idx);
		$sample_mak =  substr($input, $idx);
		$sample_mak =~ s/\\MAKE\\//;
		$sample_mak =~ s/\.MAK$//;
		$sample_mak =~ s/\_GPRS|\_GSM//;
	}
	else {
		$sample_source_path = "";
    	$sample_mak = $input;
    }

	#print "[$sample_source_path]\n";
	#print "[$sample_mak]\n";

	if("" eq $sample_source_path) {
	    print "请输入参考代路径:";
		$input = &get_input;
	    $sample_source_path = $input;
	    if("" eq $sample_source_path) {
			$sample_source_path = ".";
	    }
	}

	if($sample_source_path eq $CurrentPath) {
		$sample_source_path = ".";
	}
}

sub custom_add_to_svn {
	print "\n-----------------------------\n";

	my $confirm = "no";
	print "是否把客制化文件加入SVN? <y/n>";
	$confirm = <STDIN>;
	chomp($confirm);
	$confirm = lc($confirm);

	unless($confirm eq "yes" || $confirm eq "y") {
		exit(0);
	}
	
	foreach my $file  (@new_file_list) {
		$file = $CurrentPath."\\".$file;
		print "\nAdd $file\n";
		system("TortoiseProc /command:add /path:$file");
	}
	print "----------------------------------------\n\n"
}

sub find_source_custom_file {
	#($sample_dws, $sample_ap, $sample_theme, $sample_image, $sample_audio);
	my $customer_path = "$sample_source_path\\plutommi\\Customer";
	my $custom_path = "$sample_source_path\\custom";
	my $drv_custom = "$sample_source_path\\custom\\drv_custom";

	$sample_dws = "$custom_path\\codegen\\$sample_macro_list{'DWS_CUSTOM'}";
	$sample_ap = "$custom_path\\audio_par_custom\\$sample_macro_list{'AUDIO_PARA_CUSTOM'}";
	unless(-e $sample_dws) {
		$sample_dws = "$drv_custom\\$sample_macro_list{'DWS_CUSTOM'}\\codegen";
	} 
	unless(-e $sample_ap){
		$sample_ap = "$drv_custom\\$sample_macro_list{'AUDIO_PARA_CUSTOM'}\\audio";
	}

	$sample_theme = "$customer_path\\LcdResource\\MainLcd$sample_macro_list{'MAIN_LCD_SIZE'}\\$sample_macro_list{'THEME_TYPE'}";
	$sample_image = "$customer_path\\Images\\PLUTO$sample_macro_list{'MAIN_LCD_SIZE'}\\image_$sample_macro_list{'IMAGE_TYPE'}\.zip";
	$sample_audio = "$customer_path\\Audio\\PLUTO\\audio_$sample_macro_list{'AUDIO_TYPE'}\.zip";

	if("." ne $sample_source_path) {
		$custom_path = ".\\custom";
		$drv_custom = ".\\custom\\drv_custom";

		$sample_dws = "$custom_path\\codegen\\$local_mak_macro_list{'DWS_CUSTOM'}";
		$sample_ap = "$custom_path\\audio_par_custom\\$local_mak_macro_list{'AUDIO_PARA_CUSTOM'}";
		unless(-e $sample_dws) {
			$sample_dws = "$drv_custom\\$local_mak_macro_list{'DWS_CUSTOM'}\\codegen";
		} 
		unless(-e $sample_ap){
			$sample_ap = "$drv_custom\\$local_mak_macro_list{'AUDIO_PARA_CUSTOM'}\\audio";
		}
	}

	foreach ($sample_dws, $sample_ap, $sample_theme, $sample_image, $sample_audio) {
		#print "$_\n";
	}
}

sub find_new_custom_file {
	#($new_dws, $new_ap, $new_theme, $new_image, $new_audio)
	my $customer_path = ".\\plutommi\\Customer";
	my $custom_path = ".\\custom";
	my $drv_custom = ".\\custom\\drv_custom";

	if(-e $drv_custom) {
		$new_dws = "$drv_custom\\$new_macro_list{'DWS_CUSTOM'}\\codegen";
		$new_ap = "$drv_custom\\$new_macro_list{'AUDIO_PARA_CUSTOM'}\\audio";
	}
	else {
		$new_dws = "$custom_path\\codegen\\$new_macro_list{'DWS_CUSTOM'}";
		$new_ap = "$custom_path\\audio_par_custom\\$new_macro_list{'AUDIO_PARA_CUSTOM'}";
	}

	$new_theme = "$customer_path\\LcdResource\\MainLcd$new_macro_list{'MAIN_LCD_SIZE'}\\$new_macro_list{'THEME_TYPE'}";
	$new_image = "$customer_path\\Images\\PLUTO$new_macro_list{'MAIN_LCD_SIZE'}\\image_$new_macro_list{'IMAGE_TYPE'}\.zip";
	$new_audio = "$customer_path\\Audio\\PLUTO\\audio_$new_macro_list{'AUDIO_TYPE'}\.zip";
}

sub final_check {
	my $input = "";
	my @cmd_string = (
		"1. 查看mak\n",
		"2. 查看dws\n",
		"3. 查看音参\n",
		"4. 查看image\n",
		"5. 查看audio\n",
		"0. 查看mak\n",
	);

	do {
		print "";
		$input = &get_input;
		if("1" eq $input || "MAK" eq $input) {
			system("explorer /e,/select, make\\$new_mak");
		}
		elsif("2" eq $input || "DWS" eq $input) {
			system("explorer /e,/select, $new_dws");
		}
		elsif("3" eq $input || "AP" eq $input) {
			system("explorer /e,/select, $new_ap");
		}
		elsif("4" eq $input || "IMAGE" eq $input) {
			system("explorer /e,/select, $new_image");
		}
		elsif("5" eq $input || "AUDIO" eq $input) {
			system("explorer /e,/select, $new_audio");
		}
		elsif("Q" eq $input||"QUIT" eq $input||"EXIT" eq $input) {
			exit(0);
		}
	}
	
}

sub get_input {
	my $input = <STDIN>;
    chomp($input);
    $input =~ s/^\s+|\s+$//g; #去除开头和结尾的空白字符
    return uc($input);
}

sub system_copy {
	my $src = $_[0];
	my $dst = $_[1];

	unless(-e $src) {
		print "找不到 $src\n";
	}

	if(-e $dst) {
		print "$dst 已存在, 是否覆盖?";
		my $sel = <STDIN>;
		chomp($sel);
		$sel = uc($sel);
		if("Y" ne $sel && "YES" ne $sel) {
			exit(0);
		}
	}

	#print "复制 [$src] \n  至 [$dst]\n";

	my $copy_cmd = "";
	if(-d $src) {
		unless(-e $dst) {
			mkdir $dst;
			system("if not exist $dst mkdir $dst");
		}
		$copy_cmd = "copy /y $src\\* $dst";
	}
	else {
		$copy_cmd = "copy /y $src $dst";
	}
	system("$copy_cmd > nul");
}

sub get_date {
	#my ($week, $mon, $day, $ht, $year) = split(" ", localtime(time()));
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime(time());
	my $date_str;

	$date_str = substr($year, 1, 2);
	$mon += 1;
	if($mon < 10) {
		$date_str = $date_str."0";
	}
	$date_str = $date_str.$mon;

	if($day < 10) {
		$date_str = $date_str."0";
	}
	$date_str = $date_str.$day;
	
	#print "$date_str\n\n";
	return $date_str;
}
