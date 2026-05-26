function [varx,vary,covxy,comments,fdate]=impvar(vdat)
%IMPVAR Read variances from a variance vector or file (used by ELIS).
%
%       [varx,vary,covxy,comments,fdate]=IMPVAR(vdat)
%
%       Output arguments:
%       varx = variance vector (array) of the real part (that is,
%           also of the imaginary part) of the complex input amplitudes.
%       vary = variance vector (array) of the real part (that is,
%           also of the imaginary part) of the complex output amplitudes.
%       covxy = column vector of the complex input-output covariances
%           (0.5*E{conj(Nx)*Ny}). covxy may be empty. In the MIMO case covxy
%           contains either the covariances between input1 and output1, or
%           all the covariances beside each other, as [i1o1,i1o2,...i2o1...]
%       comments = optional, comment string in the input file
%       fdate = optional, comment string in the input file (if any)
%
%       Input arguments:
%       vdat = data vector or the name of the file, or maybe an array
%               [vary,varx] or [vary,varx,covxy]; the data vector contains
%               the data in the same order as a .vnt file.
%
%       The file may be an ASCII file with comments (usual extension: .var),
%       an ASCII file without comments (.vnt), or a binary file (.vbn).
%       The file has to be somewhere within the path of matlab, or the
%       path is to be explicitly given. Default extension: .vbn.
%       If a file is read, the most important values will be displayed on the
%       screen, unless a global variable 'expimpmessages' with value 'no' is
%       defined.
%
%       Usage: [varx,vary,covxy,comments,fdate]=impvar(vdat);
%       Example: load emachine
%                [varx,vary]=impvar(emachine.SisoVariance);
%
%       See also: EXPVAR.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-Jun-2001

global expimpmessages
if exist('expimpmessages')~=1, eim='yes'; else eim=expimpmessages; end
comments=setstr([]); fdate=setstr([]);
if isstr(vdat)
  [filename,dummy,ext]=fnamanal(vdat,'vbn');
  lcext=setstr(ext+32);
  indlc=find(('a'<=ext)&(ext<='z')); lcext(indlc)=ext(indlc);
  if strcmp(lcext,'vbn') %binary file
    fty='binary'; ntx=[];
  else
    fty='ASCII';
    if strcmp(lcext,'vnt')
      ASCIItype='flat';
    else %ASCII with text
      ASCIItype='text';
    end
  end
  fty=[fty,' file ''',filename,''''];
else %vector in workspace
  [dl,dw]=size(vdat); if (dl==1)&(dw>3), vdat=vdat(:); end
  fty='vector in workspace';
  lcext='';
end %isstr(vdat)
if ~strcmp(eim,'no')&isstr(vdat)
  disp(['impvar loading data from ',fty])
end
if isstr(vdat)
  if ~(strcmp(lcext,'var')|strcmp(lcext,'vnt')|strcmp(lcext,'vbn'))
    disp(['Warning! Extension is ''',ext,...
              ''', instead of ''var'' or ''vnt'' or ''vbn'''])
    lcext='var'; %ASCII file with nonstandard extension
  end
end
%
covxy=[];
[dl,dw]=size(vdat);
if ~strcmp(lcext,'vbn')&( (dw==1)|isstr(vdat) ) %vector or ASCII file
  if isstr(vdat)
    vdat=loadasc(filename,ASCIItype);
  end
  if length(vdat)<4, error(['Not enough data in file ',filename]), end
  inputno=vdat(1); outputno=vdat(2); wc=vdat(3);
  lno=inputno+outputno+2*wc;
  if (inputno<1)|(outputno<1),
    error('Number of inputs or outputs incorrect')
  end
  if (wc~=1)&(wc~=0)&(wc~=inputno*outputno)
    error('Illegal number of covariances')
  end
  if rem(length(vdat)-3,lno)~=0,
    error('Number of data is incorrect')
  end
  ind0=[4:lno:length(vdat)]';
  varx=vdat(ind0);
  for ii=1:inputno-1
    varx=[varx,vdat(ind0+ii)];
  end
  vary=vdat(ind0+inputno);
  for ii=inputno+1:inputno+outputno-1
    vary=[vary,vdat(ind0+ii)];
  end
  for ii=inputno+outputno:2:inputno+outputno+2*wc-1
   covxy=[covxy,vdat(ind0+ii)+sqrt(-1)*vdat(ind0+ii+1)];
  end
elseif strcmp(lcext,'vbn') %binary file
  load(filename,'-mat')
  if any(any(imag([varx,vary]))')
    error('Complex elements in the variance vectors')
  end
  [dummy,wc]=size(covxy);
else %array
  %disp('Is [vy,vu] OK in impvar?'), keyboard
  if ~isempty(vdat), varx=vdat(:,2); vary=vdat(:,1);
  else varx=[]; vary=[]; 
  end
  if dw==3, covxy=vdat(:,3); else covxy=[]; end
end
if ~iscell(vary)
  if any([varx(:);vary(:)]<0)
    error('Negative variance')
  end
  if any(isnan([varx(:);vary(:);covxy(:)])),
    %error('Vectors contain NaN elements')
  end
end
if ~strcmp(eim,'no')&~isempty(lcext)
  fprintf('   Number of frequencies: %.0f, inputs: %.0f, outputs: %.0f\n',...
     length(varx(:,1)),length(varx(1,:)),length(vary(1,:)))
  if ~isempty(covxy), fprintf('   Covariances given: %.0f\n',wc), end
  if length(comments)>0
    disp(['   Comments: ',comments])
  end
end
%
if ~iscell(vary)
  infno=sum(~isfinite([varx(:);vary(:);covxy(:)]));
  if infno>0
    fprintf(['   WARNING: variance vectors contain %.0f ',...
        'infinite element(s)\n'],infno)
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%% end of impvar %%%%%%%%%%%%%%%%%%%%%%%%%
