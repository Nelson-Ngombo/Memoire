function [cdat,Cp]=expcov(varargin)
%EXPCOV Extend covariance matrix or write covariances to model with scaling.
%
%       cdat=expcov(coeffcovar,fixpind) extends matrix with zeros for fixed
%          parameters.
%       cmodel=expcov(model,coeffcovar,fs,fixpind) also rescales
%          covariance matrix from internal scaling with fs.
%
%       Output argument:
%       cdat = "full" covariance matrix
%       cmodel = model extended by non-scaled covariance array
%
%       Input arguments:
%       model = fidmodel object to be extended by covariance
%       coeffcovar = nxn array, covariance matrix of the coefficients
%           if fixpind is not given, n must be equal to the number of the
%           numerator coefficients plus the number of the denominator
%           coefficients plus one (for the delay). If fixpind is not empty,
%           coeffcovar may not contain the rows and columns belonging to fixed
%           coefficients.
%       fs = internal scaling of coeffcovar
%       fixpind = indices of fixed parameters in the total parameter vector,
%           defined as: [num,denom,delay]', where the coefficients are in
%           descending order in the s-domain, and in ascending order in the
%           z-domain. If both fixpind is given with indices, and there are
%           zero rows and columns in coeffcovar, they must correspond to each
%           other.
%
%       Usage: cmodel=expcov(model,coeffcovar,fs,fixpind);
%              cdat=expcov(coeffcovar,fixpind);
%       Example: coeffcovar=eye(5); expcov(coeffcovar,6);
%
%       See also: IMPCOV.

%Old fdident help
%EXPCOV Write covariances to a 'covariance' vector or file (for use by ELIS).
%
%       [cdat,Cp]=EXPCOV(coeffcovar,fixpind,filename,comments,fdate)
%
%       Output arguments:
%       cdat = vector, containing the same data as a .cnt file
%       Cp = total covariance matrix (for variable and fixed parameters)
%
%       Input arguments:
%       coeffcovar = nxn array, covariance matrix of the coefficients
%           if fixpind is not given, n must be equal to the number of the
%           numerator coefficients plus the number of the denominator
%           coefficients plus one (for the delay). If fixpind is not empty,
%           coeffcovar may not contain the rows and columns belonging to fixed
%           coefficients.
%       fixpind = indices of fixed parameters in the total parameter vector,
%           defined as: [num,denom,delay]', where the coefficients are in
%           descending order in the s-domain, and in ascending order in the
%           z-domain. If both fixpind is given with indices, and there are
%           zero rows and columns in coeffcovar, they must correspond to each
%           other.
%       filename = name of the output file
%           If filename is empty or missing, no file will be generated.
%           If the name has no extension, this function extends it by '.cbn'.
%           If the extension is .cbn, the result will be a binary file, else
%           an ASCII file. If the extension is '.cnt', no text is sent to the
%           ASCII file, only data.
%       comments = string with eventual comments (optional)
%       fdate = date (and time) string (optional). If fdate is missing or
%           empty, an actual date string will be generated.
%
%       If a file is generated, the most important values will be displayed
%       on the screen, unless a global variable 'expimpmessages' with value
%       'no' is defined.
%       The file will be created in the active subdirectory or folder.
%
%       Usage: [cdat,Cp]=expcov(coeffcovar,fixpind,filename,comments,fdate);
%       Example: coeffcovar=eye(5); expcov(coeffcovar,[],'data.cbn');
%
%       See also: IMPCOV.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Dec-2000

if nargin<1, error('No input argument'), end
model=[];
model=getobjf(varargin{1},'fidmodel');
if isa(model,'idmodel'), model=fidmodel(model); end
%
if isa(model,'fidmodel')
  %New call
  if nargin<2, error('coeffcovar is not given')
  else coeffcovar=varargin{2};
  end
  if nargin<3, fs=1; else fs=varargin{3}; end
  if (length(fs)~=1)|~isnumeric(fs)|~isfinite(fs)|(fs<=0)
    error('Invalid fs')
  end
  if nargin<4, fixpind=[]; else fixpind=varargin{4}; end
  fdate=''; comments=''; filename='';
else
  if nargin<5, fdate=''; else fdate=varargin{5}; end
  if nargin<4, comments=''; else comments=varargin{4}; end
  if nargin<3, filename=''; else filename=varargin{3}; end
  if nargin<2, fixpind=[]; else fixpind=varargin{2}; end
  coeffcovar=varargin{1};
