function infostr=varinfo(data,mod)
%VARINFO Textual information about variance contents of object
%
%       mod: 'nonlin' or anything else for linear 

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Jun-2002

if nargin<2, mod=''; end
if strncmp(mod,'nonlin',6), linear=0; else linear=1; end
if isa(data,'fiddata')
  if size(data,1)>2, infostr=''; return, end
  if linear
    var=data.SiSoVariance;
    if iscell(var), var=cat(1,var{:}); end
    if size(var,2)==3, cuy=var(:,3); var=var(:,1:end); else cuy=[]; end
  else
    var=sisononlinerror(data);  
    if iscell(var), var=cat(1,var{:}); end
    if size(var,2)==3, cuy=var(:,3); var=var(:,1:end); else cuy=[]; end
  end
  infostr='';
elseif isa(data,'tiddata')
   infostr=''; return
end
if ~isempty(var)
if ~linear, infostr=[infostr,'Nonlin: ']; else infostr=[infostr,'Var: ']; end
if size(var,2)>=2
    if all(var(:,1)==0), vutxt='vu=0'; else vutxt='vu'; end
    if all(var(:,2)==0), vytxt='vy=0'; else vytxt='vy'; end
    infostr=[infostr,vutxt,', ',vytxt];
  else
    if all(var(:,1)==0), vytxt='vy=0'; else vytxt='vy'; end
    infostr=[infostr,'vu=[], ',vytxt];
  end
  if ~isempty(cuy)
    if all(cuy(:,1)==0), cuytxt='cuy=0'; else cuytxt='cuy'; end
    infostr=[infostr,', ',cuytxt];
  else infostr=[infostr,', cuy=[]'];
  end
  if linear, M=get(data,'M'); else M=get(data,'nonlinM'); end
  if ~isempty(M), infostr=[infostr,sprintf(', M = %.0f',M)]; end
elseif ~isempty(data.coherence)
  infostr=[infostr,sprintf('Coherence in [%.2f,%.2f]',...
      min(data.coherence),max(data.coherence))];
else %empty var, empty coherence
  infostr=[infostr,'No variance given'];
end

%%%%%%%%%%%%%%%%%%%%%%%% end of varinfo %%%%%%%%%%%%%%%%%%%%%%%%