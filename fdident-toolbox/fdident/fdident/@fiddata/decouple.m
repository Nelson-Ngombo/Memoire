function dcobj=decouple(obj)
%DECOUPLE  Decouple fullMIMO experiment groups

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Jan-2004

dcobj=obj;
fullmimo_groups=get(obj,'Groups_FullMIMO');
if isempty(fullmimo_groups)
  if get(obj,'expnumber')<=1
    error('Decouple has no meaning for one experiment')
  end
  if isempty(get(obj,'synchronization'))
    set(obj,'synchronization','fullmimo')
    fullmimo_groups=get(obj,'Groups_FullMIMO');
  else
    warning('Nothing to decouple')
    return
  end
end
if all(issingleexc(obj)), return, end
%
fullmimo_data=strcmp(get(obj,'synchronization'),'mimo'); %If all data belong to group
ichn=get(obj,'inputchnumber');
%
for ii=1:size(fullmimo_groups,1)
  fmexpii=getexpnos(obj,fullmimo_groups(ii,1));
  if fullmimo_data
    obji=obj; 
  else
    Struc.type='{}'; Struc.subs={':',fmexpii};
    obji=subsref(obj,Struc); 
    if all(issingleexc(obji)), break, end
  end 
  gn=fullmimo_groups{ii,2}; if isempty(gn), gn=sprintf('m(%.0f)',ii); end
  if length(fmexpii)<ichn, error(['Not enough experiments in group ''',gn,''''])
  elseif length(fmexpii)>ichn
    warning(['Too many experiments in group ''',gn,''': %.0f instead of %.0f'],length(fmexpii),ichn)
  end
  %fmexpii=fmexpii(1:ichn); %eliminate excess experiments
  %Struct.type='{}'; Struct.subs={':',fmexpii};
  %objiii=subsref(obji,Struct);
  U=get(obji,'InputData'); if ~iscell(U), U={U}; end
  Y=get(obji,'OutputData'); if ~iscell(Y), Y={Y}; end
  Ref=get(obji,'Reference'); if ~iscell(Ref), Ref={Ref}; end
  Um=U; Ym=Y; Refm=Ref;
  fp=get(obji,'InputfreqPoints'); if ~iscell(fp), fp={fp}; end
  for fi=1:length(fp{1})
    Uc=zeros(size(U)); Yc=zeros(size(Y)); Rc=zeros(size(Ref));
    for ih=1:size(U,2)
      for iv=1:size(U,1)
        Uc(iv,ih)=U{iv,ih}(fi);
        Rc(iv,ih)=Ref{iv,ih}(fi);
      end %iv
      for iv=1:size(Y,1)
        Yc(iv,ih)=Y{iv,ih}(fi);
      end %iv
    end %ih
    %H*Uc=Yc  H is Ny x Nu cell array of FRF's
    %H=[H11 H12
    %   H21 H22], H12 is the frf between output1 and input2
    Ycm=(Yc/Rc);
    Ucm=(Uc/Rc);
    Rcm=Rc/Rc;
    for ih=1:size(U,2)
      for iv=1:size(U,1)
        Um{iv,ih}(fi)=Ucm(iv,ih);
        Refm{iv,ih}(fi)=Rcm(iv,ih);
      end %iv
    end %ih
    for iv=1:size(Y,1)
      Ym{iv,ih}(fi)=Ycm(iv,ih);
    end %iv    
  end %for fi
  set(obji,'InputData',Um,'OutputData',Ym,'Reference',Refm);
  %
  if fullmimo_data
    dcobj=obji;
  else
    Struc.type='{}'; Struc.subs={':',fmexpii};
    dcobj=subsasgn(dcobj,Struc,obji); 
  end 
end %for ii
%
%End of decouple