%Help on Export/Import Data: Preparing time domain object
% 
%    Here an example is given how to prepare a proper tiddata object for 
%    importing into the GUI, if the "Compose" window is not used.
%    Let us assume that we have measured 4096 time domain samples, which are 
%    stored in the vectors 'inp' and 'outp'. The sampling frequency is fs = 
%    40960 Hz, the period length in each signal is Tp = 1/80 s (there are 8 
%    periods). The frequency content is fv = [1:2:15]/Tp.
% 
%    %Make the object:
%    obj = tiddata(outp,inp,1/40960);
%    %Set some properties:
%    obj.periodlength = 1/80;
%    obj.frequencies = [1:2:15]/80;
%    get(obj) %check properties
% 
%    Now the variable obj can be imported to the block "Read Time Domain 
%    Data".
% 
%    Other topics are also available, use the Topics menu.