#!/bin/bash
# FILE: ctrace.sh (an original should reside at $HOME/bash-scripts/pmas_data_red)
# AUTHOR: C. Herenz
# DATE: April 2012
# DESCR.: Create trace masks for a list of files in a given directory -
#         and a given parameter file. Save output masks and logfile in
#         convenient directory structure.
# USAGE:  ctrace.sh <parameter_file>, where <paramter_file> 
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

# out directorys for trace masks and log file:
name='tracemask'
mkdir -p ${mainpath}${night}${block}/${name} # out-dir
mkdir -p ${mainpath}${night}${block}/${name}/logs/ # logfiles(s)

# remember path from where script is called and go to working dir:
cwd=`pwd`
cd ${mainpath}${night}${block}

# iterate over inputfile list and perform the tracing algorithm
oldIFS=$IFS # internal file seperator needs to be changed here,
IFS=','     # but to avoid screwing things up we make a backup and restore it later
for contframe in $inputfiles
do
    echo "Tracing on $contframe..."
    date=`date +%m-%d-%y` # ...just in case the script is run @ 23:59
    timestamp=`date +%H%M`
    # ${conframe:0:12}: runXXX_xxxxxa.fits -> runXXX_xxxxx
    logname=${name}_${date}--${timestamp}-${contframe:0:12}
    outfileprefix=${name}_${date}--${timestamp}
    logfile=${mainpath}${night}${block}/${name}/logs/${logname}.log
    if test -z "${masterbias}" 
    then
	mbias_name='--- NO MASTERBIAS SPECIFIED ---'
	# p3d function call *without* master bias
	echo "Tracing without master bias."
	${p3d_path}/vm/p3d_ctrace_vm.sh ${rt} ${s} ${contframe} ${parfile} \
	    userparfile=${userparfile} opath=${mainpath}${night}${block}/${name}/ \
	    opfx=${outfileprefix} logfile=${logfile} ${special_params}
    else
	# p3d function call *with* master bias
	mbias_name=`basename ${masterbias}`
	echo "Tracing with master bias: ${mbias_name}"
	${p3d_path}/vm/p3d_ctrace_vm.sh ${rt} ${s} ${contframe} ${parfile}  \
	    userparfile=${userparfile} opath=${mainpath}${night}${block}/${name}/ \
	    opfx=${outfileprefix} logfile=${logfile} masterbias=${masterbias} \
	    ${special_params}
    fi
    # write info about this script to the beginnig of logfile using ed
    echo "0a
FROM ctrace.sh with parameter file ${1}, DATE: ${date}, TIME: ${timestamp:0:2}:${timestamp:2:3} 
TRACING ON FRAME: ${contframe} 
USING MASTERBIAS: ${mbias_name}
.
w" | ed ${logfile} 2> /dev/null
done

# restore original internal file seperator
IFS=$oldIFS

cd $cwd

# back to where we came from
cd $cwd

