function freqi = allfpi(obj,ch1,ch2)
%ALLFPI Indices to allfreq to select frequencies of 1 or 2 given channels
%
%       Example: allfpi(obj,1,4);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Sep-1998

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end

fi=obj.FreqIndices;
if isempty(fi), freqi=[]; return, end
if ~iscell(fi), freqi=fi; return, end
if ni<3, ch2=[]; end
if ni<2, ch1=[]; end
freqi=fi([ch1;ch2],:);
if isempty(freqi), return, end
if size(freqi,1)==1, freqi=freqi{1};
elseif size(freqi,1)==2
  freqisave=freqi; freqi=freqi(1,:);
  for ii=1:size(freqi,2)
    freqi{ii}=sort([freqisave{1,ii};freqisave{2,ii}]);
    ind=find(~diff(freqi{ii}));
    if ~isempty(ind), freqi{ii}(ind)=[]; end
  end
else
  error('Length of freqi is wrong')
end
%
%end of @fiddata/allfpi