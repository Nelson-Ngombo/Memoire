function [test,type]=issiglabfile(filename)
%ISSIGLABFILE Test if file is a SigLab file or not.
%
%       filename can be given simply by name or by full path 
%       type of the file ('time' or frequency') is given as a second 
%       output argument.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1999
%       All rights reserved.
%       $Revision: $
%       Last modified: 04-Dec-1999

type='';
if ~isstr(filename), error('filename is not a string'), end
if size(filename,1)~=1, error('filename is not a simple string'), end
if exist(filename)~=2, test=0; return, end

ind=findstr(filename,'.');
if isempty(ind), test=0; return, end
ext=filename(ind+1:end);
if length(ext)~=3, test=0; end
if strcmpi(ext,'mat')|strcmpi(ext,'vna')
  struc=load(filename,'-mat');
  if ~isfield(struc,'SLm'), test=0; return, end
  test=1;
  type='frequency';
end
%%%%%%%%%%%%%%%%%%%%%%%% end of issiglabfile %%%%%%%%%%%%%%%%%%%%%%%%