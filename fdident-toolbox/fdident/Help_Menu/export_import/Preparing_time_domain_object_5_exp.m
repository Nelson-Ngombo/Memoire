%Help on Export/Import Data:  Preparing time domain object, 5 exp
% 
%    Here an example is given how to prepare a proper tiddata object from 
%    multiple experiments for loading into the GUI, if the "Compose" window is 
%    not used.
%    Assume that we have multiple experiments, and let us assume that we have 
%    measured five times 1024 time domain samples, which are stored in the 1024 
%    x 5 arrays inp and outp. The sampling frequency is fs = 40960 Hz, the 
%    period length in each signal is 1/160 s (there are 4 periods in each 
%    record).
% 
%    %First prepare the data in 1 x 5 cell arrays:
%    u = num2cell(inp,1); y = num2cell(outp,1);
%    %Now make the object:
%    obj = tiddata(y,u,1/40960);
%    %Set some properties:
%    obj.periodlength = 1/160;
%    obj.frequencies = [1:2:25]/160;
%    obj.synchronization='on';
%    get(obj) %check properties
% 
%    Now the variable obj can be imported to the block "Read Time Domain 
%    Data".
% 
%    Other topics are also available, use the Topics menu.