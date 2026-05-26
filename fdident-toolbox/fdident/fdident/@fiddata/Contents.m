% Identification toolboxes - fiddata class directory
% Version 1.3, 2-Apr-2006
%
% Class directory functions
%   addchannels - Concatenation by channels
%   addtova     - Add experiment to variance analysis
%   allfpi      - Return indices of frequency points of channel to allfreqpoints
%   applyref    - Apply reference for synchronization
%   collapse    - Reduce size of object by combining experiments
%   covelements - Show the number of defined elements in the covariance matrix
%   decouple    - Decouple fullMIMO experiment groups
%   export      - Make a structure for exchange of data with people not using fdident
%   exc_channels - Return number of single excited channel among inputs for each experiment
%   ref_channels - Return number of single all-ones reference channel among inputs for each experiment
%   idfrd       - Transform fiddata object to idfrd object
%   fiddata     - Creator function
%   fiddatah    - Textual information about the object (see help(fiddata) )
%   fou2tim     - Transform Fourier data back to time
%   frd         - Transform fiddata object to frd object
%   frf         - Calculate FRF and related variances for plotting
%   frf_power   - Calculate FRF from Guy(k)/Guu(k)
%   frfobj      - Calculate object with ones at the inputs and FRF's at the outputs
%   freqdrop    - Drop frequencies
%   freqsel     - Select frequencies
%   getloc      - Get non-field child properties
%   getconsy    - Check consistency of child properties
%   getexp      - Select experiments
%   goodsnr     - Select frequencies with good SNR (input, output or tf)
%   help        - Type out fiddatah.m
%   helpc       - Type out Contents.m
%   idpropch    - Expand property names or return set of properties
%   info        - Textual information on the object
%   interpvar   - Calculate object which contains interpolated variances 
%   inv         - Implement 1/data
%   issingleexc - Check if experiments are excited in a single channel or not
%   issingleref - Check if fullMIMO experiments are decoupled using the Reference property
%   listnot     - Return properties not to be listed by get(obj)
%   mean        - Calculate mean and variance of data
%   merge       - Unify two objects by experiments
%   mrdivide    - Implement division
%   mstotalerr  - Calculate mean square of error
%   mtimes      - Implement multiplication
%   nearest     - Select frequencies closest to elements of given frequency vector
%   nonlinvar   - Evaluate nonlinear errors over experiments
%   plot        - Plot fiddata object (maybe with fidmodel object)
%   setloc      - Set child properties
%   subsrloc    - Auxiliary function for @iddat/subsref for child properties
%   windowing   - Apply window function to data
%
% For parent functions, see @iddat/Contents.m: helpc(iddat)
%
% Other utilities:
%   help fdident

% Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
% All rights reserved.
% $Revision: $
