#! /bin/bash
# FILE: cflatf_conventional.sh (an original should reside at $HOME/bash-scripts/pmas_data_red)
# AUTHOR: C. Herenz
# DATE: June 2012
# DESCR.: Create a flat-field (2D flat-field spectrum) to be used on science frame
#         - using the conventional p3d flatfielding method, i.e. transmission array 
#         and dispersion correction both from twilight flat
# USAGE:  cflatf.sh <parameter_file>, where <paramter_file> 
#         sets variables mainpath=, night=, userparfile=, parfile=,
#         - this file uses the conventional flat fielding (just twilight flat) -
#         TODO: write list of parameters here

# test if argument is provided is provided and file is existent
if [ -z "${1}" ] || [ ! -f ${1} ]; then
    # .. if not, quit gracefully!
    echo "Supply parameter file as argument!"
    exit 0
fi

# source parameter file:
source ${1}

# see other scripts for whats happening below (bash-wise):
mkdir -p ${mainpath}${night}${block}/${name} # out-dir
mkdir -p ${mainpath}${night}${block}/${name}/logs/ # logfiles(s)

cwd=`pwd`
cd ${mainpath}${night}${block}

# date & timestamp
date=`date +%m-%d-%y` # ...just in case the script is run @ 23:59
timestamp=`date +%H%M`
# ${inputfile:0:12}: runXXX_xxxxxa.fits -> runXXX_xxxxx
logname=${name}_comb_${date}--${timestamp}-${inputfile:0:12}
outfileprefix=${name}_comb_${date}--${timestamp}
logfile=${mainpath}${night}${block}/${name}/logs/${logname}.log

# out-dir
opath=${mainpath}${night}${block}/${name}

if [ ! -z "${masterbias}" ]; then
    mbias_name=`basename ${masterbias}`
# conventional flatfielding with masterbias:
    if [ -z "${tracemask}" ]; then
	echo "cflatf_conventional.sh - p3d extraction without tracemask..."
	echo "(with masterbias: ${mbias_name})"
        # extraction without tracemask, since for most twilight flats
        # no separate lamp flats were made 
	${p3d_path}/vm/p3d_cflatf_vm.sh ${rt} ${inputfile} ${parfile} masterbias=${masterbias} \
  	    dispmask=${dispmask} userparfile=${userparfile} opath=${opath} \
  	    opfx=${outfileprefix} loglevel=2 /quiet logfile=${logfile} ${special_params}
    else
      # extraction with tracemask 
	tracename=`basename ${tracemask}`
	echo "cflatf_conventional.sh - p3d extraction with tracemask ${tracename} ..."
	echo "(with masterbias: ${mbias_name})"
	${p3d_path}/vm/p3d_cflatf_vm.sh ${rt} ${inputfile} ${parfile} masterbias=${masterbias} \
  	    tracemask=${tracemask} dispmask=${dispmask} userparfile=${userparfile}  \
  	    opath=${opath} opfx=${outfileprefix} loglevel=2 /quiet logfile=${logfile} \
  	    ${special_params}
    fi
else
# conventional flatfielding without masterbias (use if constant bias / overscan bias
# is to be subtracted)
    if [ -z "${tracemask}" ]; then
	echo "cflatf_conventional.sh - p3d extraction without tracemask & WITHOUT masterbias..."
      # extraction without tracemask, since for most twilight flats
      # no separate lamp flats were made 
	${p3d_path}/vm/p3d_cflatf_vm.sh ${rt} ${inputfile} ${parfile} \
  	    dispmask=${dispmask} userparfile=${userparfile} opath=${opath} \
  	    opfx=${outfileprefix} loglevel=2 /quiet logfile=${logfile} ${special_params}
    else
      # extraction with tracemask 
	tracename = `basename ${tracemask}`
	echo "cflatf_conventional.sh - p3d extraction with tracemask ${tracename}..."
	${p3d_path}/vm/p3d_cflatf_vm.sh ${rt} ${inputfile} ${parfile}  \
  	    tracemask=${tracemask} dispmask=${dispmask} userparfile=${userparfile}  \
  	    opath=${opath} opfx=${outfileprefix} loglevel=2 /quiet logfile=${logfile} \
  	    ${special_params}
  fi
fi


# write info about this script to the beginnig of logfile ...
echo "0a
FROM cflatf_conventional.sh with parameter file ${1}, DATE: ${date}, TIME: ${timestamp:0:2}:${timestamp:2:3}
.
w" | ed ${logfile} 2> /dev/null