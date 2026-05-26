% Identification toolboxes - iddat class directory
% Version 1.3, 05-Jan-2004
%
% Class directory functions
%   addchannels - Concatenation by channels
%   addgroup    - Make new group in object
%   addhist     - Add history string to existing ones of object
%   anyisnan    - Check if any data contains NaN
%   check       - Utility: display field contents with types
%   diff        - List dfferences between objects
%   eq          - Check if objects are essentially equal
%   export      - Make a structure for exchange of data with people not using fdident
%   findchnumber - find channel number(s) by channel name(s)
%   frf         - Calculate object which contains FRF's
%   get         - Get property(ties) of iddat object
%   getgroup    - Get the definition of a group
%   groupnames  - Get all groupnames in object
%   help        - Type out iddath.m
%   helpc       - Type out Contents.m
%   iddat       - Creator function
%   iddath      - Textual information about the object (see help(iddat) )
%   idpropch    - Expand property names or return set of properties
%   israndomized - Check if data come from randomized experiment
%   issiso      - True for SISO data objects
%   listnot     - Return properties not to be listed by get(obj)
%   merge       - Unify two objects by experiments
%   ne          - Check if objects essentially differ
%   plus        - Unify two objects by samples: obj1 + obj2
%   rmexp       - Remove experiment from object
%   rmgroup     - Remove group from object
%   set         - Set property(ties) of iddat object
%   setchio     - Set character ('Input' or 'Output') of channels
%   setgroup    - Set the definition of an existing group
%   shprops     - Display properties (used with get)
%   size        - channels, experiments, samples
%   subsasgn    - Define overloaded subscripted assigning
%   subsref     - Define overloaded subscripting
%
% Children: tiddata, fiddata (time and frequency domain data objects)

% Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2004
% All rights reserved.
% $Revision: $
