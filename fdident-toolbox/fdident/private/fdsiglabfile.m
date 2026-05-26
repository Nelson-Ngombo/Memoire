function obj=fdsiglabfile(filename)
%FDSIGLABFILE Load file to fiddata or tiddata object.
%
%       filename can be given simply by name or by full path 

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1999
%       All rights reserved.
%       $Revision: $
%       Last modified: 04-Dec-1999

if ~issiglabfile(filename)
  error('Cannot generate iddat object from SigLab file')
end
ind=findstr(filename,'.');
if isempty(ind), test=0; return, end
ext=filename(ind+1:end);
if strcmpi(ext,'mat')|strcmpi(ext,'vna')
  struc=load(filename,'-mat');
  y=struc.SLm.xcmeas(1,2).xfer;
  obj=fiddata(y,ones(size(y)),struc.SLm.fdxvec);
else
  error(['Not yet ready for file ''',filename,''''])
end
%%%%%%%%%%%%%%%%%%%%%%%% end of fdsiglabfile %%%%%%%%%%%%%%%%%%%%%%%%