function fobj=segmfouvar(tdat,varargin);
%SEGMFOUVAR  Segment data, convert to Fourier domain and make variance analysis
%
%       The time domain data are segmented, and linear variance analysis is
%       performed. Among experiments, nonlinear variance analysis is executed.
%       If the experiments are linearly related to each other,
%       nonlinvar2var(fobj) gives the result of linear analysis, or a last argument
%       given as 'linear' will force the function to execute this.

%       If fname and expi are given, then the function given by string fname
%       will be called with the arguments in expi to obtain individual
%       experiments.
%
%       Examples:
%         fobj=segmfouvar(tdat);
%         fobj=segmfouvar(tdat,fname,expi);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Jan-2004

if (nargin>=2)&isstr(varargin{1})&~strncmp(varargin{1},'linear',3)
  if get(tdat,'expnumber')>0
    error('tdat is not empty: further input arguments are not allowed')
  end
  fname=varargin{1};
  expi=varargin{2}; expi=expi(:)';
else
  expi=1:get(tobj,'expnumber');
end
if (nargin>=2)&isstr(varargin{1})&strncmp(varargin{1},'linear',3)
  sync='linear';
else sync='';
end
for ie=expi
  if isempty(fname)
    Struc.type='{}'; Struc,subs={':',ie};
    tobji=subsref(tobj,Struc);
  else 
    tobji=feval(fname,ie);
  end
  fobji=varanal(tim2fou(segment(tobji)));
  if ie==1, fobj=[]; end;
  fobj=addtova(fobj,fobji,'nonlinear');
end %for ie
if strcmp('sync,'linear'), fobj=nonlinvar2var(fobj); end
% end ../@tiddata/segmfouvar.m