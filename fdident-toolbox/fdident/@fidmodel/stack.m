function sys = stack(arraydim,varargin)
%STACK  Stack fidmodel objects into fidmodel array.
%
%   SYS = STACK(ARRAYDIM,SYS1,SYS2,...) produces an array of
%   models SYS by stacking the models SYS1,SYS2,... along
%   the array dimension ARRAYDIM.  All models must have the same 
%   number of inputs and outputs, and the I/O dimensions are not
%   counted as array dimensions.
%
%   For example, if SYS1 and SYS2 are two fidmodel objects with the 
%   same I/O dimensions,
%     * STACK(1,SYS1,SYS2) produces a 2-by-1 fidmodel array
%     * STACK(2,SYS1,SYS2) produces a 1-by-2 fidmodel array
%     * STACK(3,SYS1,SYS2) produces a 1-by-1-by-2 fidmodel array.
%
%   You can also use STACK to concatenate fidmodel arrays SYS1,SYS2,...
%   along some array dimension ARRAYDIM.
%
%   See also HORZCAT, VERTCAT, CAT.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 23-Oct-2001

% Offset by the two I/O dimensions
if ~isa(arraydim,'double') | ~isequal(size(arraydim),[1 1]) | arraydim<=0,
   error('First argument arraydim must be a positive integer.')
end
catdim = arraydim+2;

% Initialize output SYS to first input system
for ii=length(varargin):-1:1
  if isempty(varargin{ii}), varargin(ii)=[]; end
end
if length(varargin)==1, sys=varargin{1}; return
elseif length(varargin)==0, sys=[]; return
end
sys = varargin{1};

if ~isa(sys,'fidmodel'), error('First system is not fidmodel'), end

% Concatenate remaining input systems
for j=2:length(varargin),
   sysj = fidmodel(varargin{j});
   
   % Pad with unit sizes up to dimension DIM
   if length(sys)==1, mn=sys.num;
   else ssys=struct(sys); mn=ssys(1).num;
   end
   if isnumeric(mn), sizes=[1,1];
   else sizes = size(mn);
   end
   sizes = [sizes,ones(1,catdim-length(sizes))];
   
   if length(sysj)==1, mnj=sysj.num;
   else ssysj=struct(sysj); mnj=ssysj(1).num;
   end
   if isnumeric(mnj), sj=[1,1];
   else sj = size(mnj);
   end
   sj = [sj,ones(1,catdim-length(sj))];
   
   % Check consistency
   sizes(catdim) = [];    sj(catdim) = [];
   if ~isequal(sizes(1:2),sj(1:2)),
     error('I/O dimension mismatch.')
   elseif ~isequal(sizes(3:end),sj(3:end)),
     error(sprintf('Array sizes may only differ along dimension #%d.',arraydim))
   end
   sys=builtin('cat',arraydim,sys,sysj);
end
