function [coeffcovar,fixpind,comments,fdate]=impcov(cdat,varargin)
%IMPCOV Read covariance matrices from a model, covariance vector or a file.
%
%       [coeffcovar,fixpind,comments,fdate]=IMPCOV(cdat,nofixp,fs)
%
%       Output arguments:
%       coeffcovar = (scaled) covariance matrix (array), see also nofixp
%       fixpind = indices of fixed parameters in the total parameter vector,
%           defined as: [num,denom,delay]', where the coefficients are in
%           descending order in the s-domain, and in ascending order in the
%           z-domain. The fixed parameters are recognized from zero rows and
%           columns in the covariance matrix.
%       comments = optional, comment string in the input file
%       fdate = optional, comment string in the input file (if any)
%
%       Input arguments:
%       cdat = data vector or the name of the file; the data vector contains
%           the data in the same order as a .cnt file (see EXPCOV).
%           cdat may also be the covariance matrix itself (with zero
%           rows/columns for the fixed parameters).
%       fs = scaling frequency between storage and internal representation.
%           If it is empty, the value in the model will be used
%           Both forms impcov(cdat,fs,'nofixp') and impcov('cdat,'nofixp',fs)
%           are allowed.
%       nofixp = if this is given with value 'nofixp', the zero rows and
%           columns in coeffcovar will be deleted.  Default: nofixp='';
%
%       Usage: [coeffcovar,fixpind,comments,fdate]=impcov(cdat,,fs,nofixp);
%       Example: inpchans=loadvar('inpchmod',inpchans');
%                [coeffcov,fixpind]=impcov(inpchans.covariance,'nofixp');
%                %Covariances of free parameters only
%
%       See also: EXPCOV, IMPPAR.

%Old fdident help
%IMPCOV Read covariance matrices from a covariance vector or a file.
%
%       [coeffcovar,fixpind,comments,fdate]=IMPCOV(cdat,nofixp)
%
%       Output arguments:
%       coeffcovar = covariance matrix (array), see also nofixp
%       fixpind = indices of fixed parameters in the total parameter vector,
%           defined as: [num,denom,delay]', where the coefficients are in
%           descending order in the s-domain, and in ascending order in the
%           z-domain. The fixed parameters are recognized from zero rows and
%           columns in the covariance matrix.
%       comments = optional, comment string in the input file
%       fdate = optional, comment string in the input file (if any)
%
%       Input arguments:
%       cdat = data vector or the name of the file; the data vector contains
%           the data in the same order as a .cnt file (see EXPCOV).
%           cdat may also be the covariance matrix itself (with zero
%           rows/columns for the fixed parameters).
%       nofixp = if this is given with value 'nofixp', the zero rows and
%           columns in coeffcovar will be deleted.  Default: nofixp='';
%
%       The file may be an ASCII file with comments (usual extension: .cov),
%       or an ASCII file without comments (.cnt), or a binary file (.cbn).
%       The file has to be somewhere within the path of matlab, or the
%       path is to be explicitly given. Default extension: .cbn.
%       If a file is read, the most important values will be displayed on the
%       screen, unless a global variable 'expimpmessages' with value 'no' is
%       defined.
%
%       Usage: [coeffcovar,fixpind,comments,fdate]=impcov(cdat,nofixp);
%       Example: inpchans=loadvar('inpchmod',inpchans');
%                [coeffcov,fixpind]=impcov(inpchans.covariance,'nofixp');
%                %Covariances of free parameters only
%
%       See also: EXPCOV.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 23-Feb-2000

cdat=getobjf(cdat,'fidmodel');
if isa(cdat,'idmodel'), cdat=fidmodel(cdat); end
nofixp=''; fs=NaN;
if isa(cdat,'fidmodel')
  %new call
  model=cdat;
  cdat=model.covariance;
  for ii=1:length(varargin)
    if isstr(varargin{ii})
      nofixp=varargin{ii};
    else
      fs=varargin{ii};
      if isnan(fs), error('fs is given as NaN'), end
    end
  end %for ii
  if isnan(fs), fs=1; end
else
  %old call
  if nargin>1, nofixp=varargin{1}; end
  if nargin>2, error('Too many input arguments'), end
end
%
comments=''; fdate=''; fixpind=[];
if isempty(cdat)
  coeffcovar=[];
  warning('Covariance matrix is empty')
  return
end
%
global expimpmessages
if exist('expimpmessages')~=1, eim='yes'; else eim=expimpmessages; end
if isstr(cdat)
  [filename,dummy,ext]=fnamanal(cdat,'cbn'); lcext=setstr(ext+32);
  indlc=find(('a'<=ext)&(ext<='z')); lcext(indlc)=ext(indlc);
  if strcmp(lcext,'cbn') %binary file
    fty='binary'; ntx=[];
  else %ASCII file
    fty='ASCII';
    if strcmp(lcext,'cnt')
      ASCIItype='flat';
    else %ASCII with text
      ASCIItype='text';
    end
  end
  fty=[fty,' file ''',filename,''''];
else %vector in workspace
  if min(size(cdat))==length(cdat), fty='array in workspace';
  else fty='vector in workspace';
  end
  lcext='';
end %isstr(cdat)
if ~strcmp(eim,'no')&isstr(cdat)
  disp(['impcov loading data from ',fty])
end
if isstr(cdat)
  if ~(strcmp(lcext,'cov')|strcmp(lcext,'cnt')|strcmp(lcext,'cbn'))
    disp(['Warning! Extension is ''',ext,...
              ''', instead of ''cov'' or ''cnt'' or ''cbn'''])
    lcext='cov'; %ASCII file with nonstandard extension
  end
end
%
if ~strcmp(lcext,'cbn') %vector or ASCII file
  if isstr(cdat)
    cdat=loadasc(filename,ASCIItype);
  end
  if length(cdat)==0, error(['No data in file ',filename]), end
  scdat=size(cdat);
  if scdat(1)~=scdat(2)
    xsize=length(cdat);
    n=(-0.5+sqrt(0.5^2+4*0.5*xsize))/(2*0.5); %solution of 2nd order eq.
    if abs(round(n)-n)>n*10*eps,
      error('Number of data is not n*(n+1)/2')
    end
    coeffcovar=zeros(n,n);
    for i=1:n
      coeffcovar(i,i:n)=cdat((i-1)*(2*n-i+2)/2+[1:(n-i+1)])';
      coeffcovar(i:n,i)=coeffcovar(i,i:n)';
    end
  else %array given
    coeffcovar=cdat;
  end
else %binary file
  load(filename,'-mat');
  [n,n2]=size(coeffcovar);
  if n~=n2,
    error('Covariance matrix is not quadratic')
  end
  if any(any(imag(coeffcovar))')
    error('Complex elements in the covariance matrix')
  end
  if any(any( abs(coeffcovar-coeffcovar')>eps*max(diag(coeffcovar)) )')
    error('Covariance matrix must be symmetric')
  end
end
if any(diag(coeffcovar)<0)
  error('Negative variance in file')
end
fixpind=find(diag(coeffcovar)==0);
if ~isempty(fixpind)
  if any(any(coeffcovar(fixpind,:)~=0))|any(any(coeffcovar(:,fixpind)~=0))
    error('nonzero covariance in row or column of zero variance')
  end
end
%
if isempty(fs), fs=model.fs; end
if ~isnan(fs)&(fs~=1)
  %scaling follows
  numo=length(model.num)-1;
  denomo=length(model.denom)-1;
  var=model.variable;
  if isempty(findstr(var,'z')) %exclude z-domain
    if ~strcmp(model.representation,'orthopol') %exclude orthopol
      if strcmp(var,'s')
        fsv=[fs.^[numo:-1:0],fs.^[denomo:-1:0],fs]';
      else
        fsv=[sqrt(fs).^[numo:-1:0],sqrt(fs).^[denomo:-1:0],fs]';
      end
      coeffcovar=(fsv*fsv').*coeffcovar; %scaling
    end
  end
end
%
if strcmp(nofixp,'nofixp') %delete zero rows/columns
  coeffcovar(:,fixpind)=[];
  if ~isempty(coeffcovar), coeffcovar(fixpind,:)=[]; end
end
%
if ~strcmp(eim,'no')&~isempty(lcext)
  fprintf('   Number of parameters: %.0f, fixed: %.0f\n',n,length(fixpind))
  if (length(comments)>0)
    disp(['   Comments: ',comments])
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%% end of impcov %%%%%%%%%%%%%%%%%%%%%%%%%
