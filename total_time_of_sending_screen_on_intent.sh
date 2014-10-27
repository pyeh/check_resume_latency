#!/bin/bash 

file_name=$1


echo "file name: $file_name"

grep 'power_screen_broadcast_done: \[1' $file_name  > after_parsing_want_log.txt


grep . after_parsing_want_log.txt | sort -t ',' -k 2 -n -r > after_sorting_intent_time.txt



awk 'BEGIN {
    FS=","
    shorter_0_5_count=0
    between_0_5_to_1_count=0
    between_1_to_1_5_count=0
    higher_1_5_count=0
    total_count=0
}
{
    this_row_intent_time=$2
    this_row_string=$0

    total_count=total_count+1


    print this_row_string
	    
    if(this_row_intent_time<500)
	shorter_0_5_count=shorter_0_5_count+1
    else if(this_row_intent_time>=500 && this_row_intent_time<1000)
	between_0_5_to_1_count=between_0_5_to_1_count+1
    else if(this_row_intent_time>=1000 && this_row_intent_time<1500)
	between_1_to_1_5_count=between_1_to_1_5_count+1
    else if(this_row_intent_time>=1500)
	higher_1_5_count=higher_1_5_count+1

}
END {
    shorter_0_5_percent=(shorter_0_5_count/total_count) * 100
    between_0_5_to_1_percent=(between_0_5_to_1_count/total_count) * 100
    between_1_to_1_5_percent=(between_1_to_1_5_count/total_count) * 100
    higher_1_5_percent=(higher_1_5_count/total_count) * 100

    printf "\n"
    printf "result::" "\t" "total:" "\t" total_count "\n"

    printf "result::" "\t" "0~0.5s:" "\t" shorter_0_5_count "\t"
    printf "%.2f %%\n", shorter_0_5_percent

    printf "result::" "\t" "0.5~1s:" "\t" between_0_5_to_1_count "\t"
    printf "%.2f %%\n", between_0_5_to_1_percent

    printf "result::" "\t" "1~1.5s:" "\t" between_1_to_1_5_count "\t"
    printf "%.2f %%\n", between_1_to_1_5_percent

    printf "result::" "\t" "1.5s~:" "\t" higher_1_5_count "\t"
    printf "%.2f %%\n", higher_1_5_percent
}' after_sorting_intent_time.txt > result.txt


grep 'result::' result.txt > result_only_percent.txt

rm after_parsing_want_log.txt 
rm after_sorting_intent_time.txt

exit 0