end
lc=length(coeffcovar);
if ~isempty(fixpind)
  if any(fixpind>lc+length(fixpind))|any(fixpind<0)|any(rem(fixpind,1)~=0)
    error('Invalid element in fixpind')
  end
end
%
ftype='covariance V1.0';
true=1; false=0;
separateline=true; %without text, each number in a separate line
global expimpmessages
if exist('expimpmessages')~=1, eim='yes'; else eim=expimpmessages; end
%
fixpind=sort(fixpind(:));
comments=setstr(comments); fdate=setstr(fdate);
if isempty(fdate), %generate actual date
  dat=clock;
  fdate=[date,sprintf(', %.0f:%.0f:%.0f',dat(4),dat(5),dat(6))];
end
if ~isempty(filename)
  if ~isstr(filename), error('filename is not a string'), end
  [filename,dummy,ext]=fnamanal(filename,'cbn'); lcext=setstr(ext+32);
  indlc=find(('a'<=ext)&(ext<='z')); lcext(indlc)=ext(indlc);
  if strcmp(lcext,'cnt') %No comment will be sent
    notext=true;
    ntx='flat '; %ASCII file type
  else %ASCII file
    notext=false;
    ntx='';
  end
else %filename is empty
  lcext='';
end
if strcmp(lcext,'cbn') %binary file
  fty='binary'; ntx='';
else
  fty='ASCII';
end
if ~strcmp(eim,'no')&~isempty(filename)
  disp(['expcov sending data to ',ntx,fty,' file ''',filename,''''])
end
if ~isempty(filename)
  if ~(strcmp(lcext,'cov')|strcmp(lcext,'cnt')|strcmp(lcext,'cbn'))
    disp(['Warning! Extension is ''',ext,...
              ''', instead of ''cov'' or ''cnt'' or ''cbn'''])
    lcext='cov'; %ASCII file with nonstandard extension
  end
end
%
[n,n2]=size(coeffcovar);
%
if n~=n2
  error('Covariance matrix is not quadratic')
