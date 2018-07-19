#!/bin/bash

##import configuration file
source ./settings.txt


##Find the amount of total memories
total_k=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo);
echo "system has: $(($total_k/1000)) M of free memories   ";

##Find out the LDA required
LDA=$(echo "sqrt(125*$total_k*0.85)"|bc); 
LDA=$( printf "%.0f" $LDA );
echo "LINPACK LDA is: $LDA";

##Prepare the LINPACK input file
rm -f input.dat>>/dev/null
echo "Intel(R) Optimized LINPACK Benchmark data file: input.dat" >> input.dat
echo "Generated automatically by RunMe.sh" >> input.dat
echo "1             # number of tests" >> input.dat
echo "$LDA # problem sizes" >> input.dat
echo "$LDA # leading dimensions" >> input.dat
echo "$how_many_passes      # times to run a test" >> input.dat
echo "1 # alignment values (in KBytes)" >> input.dat


##The following is modified from "runme_xeon64" from Intel.
#===============================================================================
# Copyright 2001-2016 Intel Corporation All Rights Reserved.
#===============================================================================

echo "This is run script for SMP LINPACK, automated"

# Setting up affinity for better threading performance
export KMP_AFFINITY=nowarnings,compact,1,0,granularity=fine

# Use numactl for better performance on multi-socket machines.
nnodes=`numactl -H 2>&1 | awk '/available:/ {print $2}'`
cpucores=`cat /proc/cpuinfo | awk '/cpu cores/ {print $4; exit}'`

#if [ $nnodes -gt 1 -a $cpucores -gt 8 ]
#then
#    numacmd="numactl --interleave=all"
#else
#    numacmd=
#fi

numacmd=

echo "run time in minutes: $run_time_in_m"

run_time_in_s=$((run_time_in_m * 60));


echo "run time in seconds: $run_time_in_s"

arch=xeon64
chmod 777 xlinpack_$arch
{
  date
  timeout $run_time_in_s $numacmd ./xlinpack_$arch input.dat
  echo -n "Done: "
  date
} | tee LastResult.txt

