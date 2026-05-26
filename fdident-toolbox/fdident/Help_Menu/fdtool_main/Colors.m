%Help on Fdident GUI: Colors
% 
%    Meaning of colors on the main block diagram:
%
%    - gray means disabled block or empty arrow (a gray block cannot be opened 
%    because of lack of input data or too low UserLevel setting),
%    - blue means an enabled block (it can be opened) which has not yet been 
%    used, or its input and output data do not belong together (the input data 
%    were changed later)
%    - green means that data are already present,
%    - light green arrow means presence of secondary data overshadowed by data 
%    of the other arrow (can be made primary by selection),
%    - dark green marks an arrow with directly loaded data,
%    - cyan is the color of a currently opened block.
%
%    In the graphs with frequency domain data, which open up later, the general 
%    rules are as follows. Every quantity is shown by defaults in dB (except 
%    for phase diagrams (degrees) and explicitly denoted linear-in-amplitude 
%    plots)
%    - green + marks denote the measured data
%    - yellow x marks denote the variances
%    - red line denotes the estimated transfer function
%    - cyan is the color of the residuals (the difference between the measured 
%    data and the estimated transfer function)
% 
% 
%    Other topics are also available, use the Topics menu.