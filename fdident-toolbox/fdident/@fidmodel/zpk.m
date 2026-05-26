function zpkobj=zpk(obj)
%ZPK  Transform fidmodel object to zpk object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 19-Jun-1999

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end
if no>1
  error('Only one output argument is allowed');
end
if strcmp(obj.variable,'w')
  error('Variable w does not allow zpk object representation')
end

%Calculate poles, zeros and k
[domain,pnum,pdenom,delay,fs,Znum,Zdenom]=imppar(obj);
if delay~=0, warning('The delay is not zero. However, it will be neglected.'), end
obj.delay=0;
if strcmp(obj.representation,'orthopol')
  if domain=='p'
    zerov=fdident('private','ortroots',pnum,Znum)*fs;
    polev=fdident('private','ortroots',pdenom,Zdenom)*fs;
    freqv=obj.freqvect;
    tfval=fdident('private','orthpval',pnum,Znum,freqv/fs)./...
      fdident('private','orthpval',pdenom,Zdenom,freqv/fs);
  else %q
    zerov=fdident('private','ortroots',pnum,Znum);
    polev=fdident('private','ortroots',pdenom,Zdenom);
    freqv=obj.freqvect;
    tfval=fdident('private','orthpval',pnum,Znum,freqv/fs,[],'q')./...
      fdident('private','orthpval',pdenom,Zdenom,freqv/fs,[],'q');
  end
else %polynomial
  if isnumeric(pnum), zerov=roots(obj.num);
  else
    zerov=pnum;
    for ii=1:prod(size(pnum))
      zerov{ii}=roots(obj.num{ii});
    end
  end
  polev=roots(obj.denom);
  ln=length(obj.num); ld=length(obj.denom);
  if strcmp(obj.variable,'z^-1')
    if ln<ld, zerov=[zerov;0*ones(ld-ln,1)];
    elseif ld<ln, polev=[polev;0*ones(ln-ld,1)];
    end
  end
  freqv=obj.freqvect;
  if isempty(freqv)
    if strcmp(obj.variable,'z^-1')
      freqv=[1:(ln+ld)*2]/((ln+ld)*2)*fs/2.2;
    else
      if isnumeric(zerov), zerovall=zerov;
      else zerovall=cat(1,zerov{:});
      end
      mzp=max(abs([zerovall;polev;eps]))/2/pi;
      freqv=[1:(ln+ld)*2]/(ln+ld)/2*mzp;
    end
  end
  if isnumeric(zerov), tfval=tfcalc(obj,freqv);
  else tfval=zerov;
    for ii1=1:size(zerov,1)
      for ii2=1:size(zerov,2)
        Struct.type='()'; Struct.subs={ii1,ii2}; 
        objii=subsref(obj,Struct);
        tfval{ii1,ii2}=tfcalc(objii,freqv);
      end
    end
  end
end
if isnumeric(tfval), tfval={tfval}; zerov={zerov}; k=[]; else k=zeros(size(tfval)); end
for ii=1:prod(size(tfval))
  mtfval=median(abs(tfval{ii}));
  [dummy,ind]=min(abs(mtfval-abs(tfval{ii}))); ind=ind(1);
  freq=freqv(ind); tff=tfval{ii}(ind);
  if strcmp(obj.variable,'s'), var=j*2*pi*freq;
  elseif strcmp(obj.variable,'z^-1')
    var=exp(j*2*pi*freq/fs);
    %if length(zerov{ii})<length(polev), zerov{ii}=[zerov{ii};zeros(length(polev)-length(zerov{ii}),1)];
    %elseif length(zerov{ii})>length(polev), polev=[polev;zeros(length(zerov{ii})-length(polev),1)];
    %end
  else error(['unknown variable ''',obj.variable,''''])
  end
  zprod=prod(var-zerov{ii}); if isempty(zprod), zprod=1; end
  pprod=prod(var-polev); if isempty(pprod), pprod=1; end
  tfpz=zprod/pprod;
  k(ii)=real(tff/tfpz);
end
if iscell(zerov)&(length(zerov)>1)
  polevsave=polev; polev=cell(size(zerov));
  for ii=1:prod(size(polev)), polev{ii}=polevsave; end
end

%if exist('@zpk/zpk.m'), zpkobj=zpk; end %Empty object
%zpkobj.z={zerov}; zpkobj.p={polev}; zpkobj.k=k;

if exist('@zpk/zpk.m')
  if strcmp(obj.variable,'z^-1')
    zpkobj=zpk(zerov,polev,k,1/obj.fs);
  else
    zpkobj=zpk(zerov,polev,k);
  end
else %generate structure
  zpkobj.z={zerov}; zpkobj.p={polev}; zpkobj.k=k;
  zkpobj.class='zpk'; %desired class
end
% end ../@fidmodel/zpk.m
