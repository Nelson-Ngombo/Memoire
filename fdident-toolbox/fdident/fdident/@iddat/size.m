function [siz1,siz2,siz3,siz4]=size(Fdat,dim)
%SIZE  Give back [samples,outputchannels,inputchannels,experiments] as size
%
%       DIM specifies the dimension which is given back.
%
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 17-Apr-2005

%SIZE  Give back [channels,experiments,freqpoints] as size

if isa(Fdat,'fiddata'), N=get(Fdat,'freqn');
elseif isa(Fdat,'tiddata'), N=get(Fdat,'samplen');
elseif isa(Fdat,'iddat')
  data=Fdat.Data;
  if isnumeric(data), N=length(data);
  else
    N=length(data{1});
    for ii=1:length(data), if N~=length(data{ii}), N=NaN; break, end, end
  end
end
if ~isnumeric(N)|(length(N)~=1), N=NaN; end
chno=get(Fdat,'outputchnumber'); if isempty(chno), chno=0; end
chni=get(Fdat,'inputchnumber'); if isempty(chni), chni=0; end
expno=get(Fdat,'expnumber'); if isempty(expno), expno=0; end
siz=[N,chno,chni,expno];
if nargin>1
  siz1=siz(dim);
else
  if nargout>0, siz1=siz;
  else fprintf(['Data set with %.0f output and %.0f input.\n',...
      'The number of data points is %.0f, experiments: %.0f\n'],...
      siz(2),siz(3),siz(1),siz(4))
  end
end
if nargout>=2, siz1=siz(1); siz2=siz(2); end
if nargout>=3, siz3=siz(3); sizz4=siz(4); end
%End of @iddat/size