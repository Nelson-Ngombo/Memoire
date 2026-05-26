function [props,values] = idpvpget(data)
%IDPVPGET   Return the list of properties and their admissible values  
%       for the object class of data.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 19-Jun-1999

if nargin<1, data='fidmodel'; end
%
%All fidmodel Properties
propstr=idpvpstr(data);
indg=findstr(propstr,'|Consistency|');
ind=find(propstr(1:indg+1)=='|');
props=cell(2,1);
for ii=1:length(ind)-1
  props{ii}=propstr(ind(ii)+1:ind(ii+1)-1);
end
%
% Also return values if needed
if nargout>1,
  [propstr,values]=idpvpstr(data);
  if size(props,1)~=size(values,1)
    error('Inconsistency between properties and values')
  end
end
% end @fidmodel/idpvpget.m
