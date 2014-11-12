#! /usr/bin/perl -w

$outputfile = "result.txt";
$outputfile2 = "result_only_percent.txt";

$Inputfile = "kernel.log";
if($ARGV[0]){
$Inputfile = $ARGV[0];
}

if($ARGV[1]){
$outputfile = "$ARGV[1].txt";
$outputfile2 = "${ARGV[1]}_only_percent.txt";
}


print "Reading $Inputfile ...\n\n";
#$power_btn_pressed_symbol = "[mid_powerbtn] power button pressed";
#$power_btn_released_symbol = "[mid_powerbtn] power button released";
$pressed_time = 0;
$released_time = 0;
$power_btn_time = 0;

$total_times = 0;

$t1=0,$t2=0,$t3=0,$t4=0,$t5=0;
my @strangeTimeArray;
$strangeTimeIndex = 0;

open (FHD, "$Inputfile") or die "Cannot open files $!i\n";
open (wr_file,">$outputfile");
print wr_file "Button_Press_Time\tButton Release_Time\t\tTotal_Time\n";


while($line = <FHD>){
	if ($line =~ m/([0-9]+\.[0-9]+)\] \[mid_powerbtn\] power button pressed/){
		$pressed_time = $1;
	}
	elsif ($line =~ m/([0-9]+\.[0-9]+)\] \[mid_powerbtn\] power button released/){
		$released_time = $1;
		$power_btn_time = $released_time - $pressed_time;
		print wr_file "$pressed_time\t\t$released_time\t\t$power_btn_time\n";
		$total_times = $total_times + 1;
		if ($power_btn_time < 0.2) {
			$t1 = $t1 + 1;
		} elsif ($power_btn_time < 0.3) {
			$t2 = $t2 + 1;
                } elsif ($power_btn_time < 0.4) {
                        $t3 = $t3 + 1;
                } elsif ($power_btn_time < 0.5) {
                        $t4 = $t4 + 1;
		} else {
			$t5 = $t5 + 1;
			$strangeTimeArray[$strangeTimeIndex] = "$pressed_time\t\t$released_time\t\t$power_btn_time\n";
			$strangeTimeIndex = $strangeTimeIndex +1;
		}
	}
}
close (FHD);
print "Calculating ...\n\n";
print wr_file "\n\n\n";
print_percent();
print wr_file "\n\nStrange Timestamp:\n";
for($i=0; $i<=$#strangeTimeArray; $i++) {
print wr_file "$strangeTimeArray[$i]";
}
print "Generate \"$outputfile\"\n\n";
close (wr_file);

open (wr_file,">$outputfile2");
print_percent();
print "Generate \"$outputfile2\"\n\n";
close (wr_file);

sub print_percent{
print wr_file "Total $total_times times\n";
$p1 = sprintf( "%.2f", $t1/$total_times*100);
print wr_file "0.0~0.2:\t\t$t1\ttimes\t\t$p1 %\n";
$p2 = sprintf( "%.2f", $t2/$total_times*100);
print wr_file "0.2~0.3:\t\t$t2\ttimes\t\t$p2 %\n";
$p3 = sprintf( "%.2f", $t3/$total_times*100);
print wr_file "0.3~0.4:\t\t$t3\ttimes\t\t$p3 %\n";
$p4 = sprintf( "%.2f", $t4/$total_times*100);
print wr_file "0.4~0.5:\t\t$t4\ttimes\t\t$p4 %\n";
$p5 = sprintf( "%.2f", $t5/$total_times*100);
print wr_file "0.5~   :\t\t$t5\ttimes\t\t$p5 %\n";
}