end
if any(any(imag(coeffcovar))'),
  error('Matrix contains complex elements')
end
if any(any(isnan(coeffcovar))'),
  warning('Matrix contains NaN element(s) in expcov')
end
if ~all(all(isfinite(coeffcovar)|isnan(coeffcovar))'),
  warning('Matrix contains infinite element(s) in expcov')
end
if any(any( abs(coeffcovar-coeffcovar')>1000*eps*max(abs(diag(coeffcovar))) )')
  warning('Covariance matrix is not symmetric in expcov')
end
if any(diag(coeffcovar)<0)
  warning('Negative number in the main diagonal of coeffcovar in expcov')
end
%
zvind=find(diag(coeffcovar)==0);
if ~isempty(zvind)
  if any(any(coeffcovar(zvind,:)~=0))|any(any(coeffcovar(:,zvind)~=0))
    warning(['Nonzero covariance in row or column of ',...
        'zero variance in expcov'])
  end
end
%if isempty(zvind)&isempty(fixpind), error('no fixed parameter defined'), end
if ~isempty(fixpind)&~isempty(zvind)
  %check redundant fixing information
  OK=false;
  if length(fixpind)==length(zvind)
    if all(fixpind==zvind)
      OK=true;
    end
  end
else OK=true;
end
if OK==false, error('fixpind contradictory to coeffcovar'), end
%
if min(size(fixpind))>1, error('fixpind is not a vector'), end
if ~isempty(fixpind)&isempty(zvind)
  if (min(fixpind)<1)|(max(fixpind)>n+length(fixpind))
    error('an index in fixpind is out of range')
  end
  if any(rem(fixpind,1)~=0), error('fixpind must contain integers'), end
  if any(diff(sort(fixpind))==0)
    error('fixpind must not contain identical elements')
  end
  for i=fixpind' %insert zero rows and columns
    coeffcovar=[coeffcovar(:,1:i-1),zeros(length(coeffcovar(:,1)),1),...
                coeffcovar(:,i:length(coeffcovar(1,:)))];
    coeffcovar=[coeffcovar(1:i-1,:);zeros(1,length(coeffcovar(1,:)));...
                coeffcovar(i:length(coeffcovar(:,1)),:)];
  end
  zvind=fixpind;
  n=length(coeffcovar);
end
%
if ~isempty(filename)&(exist(filename)~=0)
  delete(filename)
  if exist(filename)~=0, error(['Cannot delete existing file ''',...
         filename,'''']), end
end
%
if ~strcmp(eim,'no')&~isempty(filename)
  fprintf('   Number of parameters: %.0f, fixed: %.0f\n',n,length(zvind))
end
if strcmp(lcext,'cnt')|strcmp(lcext,'cov') %ASCII file
  if notext==false
    %Prepare comment string for fprintf
    if ~isempty(comments)
      cr=setstr(13); lf=setstr(10); %carriage return, line feed
      commf=comments;
      %make vector from text array
      [vc,hc]=size(commf);
      if vc>1
        commf=[commf';setstr(cr*ones(1,vc))]; commf=commf(:)';
      end
      %double \ signs
      pcti=find(commf=='\');
      if ~isempty(pcti)
        for pctn=length(pcti):-1:1
          commf(pcti(pctn)+1:length(commf)+1)=commf(pcti(pctn):length(commf));
        end
      end
      %double percent signs
      pcti=find(commf=='%');
      if ~isempty(pcti)
        for pctn=length(pcti):-1:1
          commf(pcti(pctn)+1:length(commf)+1)=commf(pcti(pctn):length(commf));
        end
      end
      %delete line feed characters from cr/lf combinations
      cri=find(commf(1:length(commf)-1)==cr);
      crlfi=find([commf(cri+1),'0']==lf);
      if ~isempty(crlfi) commf(cri(crlfi)+1)=''; end
      crorlfi=find((commf==cr)|(commf==lf));
      commf(crorlfi)=setstr(lf*ones(1,length(crorlfi)));
      if max([crorlfi,0])<length(commf), commf=[commf,lf]; end
    else
      commf='';
    end
    %
    pct='%%\n';
    header=['%%filename: ',filename,', ftype: ',ftype,...
            ', date: ',fdate,'\n'];
    eof='%%End of covariance file\n';
  else %no text
    commf='';
    pct='';
    header='';
    eof='';
  end
  if separateline==true
    separ='\n    '; %cr + 4 spaces
  else
    separ='   ';
  end
  fnid=fopen(filename,'w');
  fprintf(fnid,header);
  while ~isempty(commf)
    cri=min(find(commf==lf));
    if isempty(cri), error('comment cycle error'), end
    fprintf(fnid,['%%',commf(1:cri-1),'\n']);
    commf(1:cri)='';
  end
  tenlines='';
  for k1=1:n
    fspec='%9.7e';
    tenlines=[tenlines,sprintf(fspec,coeffcovar(k1,k1))];
    for k2=k1+1:n
      if coeffcovar(k1,k2)>=0, fspec=' %9.7e'; %space if positive
      else fspec='%9.7e';
      end
      tenlines=[tenlines,sprintf([separ,fspec],coeffcovar(k1,k2))];
    end
    tenlines=[tenlines,sprintf('\n')];
    if (rem(k1,10)==0)|(k1==n),
      fprintf(fnid,tenlines); %send ten lines
      tenlines='';
      if ~strcmp(eim,'no')
        fprintf('%4.0f rows of %.0f are ready\n',k1,n)
      end
      %information message
    end
  end %for k1
  fprintf(fnid,pct);
  fprintf(fnid,eof); %end of file line
  fclose(fnid);
elseif strcmp(lcext,'cbn') %binary file
  %Matlab4.0 and later:
  save(filename,'comments','ftype','fdate','coeffcovar')
  %Compiler and Matlab4.2c and later:
  %feval('save',filename,'comments','ftype','fdate','coeffcovar')
end
%
if isa(model,'fidmodel')
  %New call
  %Scaling is necessary, then adding the variance to the model
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
        coeffcovar=coeffcovar./(fsv*fsv'); %scaling
      end
    end
  end
  %
  model.covariance=coeffcovar;
  cdat=model;
else
  if (nargout>0)|isempty(filename) %output vector defined, or no output file
    cdat=[];
    for k1=1:length(coeffcovar)
      for k2=k1:length(coeffcovar)
        cdat=[cdat;coeffcovar(k1,k2)];
      end
    end
  end
end
if nargout>1, Cp=coeffcovar; end
%
if (length(comments)>0)&(strcmp(lcext,'cbn')|strcmp(lcext,'cov'))&...
         ~strcmp(eim,'no')
  disp(['   Comments: ',comments])
end
%%%%%%%%%%%%%%%%%%%%%%%%% end of expcov %%%%%%%%%%%%%%%%%%%%%%%%%
