% Select model parameters and make a fit
% 
% The main identification tool. The basic choices, like domain, 
% numerator/denominator orders, fixed or variable delay, etc. can be 
% selected, and the iteration can be performed. 
% 
% Meaning of the color of the block:
% 
% - gray means disabled block (it cannot be opened because input data are missing),
% - blue means an enabled block (it can be opened by double-click or right 
%   button click) which is not yet used, or the input and output data do not 
%   belong together (the input data were changed later)
% - green means that data are already present in the block, the block may be reopened
% - cyan is the color of the block if it is currently opened.
% 
% The block returns output data after the Close command. In this case its 
% color becomes green. The Cancel command closes it without affecting either 
% its output or its previous setting.