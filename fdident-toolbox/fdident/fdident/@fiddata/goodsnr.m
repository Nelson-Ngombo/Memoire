function Out=goodsnr(Fdat,varargin)
%GOODSNR  Select frequencies with good SNR (input, output or tf)
%
%       varargin: 'input',dB and/or 'output',dB and/or 'tf',dB
%       dB is the limit in dB
%       the conditions apply in and mode (all given conditions apply)
%       Default: input SNR > 10 dB
%
%       Examples:
%         load aluplate
%         plot(goodsnr(aluplate,'input',52),'#');
%         plot(goodsnr(aluplate,'tf',20,'input',52),'*');

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-May-2002

s=''; elim=inf; Out=Fdat;
for ii=1:length(varargin)
  if ~any(ii==elim)
    if ~isstr(varargin{ii}), error(sprintf('varargin{%.0f} is not a string',ii)), end
    if length(varargin)<ii+1, error('improper number of input arguments'), end
    if strncmpi(varargin{ii},'in',2)|strcmpi(varargin{ii},'u')
      il=varargin{ii+1}; s=[s,'i'];
      if length(findstr(s,'i'))>1, error('Input is given twice'), end
      elim=[elim;ii;ii+1];
    elseif strncmpi(varargin{ii},'out',3)|strcmpi(varargin{ii},'y')
      ol=varargin{ii+1}; s=[s,'o'];
      if length(findstr(s,'o'))>1, error('Output is given twice'), end
      elim=[elim;ii;ii+1];
    elseif strncmpi(varargin{ii},'fun',3)|strcmpi(varargin{ii},'tf')
      tfl=varargin{ii+1}; s=[s,'t'];
      if length(findstr(s,'t'))>1, error('tf is given twice'), end
      elim=[elim;ii;ii+1];
    end
  end
end %for ii
N=get(Fdat,'freqnumber'); ind=[1:N]';
%
if isempty(s), s='i'; il=20; end %default
%
if any(findstr(s,'i'))
  U=get(Fdat,'input'); v=get(Fdat,'inputvariance');
  if isempty(U)|isempty(v)
    warning('Cannot determine input SNR values')
  else
    if isnumeric(U)&isnumeric(v)
      if length(U)==length(v), v=v(ind); end
      if ~isempty(U), U=U(ind); end
      SNR1=20*log10(abs(U)); SNR2=10*log10(abs(v));
			%SNR=SNR1-SNR2;
			ind2=find((SNR1-SNR2>il)&(abs(U)>1e-16*length(U)*max(abs(U))));
			ind=ind(ind2);
		else
			if iscell(U)&isnumeric(v)
				if length(v)==1
					v0=v; v=U;
					for ii=1:length(U), v{ii}=v0*U{ii}; end
				end
			end
      for ii=1:length(U)
				v{ii}=v{ii}(ind);
				if ~isempty(U{ii}), U{ii}=U{ii}(ind); end
			  if ii==1
					SNR1=20*log10(abs(U{ii})); SNR2=10*log10(abs(v{ii}));
					%SNR=SNR1-SNR2;
					ind2=find((SNR1-SNR2>il)&(abs(U{ii})>1e-16*length(U{ii})*max(abs(U{ii}))));
					ind=ind(ind2); U{ii}=U{ii}(ind2); v{ii}=v{ii}(ind2);
				end
			end
		end
	end
end
%
if any(findstr(s,'o'))
  Y=get(Fdat,'output'); v=get(Fdat,'outputvariance');
  if isempty(Y)|isempty(v)
    warning('Cannot determine output SNR values')
  else
    if ~isempty(Y)
      if length(Y)==length(v), v=v(ind); end
      if ~isempty(Y), Y=Y(ind); end
      SNR1=20*log10(abs(Y)); SNR2=10*log10(abs(v));
      ind2=find(SNR1-SNR2>ol);
      ind=ind(ind2);
    end
  end
end
if any(findstr(s,'t'))
  U=get(Fdat,'input'); vu=get(Fdat,'inputvariance');
  Y=get(Fdat,'output'); vy=get(Fdat,'outputvariance');
  if isempty(Y)|isempty(U)|(isempty(vu)&isempty(vy))
    warning('Cannot determine transfer function SNR values')
  else
    if any(size(U)~=size(Y)), error('Not a SISO system'), end
    if length(U)==length(vu), vu=vu(ind); end
    if length(Y)==length(vy), vy=vy(ind); end
    cuy=get(Fdat,'covvect');
    if length(Y)==length(cuy), cuy=cuy(ind); end
    U=U(ind); Y=Y(ind); 
    SNR1=20*log10(abs(Y./U));
    %vartf1{ii}=(varx{ii}.*abs(tfm1).^2 + vary{ii} - 2*real(covxy{ii}.*conj(tfm1)))...
    %  ./abs(xm{ii}(1:F{ii}).^2);
    tf=Y./U; 
    if isempty(vu)|isequal(vu,0), vu=zeros(size(vy)); end
    if isempty(cuy)|isequal(cuy,0), cuy=zeros(size(vy)); end
    SNR2=10*log10(abs((vu.*abs(tf).^2+vy-2*real(cuy.*conj(tf)))./(U.^2)));
    ind2=find(SNR1-SNR2>tfl);
    ind=ind(ind2);
  end
end
%
Str.type='()';
Str.subs={ind};
if ~isempty(ind), Out=subsref(Fdat,Str);
else
  Out=fiddata; 
  set(Out,'inputname',get(Fdat,'inputname'))
  set(Out,'outputname',get(Fdat,'outputname'))
end
%End of @fiddata/goodsnr
