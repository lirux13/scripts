#!/usr/bin/perl -w

#
#by lirux
#

#use Switch;
use Cwd;
use strict;
use warnings;

system("cls");

#my @valid_para = ("help", "copy", "modis");
my $ScriptPath = "C:\\Users\\Administrator\\Ubuntu\ One\\script"; 
my $LogPath = "D:\\work\\log";
my $CurrentPath = getcwd();
my $CurrentDriver = substr($CurrentPath, 0, 2);
my $input = "";

#if(!(-e "$CurrentPath\\make.bat"))
if(0)
{
    my @SourceList = GetSourceList();
    $CurrentPath = ListAndSelect(@SourceList);
    chdir($CurrentPath);
    #system("cd $CurrentPath");
    #chdir($CurrentPath);
    $CurrentPath = getcwd();
}
$CurrentPath =~ s/\//\\/g;
print("Current path : $CurrentPath\n");

my ($plat, $custom, $project) = ReadMakeIni();
my $make_file = $custom."_".$project.".mak";
if("" ne $custom) {
    print("Current build custom: $custom, make file: $make_file\n");
}
print("==============================\n\n");

my @mtk_source_list;
my @prj_mak_list;
my $src_total;
my $mak_total;

while(1) 
{
    #print("MTK($CurrentPath):");
    if($custom eq "") {
        print("null \@ $CurrentPath:");
    } else {
        print("$custom \@ $CurrentPath:");
    }
    my $command = <STDIN>;
    chomp($command);

    main_proc($command);
}

##################################################
#sub begin
##################################################
my @search_result;

sub main_proc {
	my $cmd = lc($_[0]);
	my $para = "";

	my $idx_space = index($cmd, " ");
	if($idx_space > 0) {
		$para = substr($cmd, $idx_space+1);
		$cmd = substr($cmd, 0, $idx_space);
	}
	
	print "[$cmd], [$para]\n";
	#system("pause");
    
    if("mtk" eq $cmd) {
        #do nothing
    } 
    elsif ("custom" eq $cmd) {
        CustomNew();
    } 
    elsif ("mark" eq $cmd) {
        system("perl $ScriptPath/mark_path.pl $LogPath");
    }
    elsif ("modis" eq $cmd) {
        #print("Execute commond :$cmd\n");
        system("explorer .\\MoDIS_VC9\\MoDIS.sln"); 
	}elsif ("search" eq $cmd) {
		undef @mtk_source_list;
		undef @prj_mak_list;
		&find_all_mtk_src;
		&find_all_custom_mak;

		$src_total = @mtk_source_list;
		$mak_total = @prj_mak_list;
		print("Found $src_total mtk source folders, $mak_total mak.\n");
    }elsif ("find" eq $cmd) {
    	undef @search_result;
    	my $pattern = uc($para);
    	if("" eq $pattern) {
    		print "mak name cannot be null\n";
			exit(0);
    	}
        &search_custom_mak($pattern);
    }
    elsif ("update_all" eq $cmd) {
        &svn_update_all;  
    }
    elsif ("help" eq $cmd) {
        show_help();  
    }
    elsif ("exit" eq $cmd) {
        exit(0);
    }
    else {
        #系统命令
        system(@_);
    }

    print "\n\n";
}

sub show_help {

}

#获取代码路径
sub GetSourceList {
    my $ListFile = "$LogPath/mtk_source.list";
    open(my $ListHandle, "<$ListFile") or die("Can't open $ListFile!");
    my @SourceList = <$ListHandle>;
    close($ListHandle);

    my $ListTotal = scalar(@SourceList);
    foreach my $src (@SourceList) {
         $src =~ s/[\r\n]//g;
#         $src =~ s/\\/\//g;
         if(!(-e $src)) {
            
         }
    }
   
    return @SourceList;
}

