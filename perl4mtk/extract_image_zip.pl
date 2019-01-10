#!/usr/bin/perl -w

#
#by lirux @2014
#
use strict;
use warnings;

my $image_old = "E:\\image_out\\61D_0922";
my $image_out = "E:\\image_out\\61D_0119";
my $out_path = "";
my $zip_7za = "plutommi\\Customer\\ResGenerator\\7za.exe";

my @prj_mak_list;
&find_all_custom_mak;

if(-e $image_out) {
	die "$image_outÒÑ´æÔÚ\n";
}
else {
	mkdir $image_out;
}

my $mak_name;
my $image_path;
my $main_menu_stype;
my $main_lcd_size;
my $custom_mak;

foreach my $mak (@prj_mak_list) {
	print "mak: $mak\n";
	$custom_mak = $mak;
	$image_path = "";
	$main_menu_stype = "";
	$main_lcd_size = "";
	&read_make($mak);
	if($image_path ne "" && -e $image_path) {
		#print "imagte path: $image_path\n";
		&unzip_image($image_path);
	}
}

########################################################################

sub system_7zip_x {
	my $zip_flie = uc($_[0]);
	my $path = $image_out;

	unless (-e $path) {
		mkdir $path;
	}
	$path = $path."\\".$main_lcd_size;
	unless (-e $path) {
		mkdir $path;
	}

	my $out = uc($custom_mak);
	$out = substr $out, rindex($out, "\\")+1;
	$out =~ s/\_GPRS//g;
	$out =~ s/\_GSM//g;
	$out =~ s/\.MAK//g;

	$out = $path."\\".$out;
	if(-e $zip_flie) {
		unless (-e $out) {
			mkdir $out;
		}
		print ("$out \n");
		#system("start /min $zip_7za x $zip_flie -o$out");
		system("$zip_7za x $zip_flie -o$out > nul");
	}

	return $out;
}

sub find_all_custom_mak {
    my $make_path = ".\\make";
    opendir(DIR, $make_path) || die("Error in opening $make_path");
    while((my $file_name = readdir(DIR))) {
            $file_name = uc($file_name);
            if($file_name =~ m/VERNO_.*.BLD/) {
                $file_name =~ s/VERNO_//;
                $file_name =~ s/\.BLD//;
                next if $file_name =~ m/DRV/;
                next if $file_name =~ m/DEVELOP/;
                next if $file_name =~ m/FACTORY/;
                next if $file_name =~ m/BIRD/;
                next if $file_name =~ m/LEGEND/;
                next if $file_name =~ m/CTA/;
                #print "$file_name\n";
                foreach ("GPRS", "GSM") {
                    my $full_file_path = "$make_path\\$file_name\_$_.mak";
                    if((-e $full_file_path)) {
                        push(@prj_mak_list, "$full_file_path");
                    }
                }
            }
    }
    close(DIR);
}

sub read_make {
	my $mak = uc($_[0]);
    exit unless (-e $mak);

	my $idx0 = rindex($mak, "\\")+1;
	my $idx1 = rindex($mak, "_");
	$mak_name = substr $mak, $idx0, $idx1 - $idx0;
	#print $mak_name, "\n";
	#exit(0);

    
	my $image_type;
    open (FILE_HANDLE, "<$mak") or die "cannot open $mak\n";
    while (<FILE_HANDLE>) {
        #push(@sample_mak_buff, $_);
        if (/^(\S+)\s*=\s*(\S+)/) {
            my $keyname = uc($1); 
            my $keyvalue = uc($2);
          
            if($keyname eq "MAIN_LCD_SIZE") {
				$main_lcd_size = $keyvalue;
            }
            elsif($keyname eq "IMAGE_TYPE") {
				$image_type = $keyvalue;
            }
            elsif($keyname eq "BIRD_MAINMENU_STYLE") {
				$main_menu_stype = $keyvalue;
            }

            if("" ne $main_menu_stype) {
            	#print "$main_lcd_size, $image_type, $main_menu_stype\n";
				last;
            }
        }
    }

    close FILE_HANDLE;
    if(defined($main_lcd_size) && defined($image_type)) {
    	$image_path = ".\\plutommi\\Customer\\Images\\PLUTO".$main_lcd_size."\\image_".$image_type.".zip";
    }
}

sub unzip_image {
  	my $file_name = uc($_[0]);
  	my $file_out = substr($file_name, rindex($file_name, "\\")+1);

	my $lcd_size_path = "$image_out\\$main_lcd_size";
	#print "$lcd_size_path\n";
	unless(-e $lcd_size_path) {
		mkdir $lcd_size_path;
	}

  	$file_out =~ s/IMAGE_//;
  	$file_out =~ s/\.ZIP//;
  	my $file_old = "$image_old\\$main_lcd_size\\$file_out";
  	$file_out = "$image_out\\$main_lcd_size\\$file_out.zip";

	
  	
  	#print "000: $file_out\n";
  	unless((-e "$file_old" || -e "$file_out")) {
		if($file_name =~ m/IMAGE_.*.ZIP/) {
			#my $out_path = &system_7zip_x($file_name);
			#&delete_useless_main_menu_folder($out_path);
			my $cmd = "copy $file_name $file_out";
			print "$cmd\n";
			system("$cmd");
		}
	}
}

sub delete_useless_main_menu_folder {
	my $img_path = $_[0];
	my $mm_new = $img_path."\\MainLCD\\MainMenu0";
	my $mm_old = $img_path."\\MainLCD\\MainMenu";
	my $mm_type = $main_menu_stype;

	my $cp_path = "";

	mkdir $mm_new;

	#print "$mm_type\n";
	if($mm_type eq "" || $mm_type =~ m/GRID/) {
		$cp_path = $img_path."\\MainLCD\\MainMenu\\SLIM_MATRIX\\STYLE0";
	}
	elsif($mm_type =~ m/PAGE_STYLE1/) {
		$cp_path = $img_path."\\MainLCD\\MainMenu\\BIRD_PAGE\\PAGE_STYLE1";
	}
	else {
		$cp_path = $img_path."\\MainLCD\\MainMenu\\BIRD_PAGE\\PAGE_STYLE3";
	}

	system("copy /y $cp_path $mm_new > nul");

	system("del $mm_old /s /q /f > nul");
	system("rmdir $mm_old /s /q> nul");

	rename $mm_new, $mm_old;
}
