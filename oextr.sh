#! /bin/bash
# FILE: oextr.sh (an original should reside at $HOME/bash-scripts/pmas_data_red)
# AUTHOR: C. Herenz
# DATE: May 2012
# DESCR.: Extract an spectrum from  raw exposure(s). 
# USAGE:  oextr.sh <parameter_file>, where <paramter_file> 
#         sets variables mainpath=, night=, userparfile=, parfile=,
#         inputfiles= and masterbias=
#         (for example parameter file see ./oextr.params)


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
cd ${mainpath}${night}${block}

date=`date +%m-%d-%y` 
timestamp=`date +%H%M`
# ${inputfiles:0:12}: runXXX_xxxxxa.fits -> runXXX_xxxxx
logname=${name}_${date}--${timestamp}-${inputfile:0:12}
logfile=${mainpath}${night}${block}/${name}/logs/${logname}.log
outfileprefix=${name}_${date}--${timestamp}

# object extraction
opath=${mainpath}${night}${block}/${name}/
if [ ! -z "${masterbias}" ]; then
mbiasname=`basename ${masterbias}`
if [ ! -z "${flatfield}" ]; then
    flatname=`basename ${flatfield}`
    biasname=`basename ${masterbias}`
    echo "Extraction of ${inputfile} with flatfield ${flatname} and with masterbias ${biasname}"
    # extraction with flatfield
    ${p3d_path}/vm/p3d_cobjex_vm.sh ${rt} ${inputfile} ${parfile} \
	masterbias=${masterbias} tracemask=${tracemask} dispmask=${dispmask} \
	flatfield=${flatfield} userparfile=${userparfile} opath=${opath} \
	opfx=${outfileprefix} loglevel=2 /quiet logfile=${logfile} \
	${special_params} 
else
    flatname='--- NO FLATFIELD USED! ---'
    echo "Extraction of ${inputfile} WITHOUT flatfield!!! (with masterbias)"
    # extraction without flatfield
    ${p3d_path}/vm/p3d_cobjex_vm.sh ${rt} ${inputfile} ${parfile} \
	masterbias=${masterbias} tracemask=${tracemask} dispmask=${dispmask} \
	userparfile=${userparfile} opath=${opath} \
	opfx=${outfileprefix} loglevel=2 /quiet logfile=${logfile} \
	${special_params} 
fi
else
mbiasname='--- NO MASTERBIAS USED! ---'
if [ ! -z "${flatfield}" ]; then
    flatname=`basename ${flatfield}`
    echo "Extraction of ${inputfile} with flatfield ${flatname} WITHOUT masterbias."
    # extraction with flatfield
    ${p3d_path}/vm/p3d_cobjex_vm.sh ${rt} ${inputfile} ${parfile} \
	tracemask=${tracemask} dispmask=${dispmask} \
	flatfield=${flatfield} userparfile=${userparfile} opath=${opath} \
	opfx=${outfileprefix} loglevel=2 /quiet logfile=${logfile} \
	${special_params} 
else
    flatname='--- NO FLATFIELD USED! ---'
    biasname=`basename ${masterbias}`
    echo "Extraction of ${inputfile} WITHOUT flatfield (!!!) & masterbias ${biasname}"
    # extraction without flatfield
    ${p3d_path}/vm/p3d_cobjex_vm.sh ${rt} ${inputfile} ${parfile} \
	tracemask=${tracemask} dispmask=${dispmask} \
	userparfile=${userparfile} opath=${opath} \
	opfx=${outfileprefix} loglevel=2 /quiet logfile=${logfile} \
	${special_params} 
fi
fi
# ... write info about this script to the beginnig of logfile ...
echo "0a
FROM oextr.sh with parameter file ${1}, DATE: ${date}, TIME: ${timestamp:0:2}:${timestamp:2:3}
EXTRACTING FRAME: ${inputfile}
USING DISPERSION MASK: ${dispmask}
USING TRACEMASK: ${tracemask}
USING FLATFIELD: ${flatfield}
USING MASTERBIAS: ${masterbias}
=======================---------------- ORIGINAL LOG BELOW ----------------=======================
.
w" | ed ${logfile} 2> /dev/null

cd $cwd