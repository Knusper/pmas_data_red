#! /bin/bash
# FILE: fluxcal.sh (an orginal should reside at $HOME/bash-scripts/pmas_data_red
# AUTHOR: C. Herenz
# DATE: September 2012
# DESCR.: Flux calibrate an exposure using the sensitivity fuction
# USAGE:  fluxsens.sh <parameter_file>, where <paramter_file> 
#         sets variables mainpath=, night=, block=, userparfile=, parfile=,
#         extracted_name=, sensfunc=, extinct_file=, input_rss=
#         (for example parameter file see ./fluxcal.params)

# test if argument is provided is provided and file is existent
if [ -z "${1}" ] || [ ! -f ${1} ]; then
    # .. if not, quit gracefully!
    echo "Supply (existing) parameter file as argument!"
    exit 0
fi

# source parameter file:
source $1

# see other scripts for whats happening below (bash-wise):
mkdir -p ${mainpath}${night}${block}/${name} # out-dir
mkdir -p ${mainpath}${night}${block}/${name}/logs/ # logfiles(s)

cwd=`pwd`
cd ${mainpath}${night}${block}/${extracted_name}/

date=`date +%m-%d-%y` 
timestamp=`date +%H%M`
logname=${name}_${date}--${timestamp}.log
logfile=${mainpath}${night}${block}/${name}/logs/${logname}
outfileprefix=${name}_${date}--${timestamp}
opath=${mainpath}${night}${block}/${name}

# p3d fluxcalibration tool call
${p3d_path}/vm/p3d_fluxcal_vm.sh ${rt} ${input_rss} ${parfile} sensfunc=${sensfunc} \
    userparfile=${userparfile} extinctionfile=${extinct_file}  \
    opath=${opath} opfx=${outfileprefix} logfile=$logfile loglevel=2 /quiet 

# DONE
cd $cwd