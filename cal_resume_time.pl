#! /usr/bin/perl -w

use File::Copy;

$inputfile = "kernel.log";

$dirname = "result";
set_output($dirname);

arg_parse();

print "Reading $inputfile ...\n\n";
#$display_on = "innolux_n070iceg02_vid_set_brightness: brightness level";  # 375 case
$display_on = "mdfld_dsi_auo_set_brightness: brightness level";   # 581 case
$resume_btn_press = "wakeup from";
$device_suspend = "PM: suspend entry";

$resume_time = 0;
$flag = 0;
$btn_press_time = 0;
$total_times = 0;

$t1=0,$t2=0,$t3=0,$t4=0;

open (FHD, "$inputfile") or die "Cannot open files. $!\n";
open (ab_file,">$outputfile3");
print ab_file "Button_Press_Time\tDisplay_on_Time\t\tResume_Time\n";
open (wr_file,">$outputfile");
print wr_file "Inputfile:\t$inputfile\n\n";
print wr_file "Button_Press_Time\tDisplay_on_Time\t\tResume_Time\n";

while($line = <FHD>){
	if ($line =~ m/([0-9]+\.[0-9]+)] +$resume_btn_press/){
		$btn_press_time = $1;
		$flag = 0;
	}
	elsif ($line =~ m/([0-9]+\.[0-9]+)] +$device_suspend/){
		$flag = 1;
	}
	elsif ($line =~ m/([0-9]+\.[0-9]+)] +$display_on=([0-9]+)/){
		$display_on_time = $1;
		$level = $2;
		if($flag == 0 && $level != 0 && $btn_press_time != 0){
			$flag = 1;
			$resume_time = $display_on_time - $btn_press_time;
			print wr_file "$btn_press_time\t\t$display_on_time\t\t$resume_time\n";
			$total_times = $total_times + 1;
			# make statistic for different resume time
			if($resume_time < 0.5){
				$t1 = $t1 + 1;
			}elsif($resume_time < 1){
				$t2 = $t2 + 1;
			}elsif($resume_time < 1.5){
				$t3 = $t3 + 1;
			}else{
				print ab_file "$btn_press_time\t\t$display_on_time\t\t$resume_time\n";
				$t4 = $t4 + 1;
			}
		}
	}
}
close (FHD);
print "Calculating ...\n\n";
if ($total_times == 0){
	print "Cannot find any resume log! Please check the inputfile!\n";
	exit 1
}

if ($t4 == 0){
	print ab_file "\nNo abnormal case!\n";
}

print wr_file "\n\n\n";
print_percent();
print "Generate \"$outputfile\"\n\n";
print wr_file "\n\nAbnormal case: \n";
qx(cat $outputfile3 >> $outputfile);
close (wr_file);

open (wr_file,">$outputfile2");
print_percent();
print "Generate \"$outputfile2\"\n\n";
close (wr_file);

print "Generate \"$outputfile3\"\n\n";
close (ab_file);


if (-d $dirname){
	$i = 1;
	$org_dirname = $dirname;
	while (-d $dirname){
		$dirname = "$org_dirname". "_". "$i";
		$i = $i + 1;
	}
}elsif (-e $dirname){
	print "File \"$dirname\" exist. Create $dirname_dir\n";
	$dirname = "$dirname_dir";
}

print "Move the result files to \"$dirname\" folder.\n\n";

mkdir "$dirname";
move($outputfile,"$dirname/$outputfile") or die "Move failed: $!\n";
move($outputfile2,"$dirname/$outputfile2") or die "Move failed: $!\n";
move($outputfile3,"$dirname/$outputfile3") or die "Move failed: $!\n";

sub print_percent{
print wr_file "Total $total_times times\n";
$p1 = sprintf( "%.2f", $t1/$total_times*100);
print wr_file "0.0~0.5:\t\t$t1\ttimes\t\t$p1 %\n";
$p2 = sprintf( "%.2f", $t2/$total_times*100);
print wr_file "0.5~1.0:\t\t$t2\ttimes\t\t$p2 %\n";
$p3 = sprintf( "%.2f", $t3/$total_times*100);
print wr_file "1.0~1.5:\t\t$t3\ttimes\t\t$p3 %\n";
$p4 = sprintf( "%.2f", $t4/$total_times*100);
print wr_file "1.5~   :\t\t$t4\ttimes\t\t$p4 %\n";
}

sub set_output{
	$dirname = "$_[0]";
	$outputfile = "$_[0].txt";
	$outputfile2 = "$_[0]_percent.txt";
	$outputfile3 = "$_[0]_abnormal.txt";
}

sub arg_parse{
	if ($#ARGV == -1){
		print "Try './cal_resume_time.pl --help' for more information.\n";
		exit 0
	}
	elsif ($#ARGV == 0){
		if ($ARGV[0] eq "--help"){
			help();
		}else{
			$inputfile = $ARGV[0];
		}
	}
	elsif ($#ARGV == 1){
		if($ARGV[0] eq "-o"){
			set_output($ARGV[1]);
		}else{
			print "Invalid argument: must have '-o' in front of $ARGV[1]!\n";
			exit 1
		}
	}
	elsif ($#ARGV == 2){
		if($ARGV[0] eq "-o"){
			set_output($ARGV[1]);
			$inputfile = $ARGV[2];
		}else{
			$inputfile = $ARGV[0];
			if($ARGV[1] eq "-o"){
				set_output($ARGV[2]);
			}
			else{
				print "Invalid argument!\n";
				exit 1
			}
		}
	}
	else {
		print "Too many arguments\n";
		exit 1
	}
}

sub help{
		print "Usage: ./cal_resume_time.pl [\$INPUTFILE] [-o \$OUTDIR]\n";
		print "       ./cal_resume_time.pl [-o \$OUTDIR] [\$INPUTFILE]\n\n\n";
		print "Example: ./cal_resume_time.pl kernel_1.log            <- inputfile \"kernel_1.log\" output folder \"result\".\n";
		print "         ./cal_resume_time.pl -o output               <- inputfile \"kernel.log\" output folder \"output\".\n";
		print "         ./cal_resume_time.pl -o output kernel_1.log  <- inputfile \"kernel_1.log\" outpur folder \"output\".\n";
		print "         ./cal_resume_time.pl kernel_1.log -o output  <- inputfile \"kernel_1.log\" outpur folder \"output\".\n\n";
		exit 0
}
