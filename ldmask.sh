#!/bin/bash
# FILE: ldmask.sh (an original should reside at $HOME/bash-scripts/pmas_data_red)
# AUTHOR: C. Herenz
# DATE: April 2012
# DESCR.: Create dispersion masks for one arclamp exposure in a given directory
#         and a given input dispersion mask. Save output masks and logfile in
#         convenient directory structure.
#         (for looping over a set of files check ldmask_loop.sh) 
# USAGE:  ldmask.sh <parameter_file>, where <paramter_file> 
#         sets variables mainpath=, night=, userparfile=, parfile=,
#         arc=, arclinefile=, input_dispersion_mask=, tracemask= and 
#         masterbias=
#         (for example parameter file see ./ldmask.params)

# test if argument is provided is provided and file is existent
if [ -z "${1}" ] || [ ! -f ${1} ]; then
    # .. if not, quit gracefully!
    echo "Supply parameter file as argument!"
    exit 0
fi

# source parameter file:
source $1

# See ctrace.sh for comments on what is happening below

mkdir -p ${mainpath}${night}${block}/${name} # out-dir
mkdir -p ${mainpath}${night}${block}/${name}/logs/ # logfiles(s)

cwd=`pwd`
cd ${mainpath}${night}${block}
date=`date +%m-%d-%y` 
timestamp=`date +%H%M`
logname=${name}_${date}--${timestamp}-${arc:0:12}
outfileprefix=${name}_${date}--${timestamp}
logfile=${mainpath}${night}${block}/${name}/logs/${logname}.log
tracemaskfile=${mainpath}${night}${block}/${tracedirname}/${tracemask}

# p3d call here:
if [ -z ${masterbias} ]; then
  # NOT USING A MASTERBIAS 
    mbias_name='--- NO MASTERBIAS WAS USED ---'
    if [ -z ${input_dispersion_mask} ]; then
        dispmaskin_name='--- NO INPUT DISPERSION MASK USED ---'
        # make dispersion mask, without input dispersion mask
        echo "ldmask.sh: Creation of dispersion mask without input dispersion mask"
        ${p3d_path}/vm/p3d_cdmask_vm.sh ${rt} ${arc} ${parfile} \
    	tracemask=${tracemaskfile} userparfile=${userparfile} \
    	opath=${mainpath}${night}${block}/${name}/ opfx=${outfileprefix} \
    	logfile=${logfile} loglevel=2 /quiet arclinefile=${arclinefile} \
    	${special_params}
    else
        # make dispersion mask from existing input dispersion mask
        # (should be one mask of this night)
        dispmaskin_name=`basename ${input_dispersion_mask}`
        echo "ldmask.sh: Creation of dispersion mask with input dispersion mask ${dispmaskin_name}"
        ${p3d_path}/vm/p3d_cdmask_vm.sh ${rt} ${arc} ${parfile} \
    	tracemask=${tracemaskfile} userparfile=${userparfile} \
            opath=${mainpath}${night}${block}/${name}/ opfx=${outfileprefix} \
            logfile=${logfile} loglevel=2 /quiet dispmaskin=${input_dispersion_mask}  \
            arclinefile=${arclinefile} ${special_params}
    fi
else
   # USING A MASTERBIAS
    mbias_name=`basename ${masterbias}`
    if [ -z ${input_dispersion_mask} ]; then
        dispmaskin_name='--- NO INPUT DISPERSION MASK USED ---'
        # make dispersion mask, without input dispersion mask
        echo "ldmask.sh: Creation of dispersion mask without input dispersion mask"
        ${p3d_path}/vm/p3d_cdmask_vm.sh ${rt} ${arc} ${parfile} masterbias=${masterbias} \
    	tracemask=${tracemaskfile} userparfile=${userparfile} \
    	opath=${mainpath}${night}${block}/${name}/ opfx=${outfileprefix} \
    	logfile=${logfile} loglevel=2 /quiet arclinefile=${arclinefile} \
    	${special_params}
    else
        # make dispersion mask from existing input dispersion mask
        # (should be one mask of this night)
        dispmaskin_name=`basename ${input_dispersion_mask}`
        echo "ldmask.sh: Creation of dispersion mask with input dispersion mask ${dispmaskin_name}"
        ${p3d_path}/vm/p3d_cdmask_vm.sh ${rt} ${arc} ${parfile} masterbias=${masterbias} \
    	tracemask=${tracemaskfile} userparfile=${userparfile} \
            opath=${mainpath}${night}${block}/${name}/ opfx=${outfileprefix} \
            logfile=${logfile} loglevel=2 /quiet dispmaskin=${input_dispersion_mask}  \
            arclinefile=${arclinefile} ${special_params}
    fi
fi

# write info about this script to the beginnig of logfile ...
echo "0a
FROM ldmask.sh with parameter file ${1}, DATE: ${date}, TIME: ${timestamp:0:2}:${timestamp:2:3}
CREATING DISPERSION MASK FROM ARCFRAME: ${arc}
USING INPUT DISPERSION MASK: ${dispmaskin_name}
USING MASTERBIAS: ${mbias_name}
.
w" | ed ${logfile} 2> /dev/null
cd $cwd