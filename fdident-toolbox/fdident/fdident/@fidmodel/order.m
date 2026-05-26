function ord=order(model)
%ORDER  Orders fidmodel object
%
%       The output is a string, like '5/6', or cell array of strings

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Sep-2002

sm=size(model);
if all(sm(1:2)==1) %SISO
  so=sm(3:end);
  if length(so)==1, ord=cell(so,1);
	else ord=cell(so(1),so(2));
	end
  for ii=1:prod(sm)
    if ii==1, ms=struct(model); end
    ord{ii}=sprintf('%.0f/%.0f',length(ms(ii).num)-1,length(ms(ii).denom)-1);
  end
else %MIMO
  error('Order is not yet ready for MIMO')
end
if length(ord)==1, ord=ord{1}; end
% end ../@fidmodel/order.m