sub ListAndSelect {
    my @list = @_;
    my $total = scalar(@list);
    for(my $i = 0; $i < $total; $i++) {
         print($i+1, ".", $list[$i], "\n");
    }
    print("-"*15, "\n"); 

    my $input = 0;
    
    do {
        print("Select a source :");
        $input = <STDIN>;
        chomp($input);
        if($input < 1 || $input > $total) {
            $input = "";
            print("Invalid input.\n");
        } 
    } while ($input eq "");

    my $selected = $list[$input-1];
    $selected =~ s/\\/\//g;
    print($selected, "\n");
    return $selected;
}

sub ReadMakeIni {
    my ($plat, $custom, $project);
    if (-e "make.ini") 
    {
        open (FILE_HANDLE, "<make.ini");
        #print <FILE_HANDLE>;
        while (<FILE_HANDLE>) {
            if (/^(\S+)\s*=\s*(\S+)/) {
                    #print("1=$1, 2=$2\n");
                if($1 eq "custom") {
                    $custom = $2; 
                } elsif($1 eq "project") {
                    $project = $2;
                } elsif($1 eq "plat") {
                    $plat = $2;
                }
            }
        }
        close FILE_HANDLE;
       
    }
    
    $plat = uc($plat);
    $custom = uc($custom);
    $project = uc($project);
    #print ("plat=$plat[1]; custom=$custom;  project=$project\n");
    return ($plat, $custom, $project);
}


sub GetCustomSettings {
    my $custom_make = $_[0];
    my ($image_type, $audio_type, $theme_type) = ("", "", "");
    my ($pcba_custom, $dws_custom, $ap_custom) = ("", "", "");
    my $lcd_size = "";

    if (-e $custom_make) {
        open (FILE_HANDLE, "<$custom_make");
        while (<FILE_HANDLE>) {
            if (/^(\S+)\s*=\s*(\S+)/) {
                if($1 eq "IMAGE_TYPE") {
                    $image_type = $2; 
                } elsif ($1 eq "AUDIO_TYPE") {
                    $audio_type = $2;
                } elsif ($1 eq "THEME_TYPE") {
                    $theme_type = $2;
                } elsif ($1 eq "PCBA_CUSTOM") {
                    $pcba_custom = $2;
                } elsif ($1 eq "DWS_CUSTOM") {
                    $dws_custom = $2;
                } elsif ($1 eq "AUDIO_PARA_CUSTOM") {
                    $ap_custom = $2;
                } elsif ($1 eq "MAIN_LCD_SIZE") {
                    $lcd_size = $2;
                }
            }
        }
        close FILE_HANDLE;
    }

    return ($image_type, $audio_type, $theme_type,
            $pcba_custom, $dws_custom, $ap_custom, $lcd_size);
}

