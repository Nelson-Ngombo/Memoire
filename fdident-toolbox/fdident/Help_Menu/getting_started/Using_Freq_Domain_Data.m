%Help on Getting Started...: Using Freq. Domain Data
%   
%   Example: open "Read Freq. Domain Data", "Get data", and import data with 
%   the choices "From File", "Browse demos". Then you can select data from 
%   supported files. A good choice is "bandpass.mat", variable 
%   "bandpass_synch". After viewing the plot, Close the Read Frequency Domain 
%   Data window. If you left "UserLevel" at "Automatic" in the menu of the 
%   main window, this will launch automatic execution until opening the 
%   "Estimate Plant Model" window. Otherwise, open "Variance and/or 
%   Averaging". This will automatically preprocess your data, and after 
%   closing it, you can make estimation in the block "Estimate Plant Model". 
%   The best order selection for the bandpass data is 4/6 in s-domain, but 
%   other choices may also work well. The results can be studied in the last 
%   window, "Evaluate or Compare Plant Models".
%   
%   If you have your data at vectors/arrays in the workspace, use the 
%   "Compose" button: this allows to automatically assemble your data object 
%   from common Matlab variables in the workspace. If you have your data in 
%   files, load them first into the workspace, and then execute "Compose". FRF 
%   data can also be processed in the "Compose" window, or some more hints can 
%   be read on the WEB, at 
%   http://elecwww.vub.ac.be/fdident/frf-data.html
%   
%   A last possibility is to make your fiddata object in the command window, 
%   using the functions 'fiddata'.
%   
%   Other topics are also available, use the Topics menu.