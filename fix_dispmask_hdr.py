#! /usr/bin/env python
#  p3d version 2.6.X until version ??? has a problem
#  with reading input dispersion masks properly (which we may use in ldmask.sh).
#  The following python lines fix this.

import sys
from astropy.io import fits

filename = sys.argv[1]

hdu = fits.open(filename)

params_header = hdu['PARAMS'].header

for key in params_header.keys():
    if key.startswith('ARCL') and not key.startswith('ARCLN'):
        print(key,params_header[key])
        num = int(key[-4:])
        num_str = 'ARCLN'+str(num).zfill(3)
        params_header[num_str] = params_header[key]

hdu.writeto(filename[:-4]+'hdrfix.fits', output_verify='ignore')
