% Identification toolboxes - tiddata class directory
% Version 1.3, 15-May-2002
%
% Class directory functions
%   addchannels - Concatenation by channels
%   export      - Make a structure for exchange of data with people not using fdident
%   frd         - Catch calls frd on tiddata inputs
%   getconsy    - Check consistency of child properties
%   getexp      - Select experiments
%   getloc      - Get non-field child properties (nothing done at the moment)
%   help        - Type out tiddatah.m
%   helpc       - Type out Contents.m
%   idpropch    - Expand property names or return set of properties
%   info        - Textual information on the object
%   invrepeat   - Add (-1) times time sequence
%   listnot     - Return properties not to be listed by get(obj)
%   merge       - Unify two objects by experiments: [obj1 obj2]
%   mrdivide    - Divide output data in object by scalar or cell vector
%   mtimes      - Multiply output data in object by scalar or cell vector
%   plot        - Plot tiddata object
%   plus        - Unify two objects by samples: obj1 + obj2
%   repeat      - Repeat time sequence
%   resample    - Subsample time sequence by integer number
%   segment     - Segment periodic data into periods
%   segmfouvar  - Segment data, convert to Fourier domain and make variance analysis
%   setloc      - Set child properties
%   subsrloc    - Auxiliary function for @iddat/subsref for child properties
%   tiddata     - Creator function
%   tiddatah    - Textual information about the object (see help(tiddata) )
%   tidin       - Generate object with inputs only
%   tidout      - Generate object with outputs only
%   uminus      - Unitary minus (-1*object.data)
% For parent functions, see @iddat/Contents.m: helpc(iddat)
%
% Other utilities:
%   help fdident

% Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2002
% All rights reserved.
% $Revision: $
