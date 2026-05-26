function [avdat,freqindices]=interpvar(Fdat)
%INTERPVAR  Object with interpolating errors
%
%       avdat=interpvar(Fdat)
%
%       See also VARANAL, @FIDDATA/NONLINVAR

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 06-Apr-2005

%if ~israndomized(Fdat)
%  error('Not randomized data')
%  avdat=[]; return
%end
expno=get(Fdat,'expnumber');
for ei=1:expno
  if expno>1
    Struct=[]; Struct.type='{}'; Struct.subs={':',ei};
    obji=subsref(Fdat,Struct);
  else
    obji=Fdat;
  end
  avdati=obji;
  df=dfcalc(obji);
  %
  freqvall=get(avdati,'freqpoints');
  fvexc=get(avdati,'frequencies');
  if ~isempty(fvexc)&(length(fvexc)<length(freqvall))
    %eliminate zero excitation lines
    frind=round(fvexc/df*1e4);
    fvind=round(freqvall/df*1e4);
    ind=find(ismember(fvind,frind));
    Struct=[]; Struct.type='()'; Struct.subs={ind};
    %avdati=avdati(ind);
    avdati=subsref(avdati,Struct,'noconsistency');
    %
    freqallind=round(freqvall/df); fvexcind=round(fvexc/df);
    fevenpoint=find(rem(freqallind,2)==0);
    fexcpoint=find(ismember(freqallind,fvexcind));
    %foddind=find((rem(freqallind,2)==1)&~ismember(freqallind,fvexcind));
    fnonexcpoint=find(~ismember(freqallind,fvexcind)&...
      (freqallind<=max(fvexcind)+2)&...
      (freqallind>=min(fvexcind)-2));
    fvnonexc=freqvall(fnonexcpoint);
    fnonexcoddpoint=find(~ismember(freqallind,fvexcind)&...
      (rem(freqallind,2)==1)&...
      (freqallind<=max(fvexcind)+2)&...
      (freqallind>=min(fvexcind)-2));
    fnonexcevenpoint=find(~ismember(freqallind,fvexcind)&...
      (rem(freqallind,2)==0)&...
      (freqallind<=max(fvexcind)+2)&...
      (freqallind>=min(fvexcind)-2));
    %
    oddintononnexcpoint=find(rem(freqallind(fnonexcpoint),2)==1);
    evenintononnexcpoint=find(rem(freqallind(fnonexcpoint),2)==0);
    %
    y=get(obji,'output'); u=get(obji,'input');
    tfexc=y(fexcpoint)./u(fexcpoint);
    tf2=[tfexc(1);tfexc;tfexc(end)]; fv2=[0;fvexc;2*max(freqvall)];
    tfnonexc=interp1(fv2,abs(tf2),fvnonexc).*...
      exp(j*2*pi*interp1(fv2,unwrap(angle(tf2)),fvnonexc));
    %
    uexc=u(fexcpoint);
    u2=[uexc(1);uexc;uexc(end)]; fv2=[0;fvexc;2*max(freqvall)];
    unonexc=interp1(fv2,abs(u2),fvnonexc).*...
      exp(j*2*pi*interp1(fv2,unwrap(angle(u2)),fvnonexc));
    ynonexc=tfnonexc.*unonexc;
    %vy=get(obji,'outputvariance'); vu=get(obji,'inputvariance'); cuy=get(obji,'covvect');
    sisovar=get(obji,'sisovariance'); if size(sisovar,2)==2, sisovar=[sisovar,0]; end
    if size(sisovar,1)==1, sisovar=sisovar(ones(get(obji,'Freqnumber'),1),:); end
    avdatne=fiddata(ynonexc,unonexc,fvnonexc,sisovar(fnonexcpoint,1),...
      sisovar(fnonexcpoint,2),...
      sisovar(fnonexcpoint,3));
    %var=vy(fnonexcpoint)+vu(fnonexcpoint).*abs(tfnonexc).^2-2*real(cuy(fnonexcpoint).*conj(tfnonexc));
    yerr=abs(y(fnonexcpoint)-tfnonexc.*u(fnonexcpoint)).^2;
    set(avdati,'oddnonexcfreq',freqvall(fnonexcoddpoint),...
      'oddoutputnonlinerror',yerr(oddintononnexcpoint),...
      'evennonexcfreq',freqvall(fnonexcevenpoint),...
      'evenoutputnonlinerror',yerr(evenintononnexcpoint),...
      'userdata',avdatne);
    %
    if ei==1, avdat=avdati;
    else avdat=merge(avdat,avdati);
    end
  end
end %for ei
if exist('avdat'), set(avdat,'nonlinM',2); else error('Cannot process the given data'), end
%
freqindices.fexcind=fvexcind;
freqindices.fnonexcind=freqallind(fnonexcpoint);
freqindices.fnonexcoddind=freqallind(fnonexcoddpoint);
freqindices.fnonexcevenind=freqallind(fnonexcevenpoint);
%
%End of interpvar