#!/bin/bash
# FILE: ctrace_combined.sh (an original should reside at $HOME/bash-scripts/pmas_data_red)
# AUTHOR: C. Herenz
# DATE: May 2012
# DESCR.: Same as ctrace.sh, but this time the exposures of 
#         inputlist will be combined 
# USAGE:  ctrace_combined.sh <parameter_file>, where <paramter_file> 
#         sets variables mainpath=, night=, userparfile=, parfile=,
#         inputfiles= and masterbias=
#         (for example parameter file see ./ctrace.params)


# test if argument is provided is provided and file is existent
if [ -z "${1}" ] || [ ! -f ${1} ]; then
    # .. if not, quit gracefully!
    echo "Supply parameter file as argument!"
    exit 0
fi

# source parameter file:
source $1

# test if variable 'name' is set in parameter file 
if [ -z "${name}" ]; then
    # if not - do so, since older version of the script set this here
    name='tracemask'
fi

# out directorys for trace masks and log file:
mkdir -p ${mainpath}${night}${block}/${name} # out-dir
mkdir -p ${mainpath}${night}${block}/${name}/logs/ # logfiles(s)

# remember path from where script is called and go to working dir:
cwd=`pwd`
cd ${mainpath}${night}${block}

date=`date +%m-%d-%y` # ...just in case the script is run @ 23:59
timestamp=`date +%H%M`
# ${inputfiles:0:12}: runXXX_xxxxxa.fits -> runXXX_xxxxx
logname=${name}_comb_${date}--${timestamp}-${inputfiles:0:12}
outfileprefix=${name}_comb_${date}--${timestamp}
logfile=${mainpath}${night}${block}/${name}/logs/${logname}.log

opath=${mainpath}${night}${block}/${name}/
if test -z "${masterbias}" ; then
	# p3d function call *without* master bias
	${p3d_path}/vm/p3d_ctrace_vm.sh ${rt} ${inputfiles} ${parfile} \
	    userparfile=${userparfile} opath=${opath} \
	    opfx=${outfileprefix} logfile=${logfile} ${special_params}
else
	# p3d function call *with* master bias
	${p3d_path}/vm/p3d_ctrace_vm.sh ${rt} ${inputfiles} ${parfile} \
	userparfile=${userparfile} opath=${opath} \
	opfx=${outfileprefix} logfile=${logfile} \
	masterbias=${masterbias} ${special_params}
fi

# back to where we came from
cd $cwd