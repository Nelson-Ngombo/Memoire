function fdidprops(type)
%FDIDPROPS  Help on FDIDENT model and data properties.
%
%   FDIDPROPS gives details on the generic properties of FIDMODEL models.
%
%   FDIDPROPS(MODELTYPE) gives details on the properties specific
%   to the various types of models and data.  The string MODELTYPE 
%   selects the model type among the following:
%
%      'fidmodel':   Transfer function (polynomial) models
%      'fiddata':    Frequency domain data representation (FIDDATA object)
%      'tiddata':    Time domain data representation (TIDDATA object)
%      'algorithm':  Properties associated with the algorithm.
%      'estimation': Properties associated with the estimation result
%   
%   Note that you can type
%      fdidprops fidmodel
%   as a shorthand for
%      idprops('fidmodel'), and also use just the three first letters.
%
%   See also FIDMODEL, FIDDATA, TIDDATA 

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Aug-2003

if nargin==0,
   type = 'fidmodel';
elseif ~ischar(type)&~isa(type,'fidmodel')&~isa(type,'iddat')
   error('TYPE must be a string or an object.')
end
if ischar(type), obj=feval(type); else obj=type; end
if isa(type,'fiddata')|isa(type,'tiddata'), help(iddat), end
help(obj)
