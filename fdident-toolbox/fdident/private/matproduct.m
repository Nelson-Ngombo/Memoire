function p=matproduct(varargin)
%PRODUCT Bypass to avoid svd error in Matlab 7.0.4
p=varargin{nargin};
for ii=nargin-1:-1:1
  p=varargin{ii}*p;
end