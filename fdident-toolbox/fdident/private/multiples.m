function modelc = multiples(models)
%MULTIPLES If there are multiple occurences of models, the function
%          assigns the count to the individual models.

%       Input arguments:
%         models - cell vector of model strings
%
%       Usage: modelc = multiples(models);
%       Example: 
%

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Roman
%       Last modified: 30-Oct-1999, GYR


for i = 1:length(models)
   count = 0;
   for j = 1:length(models)
      if (strcmp(models{i}, models{j}))
         count = count + 1;
      end
   end
   modelc{i} = count;
end

