function [orderstr, pieces] = fdmodord(model, mode)
% function orderstr=fdmodord(model, mode)
% 
% Returns the order(s) of model(s) of input 'model' in string format (e.g. '3/6').
% Input can be an array or cell array of fdmodels as well, the output in this 
% case is a cell array of strings.
% Parameter 'mode' is optional, if given and its value is 'distinguish' then 
% the same orders are marked: (eg. {'6/6 (1)', '6/3', '6/6 (2)'})

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 14-July-1998, GYS

if length(model)>1  % array or cell of fidmodels
   N=length(model);
   if isa(model,'fidmodel')
     for ix=1:N
       orderstr{ix}=order(model(:,:,ix));
     end
   else %cell
     for ix=1:N
       orderstr{ix}=order(model{ix});
     end
   end
   pieces = multiples(orderstr);
   if nargin > 1 & strcmp(mode, 'distinguish')
      [sorted_orders sorte_ix]=sort(orderstr);
      d=[strcmp(sorted_orders(1:end-1), sorted_orders(2:end)) ];
      d(length(d)+1)=0;
      Xix=0;
      for ix=1:N
         if d(ix)
            Xix=Xix+1;
            orderstr{sorte_ix(ix)}=[orderstr{sorte_ix(ix)} ' (' num2str(Xix) ')'];
         else
            if Xix~=0
               orderstr{sorte_ix(ix)}=[orderstr{sorte_ix(ix)} ' (' num2str(Xix+1) ')'];
               Xix=0;
            end
         end
      end
   end
else
   orderstr=order(model);
   pieces = 1;
end


function ordstr=order(model)
if iscell(model)
  if length(model)>1, error('Cannot calculate order string for multi-models'), end
  model=model{1};
end
no=length(model.num)-1; do=length(model.denom)-1;
if no>=0, nostr=num2str(no); else nostr='[ ]'; end
if do>=0, dostr=num2str(do); else dostr='[ ]'; end
ordstr=[nostr '/' dostr];

%
