#!/bin/bash
# FILE:   mbias.sh (an original should reside at $HOME/bash-scripts/pmas_data_red)
# AUTHOR: C. Herenz
# DATE:   March 2012
# DESCR.: Creates a master bias from a given list of files + parameter file using 
#         p3d
# USAGE:  mbias.sh <parameter_file>, where <paramter_file> 
#         sets variables mainpath=, night=, bias=, userparfile=, parfile=,
#         inputfiles= and name= 
#         (for example parameter file see ./mbias.params)


# test if argument is provided is provided and file is existent
if [ -z "${1}" ] || [ ! -f ${1} ]; then
    # .. if not, quit gracefully!
    echo "Supply parameter file as argument!"
    exit 0
fi

# source parameter file:
source ${1}

# =====================================================

# create directories for output files ...
mkdir -p ${mainpath}${night}${bias}/${name}
# ... and log files 
mkdir -p ${mainpath}${night}${bias}/${name}/logs/

date=`date +%m-%d-%y`
timestamp=`date +%H%M`
logname=${name}_${date}--${timestamp}
logfile=${mainpath}${night}${bias}/${name}/logs/${logname}.log

# remember where we are coming from...
cwd=`pwd`
# ..going to where nice stuff is going to happen (well.. a master bias is created)
cd ${mainpath}${night}${bias}
# Actual creation of master-bias:
${p3d_path}/vm/p3d_cmbias_vm.sh ${rt} ${inputfiles} ${parfile} userparfile=${userparfile} \
    opath=${mainpath}${night}${bias}/${name} detector=0 \
    logfile=$logfile loglevel=2 /quiet opfx=$logname

# ... write info about this script to the beginnig of logfile ...
echo "0a
FROM mbias.sh with parameter file ${1}, DATE: ${date}, TIME: ${timestamp:0:2}:${timestamp:2:3}
.
w" | ed ${logfile} 2> /dev/null

# ... and finally go back to where we came from
cd $cwd