#! /usr/bin/perl -w

$outputfile = "result.txt";
$outputfile2 = "result_only_percent.txt";

$Inputfile = "kernel.log";
if($ARGV[0]){
$Inputfile = $ARGV[0];
}

print "Reading $Inputfile ...\n\n";
#$display_on = "innolux_n070iceg02_vid_set_brightness: brightness level";  # 375 case
$display_on = "mdfld_dsi_auo_set_brightness: brightness level";   # 581 case
$resume_btn_press = "wakeup from";
$device_suspend = "PM: suspend entry";

$resume_time = 0;
$flag = 0;
$btn_press_time = 0;
$total_times = 0;

$t1=0,$t2=0,$t3=0,$t4=0;

open (FHD, "$Inputfile") or die "Cannot open files $!i\n";
open (wr_file,">$outputfile");
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
				$t4 = $t4 + 1;
			}
		}
	}
}
close (FHD);
print "Calculating ...\n\n";
print wr_file "\n\n\n";
print_percent();
print "Generate \"$outputfile\"\n\n";
close (wr_file);

open (wr_file,">$outputfile2");
print_percent();
print "Generate \"$outputfile2\"\n\n";
close (wr_file);

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
