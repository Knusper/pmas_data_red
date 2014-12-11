#!/bin/bash
# FILE:   ldmask_loop.sh (an original should reside at $HOME/bash-scripts/pmas_data_red)
# AUTHOR: C. Herenz
# DATE:   April 2012
# DESCR.: Create dispersion masks for a list of arclamp exposure in a given directory
#         and a given input dispersion mask. Save output masks and logfile in
#         convenient directory structure. 
# USAGE:  ldmask_loop.sh <parameter_file>, where <paramter_file> 
#         sets variables mainpath=, night=, userparfile=, parfile=,
#         input_dispersion_mask=, arclinefile=, arcs=, tracedirname=, traces=,
#         masterbias=, 
#         (for example parameter file see ./ldmask_loop.params)

# test if argument is provided is provided and file is existent
if [ -z "${1}" ] || [ ! -f ${1} ]; then
    # .. if not, quit gracefully!
    echo "Supply parameter file as argument!"
    exit 0
fi

# source parameter file:
source $1

# (see ctrace.sh for comments on what is happening below)
name='dispmask'
mkdir -p ${mainpath}${night}${block}/${name} # out-dir
mkdir -p ${mainpath}${night}${block}/${name}/logs/ # logfiles(s)
cwd=`pwd`
cd ${mainpath}${night}${block}
oldIFS=$IFS
IFS=','
# iterate over traces simultaneously!:
trace_array=($traces)
i=0
for arc in $arcs
do
    date=`date +%m-%d-%y` 
    timestamp=`date +%H%M`
    logname=${name}_${date}--${timestamp}-${arc:0:12}
    outfileprefix=${name}_${date}--${timestamp}
    logfile=${mainpath}${night}${block}/${name}/logs/${logname}.log
    tracemaskfile=${mainpath}${night}${block}/${tracedirname}/${trace_array[${i}]}
    dispmaskin_name=`basename ${input_dispersion_mask}`
    if test -z "${masterbias}"
    then
	echo "ldmask_loop.sh: Creation of dispersion mask from ${arc} without masterbias."
	mbias_name='--- NO MASTERBIAS SPECIFIED ---'
        # p3d call *without* masterbias:
	${p3d_path}/vm/p3d_cdmask_vm.sh ${rt} ${arc} ${parfile} \
	    tracemask=${tracemaskfile} userparfile=${userparfile} \
	    opath=${mainpath}${night}${block}/${name}/ opfx=${outfileprefix} \
	    logfile=${logfile} loglevel=2 /quiet dispmaskin=${input_dispersion_mask}  \
	    arclinefile=${arclinefile} ${special_params}
    else
	mbias_name=`basename ${masterbias}`	
	echo "ldmask_loop.sh: Creation of dispersion mask from ${arc}."
        # p3d call *with* masterbias:
	${p3d_path}/vm/p3d_cdmask_vm.sh ${rt} ${arc} ${parfile} masterbias=${masterbias} \
	    tracemask=${tracemaskfile} userparfile=${userparfile} \
	    opath=${mainpath}${night}${block}/${name}/ opfx=${outfileprefix} \
	    logfile=${logfile} loglevel=2 /quiet dispmaskin=${input_dispersion_mask}  \
	    arclinefile=${arclinefile} ${special_params}
    fi
    let "i=i+1"
    # write info about this script to the beginnig of logfile using ed
    echo "0a
FROM ldmask_loop.sh with parameter file ${1}, DATE: ${date}, TIME: ${timestamp:0:2}:${timestamp:2:3}
CREATING DISPERSION MASK FROM ARCFRAME: ${arc}
USING INPUT DISPERSION MASK: ${dispmaskin_name}
USING MASTERBIAS: ${mbias_name}
==============================--------------------
.
w" | ed ${logfile} 2> /dev/null

done
# ...finish!
IFS=$oldIFS


cd $cwd