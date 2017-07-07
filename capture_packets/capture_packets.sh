#!/bin/bash

###############################################
# to be done after capture with netsniff-ng tool
# see md for more details
# usage: ./capture_packets.sh output.txt final_output.txt
# 


output="$1"
new_output="$2"
awk -F, '/IP/ && /tcp/' $output | sed  's/ > / / ; s/: tcp/ tcp/ ; s/ /\t\t/g' | \
sed -n  's/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/ & \t\t/gp' | \
awk 'BEGIN {OFS=FS="\t\t"} {gsub(/\./,"",$4);gsub(/\./,"",$6)}1' | \
awk -vOS=',' -vcdate=$(date '+%Y/%m/%d') ' {print cdate, $0}' >> $new_output


########################################
# Sample final output:
#
# 2017/05/2 19:24:30.524628		IP		 172.217.20.196 		443		 172.161.0.12 		38743		tcp		42
# 2017/05/2 19:24:30.524649		IP		 172.217.20.196 		443		 172.161.0.12 		38743		tcp		38
#

