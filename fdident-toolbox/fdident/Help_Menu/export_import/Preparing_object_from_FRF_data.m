%Help on Export/Import Data:  Preparing object from FRF data
% 
%    FRF data can be best processed in the "Compose" window, or some more hints 
%    can be read on the WEB, at 
%    http://elecwww.vub.ac.be/fdident/frf-data.html
%    Here is an example how to prepare a proper fiddata object for loading into 
%    the GUI, if the "Compose" window is not used.
% 
%    Let us assume that we have measured gain and phase data at frequency 
%    points [100 Hz - 40 kHz], at 50 Hz steps. The gain data are in dB, the 
%    phase data are in degrees.
% 
%    The frequency vector is
% 
%         freqv = [100/50:40e3/50]'*50; %assure proper number of points
% 
%    Now size(freqv), size(gain) and size(phase) should be in general the same, 
%    all column vectors.
% 
%         FRF = 10.^(gain/20).*exp(j*phase/360*2*pi);
%         obj = fiddata(FRF,ones(size(FRF)),freqv);
% 
%    It is also possible for multiple experiments that that 'gain' and 
%    'phase' are cell row vectors with equal-sized column vectors as 
%    elements.
% 
%    Now the variable obj can be imported into the block "Read Frequency Domain 
%    Data".
% 
%    Other topics are also available, use the Topics menu.