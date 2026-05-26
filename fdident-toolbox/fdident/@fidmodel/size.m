function [ny,varargout] = size(model,x) 
%SIZE  Size and order of fidmodel objects.
%
%   D = SIZE(MODEL) returns
%      * the two-entry row vector D = [NY NU] for a single fidmodel 
%        object with NY outputs and NU inputs
%      * the row vector D = [NY NU S1 S2 ... Sp] for a S1-by-...-by-Sp 
%        array of models with NY outputs and NU inputs.
%   SIZE(MODEL) by itself makes a nice display.
%
%   [NY,NU,S1,...,Sp] = SIZE(MODEL) returns
%      * the number of outputs NY
%      * the number of inputs NU 
%      * the model array sizes S1,...,Sp (for arrays of models)
%   in separate output arguments.  Alternatively,
%      NY = SIZE(MODEL,1)   returns just the number of outputs.
%      NU = SIZE(MODEL,2)   returns just the number of inputs.
%      Sk = SIZE(MODEL,2+k) returns the length of the k-th fidmodel array 
%                         dimension.
%
%   NS = SIZE(MODEL,'order') returns the model order.
%   For model arrays, NS is scalar when all
%   models have the same order, and is an array listing the order of
%   each model otherwise.
%
%   See also @TF/SIZE, NDIMS, ISEMPTY, ISSISO.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Aug-1999

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,2,ni)), %earlier
end

if length(model)==0
  mn=[]; 
  sm=[0,0];
elseif length(model)==1
  mn=model.num;
  sm=[1,1];
else
  ms=struct(model);
  mn=ms(1).num;
  sm=size(ms);
end
if isnumeric(mn), sizes=[1,1];
else sizes = size(mn);
end
if sm(end)==1, sm(end)=[]; end
sizes=[sizes,sm];
sizes = [sizes , ones(1,length(sizes)==3)];
nd = length(sizes);

if ni==1,
  if no==0,
    % Display only for SIZE(MODEL) 
    s = 's';
    nyint = sizes(1);
    nuint = sizes(2);
    if all(sizes(3:end)==1),
      disp(sprintf('Transfer function with %d output%s and %d input%s.',...
        nyint,s(1,nyint>1),nuint,s(1,nuint>1)));
    else
      ArrayDims = sprintf('%dx',sizes(3:end));
      disp(sprintf('%s array of transfer functions',ArrayDims(1:end-1)))
      disp(sprintf('Each model has %d output%s and %d input%s.',...
        nyint,s(1,nyint>1),nuint,s(1,nuint>1)));
    end
  elseif no==1,
    % S = SIZE(MODEL)
    ny = sizes;
  else
    % [S1,..,SK] = SIZE(MODEL)
    s = [sizes(1:2) sizes(3:min(nd,no-1)) prod(sizes(no:nd)) ones(1,no-nd)];
    ny = s(1);
    varargout = num2cell(s(2:no)); 
  end
  
else
  % SIZE(MODEL,'ORDER') or SK = SIZE(MODEL,K)
  if ~ischar(x),
    if x<=0,
      error('Second argument must be a non negative integer.')
    end
    x = round(x);
    sizes = [sizes ones(1,x-nd)];
    ny = sizes(x);
  elseif strcmp(lower(x(1:min(1,end))),'o')   
    if strncmp(version,'5.2',3)
      error('size(m,''order'') does not work yet in Matlab 5.2. Sorry for the inconveinience.')
    end
    if length(model)==1
      [ro,co] = tforder(model.num,model.denom);
    else
      ms=struct(model);
      sm=size(ms); num=cell(sm); denom=cell(sm);
      for ii=1:prod(sm)
        num{ii}=ms(ii).num; denom{ii}=ms(ii).denom;
      end
      [ro,co] = tforder(num,denom);
    end
    ny = min(ro,co);   
    if length(ny) & ~any(ny(2:end)-ny(1:end-1)),
      % Uniform order
      ny = ny(1);
    end
  else
    error('Second input argument must be an integer or the string ''order.''')
  end
end
if (no>0)&(length(ny)==4)&(ny(4)==1), ny(4)=[]; end
%

function [ro,co] = tforder(num,den)
%TFORDER   Computes order of ZPK models
%
%   [RO,CO] = TFORDER(NUM,DEN) compute the row-wise and
%   column-wise orders RO and CO for the TF models 
%   with data NUM,DEN.

if ~iscell(num), num={num}; end
if ~iscell(den), den={den}; end
sizes = size(num);
ro = zeros([sizes(3:end) 1 1]);
co = zeros([sizes(3:end) 1 1]);

% Loop over each model
for m=1:prod(size(ro)),
   % Gain and poles of model #m (discard poles where gain=zero)
   nm = num(:,:,m);
   dm = den(:,:,m);
   if exist('cellfun')
     npoles = cellfun('length',dm)-1;
   else %5.2
     npoles=cell(size(dm));
     for ii=1:length(dm), npoles{ii}=length(dm{ii}); end
   end
   
   % Zero entries contribute no dynamics
   for k=1:prod(sizes(1:2)),
     if strncmp(version,'5.2',3)
       npoles{k} = any(nm{k}) * npoles{k};       
     else
       npoles(k) = any(nm{k}) * npoles(k);
     end
   end
   
   % Determine row-wise order
   rom = 0;
   for i=1:sizes(1),
     if strncmp(version,'5.2',3)
       jdyn = find(npoles{i,:});  % dynamic entries
       if length(jdyn)<2 | ~isequal(dm{i,jdyn}),
         rom = rom + sum(npoles{i,jdyn});
       else
         % Common denominator
         rom = rom + npoles{i,jdyn(1)};
       end
     else
       jdyn = find(npoles(i,:));  % dynamic entries
       if length(jdyn)<2 | ~isequal(dm{i,jdyn}),
         rom = rom + sum(npoles(i,jdyn));
       else
         % Common denominator
         rom = rom + npoles(i,jdyn(1));
       end
     end
   end
   ro(m) = rom;
   
   % Determine column-wise order
   com = 0;
   for j=1:sizes(2),
     if strncmp(version,'5.2',3)
       idyn = find(npoles{:,j});   % dynamic entries
       if length(idyn)<2 | ~isequal(dm{idyn,j})
         com = com + sum(npoles{idyn,j});
       else        
         % Common denominator
         com = com + npoles{idyn(1),j};
       end
     else
       idyn = find(npoles(:,j));   % dynamic entries
       if length(idyn)<2 | ~isequal(dm{idyn,j})
         com = com + sum(npoles(idyn,j));
       else        
         % Common denominator
         com = com + npoles(idyn(1),j);
       end
     end
   end
   co(m) = com;
end