sub CustomNew {
    my $custom_name = "";
    my $sample_name = "";
    my $custom_make = "";
    my $sample_make = ""; 

    my($image_type, $audio_type, $theme_type,
            $pcba_custom, $dws_custom, $ap_custom, $lcd_size);

    my($sample_image_type, $sample_audio_type, $sample_theme_type,
            $sample_pcba_custom, $sample_dws_custom, $sample_ap_custom, $sample_lcd_size);

    if("" eq $sample_name) {
        print("Input custom sample:");
        $sample_name = <STDIN>;
        chomp($sample_name);
        $sample_name = uc($sample_name);
        $sample_make = $sample_name."_GPRS.mak";
    }
    my $sample_path = "$CurrentPath\\make\\$sample_make";
    if(-e $sample_path) {
        ($sample_image_type, $sample_audio_type, $sample_theme_type,
            $sample_pcba_custom, $sample_dws_custom, $sample_ap_custom, $sample_lcd_size) = GetCustomSettings($sample_path);
        
        print("IMAGE_TYPE = $sample_image_type\n");
        print("AUDIO_TYPE = $sample_audio_type\n");
        print("THEME_TYPE = $sample_theme_type\n");
        print("PCBA_CUSTOM = $sample_pcba_custom\n");
        print("DWS_CUSTOM = $sample_dws_custom\n");
        print("AUDIO_PARA_CUSTOM = $sample_ap_custom\n");
        print("MAIN_LCD_SIZE = $sample_lcd_size\n");
        #print("Use $sample_name as sample project?\n")
    }

    if("" eq $custom_name) {
       print("Input custom name:");
       $custom_name = <STDIN>;
       chomp($custom_name);
       $custom_name = uc($custom_name);
       $custom_make = $custom_name."_GPRS.mak";
    }

    $image_type = $custom_name;
    $audio_type = $custom_name;
    $theme_type = $custom_name;
    $pcba_custom = $custom_name;
    $dws_custom = $custom_name;
    $ap_custom = $custom_name;
    $lcd_size = $sample_lcd_size;
    print("IMAGE_TYPE = $image_type\n");
    print("AUDIO_TYPE = $audio_type\n");
    print("THEME_TYPE = $theme_type\n");
    print("PCBA_CUSTOM = $pcba_custom\n");
    print("DWS_CUSTOM = $dws_custom\n");
    print("AUDIO_PARA_CUSTOM = $ap_custom\n");
    print("MAIN_LCD_SIZE = $lcd_size\n");
    #print("Create make file: ", $custom_make, "?\n");
    print("-"*15, "\n\n");
    
    #mak
    &system_copy_file("$CurrentPath\\make\\$sample_make", "$CurrentPath\\make\\$custom_make"); 
    #verno
    &system_copy_file("$CurrentPath\\make\\verno_$sample_name\.bld", "$CurrentPath\\make\\verno_$custom_name\.bld"); 
    
    $sample_image_type = "$CurrentPath\\plutommi\\Customer\\Images\\PLUTO$sample_lcd_size\\image_$sample_image_type.zip";
    $image_type = "$CurrentPath\\plutommi\\Customer\\Images\\PLUTO$sample_lcd_size\\image_$image_type.zip";
    &system_copy_file($sample_image_type, $image_type);
    
    $sample_audio_type = "$CurrentPath\\plutommi\\Customer\\Audio\\PLUTO\\audio_$sample_audio_type.zip";
    $audio_type = "$CurrentPath\\plutommi\\Customer\\Audio\\PLUTO\\audio_$audio_type.zip";
    &system_copy_file($sample_audio_type, $audio_type);

    $sample_theme_type = "$CurrentPath\\plutommi\\Customer\\LcdResource\\MainLcd$sample_lcd_size\\$sample_theme_type";
    $theme_type        = "$CurrentPath\\plutommi\\Customer\\LcdResource\\MainLcd$lcd_size\\$theme_type";
    &system_copy_dir($sample_theme_type, $theme_type);
   
    if(!(-e "$CurrentPath\\custom\\drv_custom\\$dws_custom"))
    {
        mkdir("$CurrentPath\\custom\\drv_custom\\$dws_custom");
    }
    $sample_dws_custom = "$CurrentPath\\custom\\drv_custom\\$sample_dws_custom\\codegen";
    $dws_custom        = "$CurrentPath\\custom\\drv_custom\\$dws_custom\\codegen";
    system_copy_dir($sample_dws_custom, $dws_custom);
    
    if(!(-e "$CurrentPath\\custom\\drv_custom\\$ap_custom"))
    {
        mkdir("$CurrentPath\\custom\\drv_custom\\$ap_custom");
    }
    $sample_ap_custom = "$CurrentPath\\custom\\drv_custom\\$sample_ap_custom\\audio";
    $ap_custom        = "$CurrentPath\\custom\\drv_custom\\$ap_custom\\audio";
    system_copy_dir($sample_ap_custom, $ap_custom);
}

sub system_copy_file{
    my $src = $_[0];
    my $dst = $_[1];

    if(!(-e $src)) {
        print("$src do not exist!\n");
    }
    elsif(-e $dst) {
        print("$dst hava exist!\n");
    } else {
        my $cmd = ("copy $src $dst");
        print($cmd, "\n");
        system($cmd);
    }
}

