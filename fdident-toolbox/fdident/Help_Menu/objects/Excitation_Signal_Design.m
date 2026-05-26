% Design excitation signal
%
% Design of different periodic excitation signals. Types of signals: 
% multisine, discrete interval binary signal (DIBS), discrete interval 
% three-level signal (DITS) or pseudo random binary signal (PRBS or MLBS).
% 
% This block is enabled only if "UserLevel" is "Interactive" or higher.
% 
% Meaning of the color of the block:
% 
% - gray means block disabled for some reason (e.g. because UserLevel is "Automatic"),
% - blue means an enabled block (it can be opened by double-click or right 
% button click), the block has not yet been used
% - green means that data are already present in the block, the block may be reopened
% - cyan is the color of the block if it is currently opened.
% 
% The block returns output data after the Close command. In this case its 
% color becomes green. The data are available on the output arrow, either 
% for one of the next blocks (e.g. for simulation), or by double-clicking on 
% the arrow, and selecting "Save Arrow Data". in the resulting object (let 
% us name it 'obj'), the basic data are as follows:
%   get(obj) 