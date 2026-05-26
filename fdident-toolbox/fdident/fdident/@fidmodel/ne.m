function out=ne(model1,model2)
%Ne Realize operation ~=

if nargin<2, error('Not enough input arguments'), end
out=~eq(model1,model2);
%
%End of @fidmodel/ne