sub system_copy_dir{
    my $src = $_[0];
    my $dst = $_[1];

    if(!(-e $src)) {
        print("$src do not exist!\n");
    }
    elsif(-e $dst) {
        print("$dst hava exist!\n");
    } else {
        my $cmd = ("xcopy /S /I $src $dst");
        print($cmd, "\n");
        system($cmd);
    }
}

# 查找mak文件
# Output: @prj_mak_list
sub find_all_custom_mak {
    foreach my $src (@mtk_source_list) {
        #print("====================\n$src : \n");
        my $make_path = "$src\\make";
        opendir(DIR, $make_path) || die("Error in opening $make_path");
        while((my $file_name = readdir(DIR))) {
            $file_name = uc($file_name);
            if($file_name =~ m/VERNO_.*.BLD/) {
                $file_name =~ s/VERNO_//;
                $file_name =~ s/\.BLD//;
                #print("$file_name\n");
                
                foreach ("GPRS", "GSM") {
                    my $full_file_path = "$make_path\\$file_name\_$_.mak";
                    #if((-e $full_file_path) && ($full_file_path =~ m/60M/)) {
                    if((-e $full_file_path)) {
                        #print("$full_file_path\n");
                        push(@prj_mak_list, "$full_file_path");
                    }
                }
            }
        }
        close(DIR);
    }
}

# 查找MTK代码文件夹
sub find_all_mtk_src {
    my @src_list;
    my $i = 0;
    
	#print("Finding mtk source....\n");
#	system("C:");
    foreach my $ch ('D'..'H') {
        my $drv = "$ch:";
        
        if(-e $drv) {
        	print "Searching driver $drv ...\n";

            opendir (DRV_HDL, $drv) || die "Error in opening dir $drv\n";
            my @folders = readdir(DRV_HDL);
            close(DRV_HDL);
            
            foreach my $folder(@folders) {

            	my $path = "$drv\\$folder";
				#print "$path\n";
            	next unless (-d $path);
            	next if ($folder =~ m/^System/);
            	next if ($folder =~ m/\$/);
            	next if ($folder =~ m/\~/);
            	next if ($folder eq ".");
            	next if ($folder eq "..");
            	#print "$path\n";
            	
                if(-e "$path\\make" && -e "$path\\make.bat" && -e "$path\\m.bat") {
                	print("\t$path\n");
                    push(@mtk_source_list, "$path");
                    next;
                }

	            opendir (FOLDER_HDL, $path) || die "Error in opening dir $path\n";
	            my @sub_folders = readdir(FOLDER_HDL);
	            close(FOLDER_HDL);

				foreach my $sub_folder(@sub_folders) {
            		next if ($sub_folder eq ".");
            		next if ($sub_folder eq "..");

	                if($sub_folder=~/^src/){
	                	my $path2 = "$path\\$sub_folder";
		                if(-e "$path2\\make" && -e "$path2\\make.bat" && -e "$path2\\m.bat") {
		                	print("\t$path2\n");
		                    push(@mtk_source_list, "$path2");
		                }
	                }
                }
            }   
        }
    }
}


sub search_custom_mak {
	my $pattern = $_[0];
	chomp($pattern);
	foreach my $mak (@prj_mak_list) {
		if($mak=~/$pattern/) {
			#print "$mak\n";
			push(@search_result, $mak);
		}
	}

	my $i = 0;
	foreach my $mak (@search_result) {
		$i++;
		print $i, ". ", $mak, "\n"; 
	}	
}

sub svn_update_all {
	foreach my $src(@mtk_source_list){
		my $bat = "$src\\..\\svn_update.bat";
		
		if(-e $bat) {
			#print "$bat\n";
			##system($bat);
			my $cmd = "start TortoiseProc.exe /command:update  /path:$src /closeonend:3";
			system($cmd);
		}
	}
}