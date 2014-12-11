#! /bin/bash
# FILE: fluxsens.sh (an orginal should reside at $HOME/bash-scripts/pmas_data_red
# AUTHOR: C. Herenz
# DATE: September 2012
# DESCR.: Create a sensitivity function from a 1D extracted standard star spectrum
# USAGE:  fluxsens.sh <parameter_file>, where <paramter_file> 
#         sets variables input_spectrum= mainpath=, night=, block=, userparfile=, 
#         parfile=, standard_star_fmt=, standard_star_file=, extinct_file= (optional)
#         interpol_func= (splinetension= <=> interpol_func == spline)
#         (for example parameter file see ./fluxsens.params)

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
logname=${name}_${date}--${timestamp}.log
logfile=${mainpath}${night}${block}/${name}/logs/${logname}
outfileprefix=${name}_${date}--${timestamp}
opath=${mainpath}${night}${block}/${name}
# p3d call to create sensitivity function:
# (much of the stuff is undocumented here... fishing in the blind)
if [ "${interpol_func}" == 'spline' ]; then
    ${p3d_path}/vm/p3d_fluxsens_vm.sh ${rt} ${input_spectrum} ${parfile} \
        userparfile=${userparfile} ssfile_cal=${standard_star_file}  \
	extinctionfile=${extinct_file} inpfunction=${interpol_func} \
	splinetension=${splinetension} catalog=${standard_star_fmt} \
	opfx=${outfileprefix} opath=${opath} logfile=${logfile} loglevel=2 /quiet
else
    ${p3d_path}/vm/p3d_fluxsens_vm.sh ${rt} ${input_spectrum} ${parfile} \
        userparfile=${userparfile} ssfile_cal=${standard_star_file}  \
	extinctionfile=${extinct_file} inpfunction=${interpol_func} \
	catalog=${standard_star_fmt} opfx=${outfileprefix} opath=${opath} \
        logfile=${logfile} loglevel=2 /quiet
fi

# ... write info about this script to the beginnig of logfile ...
echo "0a
FROM fluxsens.sh with parameter file ${1}, DATE: ${date}, TIME: ${timestamp:0:2}:${timestamp:2:3}
STANDARD STAR SPECTRUM: ${input_spectrum}
STANDARD STAR REFERENCE: ${standard_star_file}
EXTINCTION CURVE: ${extinct_file}
INTERPOLATION FUNCTION: ${interpol_func}
USER PARAMETER FILE: ${userparfile}
INSTRUMENT PARAMETER FILE: ${parfile}
=======================---------------- ORIGINAL LOG BELOW ----------------=======================
.
w" | ed ${logfile} 2> /dev/null

cd $cwd