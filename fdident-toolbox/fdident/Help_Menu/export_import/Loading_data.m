%Help on Export/Import Data: Loading data
% 
%    Data can be directly loaded (imported) or assembled from vectors/files in 
%    the two "Read ... Data" blocks. 
% 
%    When the data are available as workspace variables or ASCII files or 
%    variables in MAT-files, the "Compose" command allows to assemble them. The 
%    fields of the Compose window can be filled in with valid MATLAB commands, 
%    like variables, subscripted variables like data(:,2), or special file 
%    references (use "Browse" at the appropriate places). When assembling the 
%    objects, the function checks the data if they are consistent indeed, and 
%    give warnings if they are not.
% 
%    The "Import" procedure checks the type of the data: they must be 
%    'tiddata' or 'fiddata' objects, or maybe 'iddata' objects (see 
%    System Identification Toolbox, V5.x or later). The first two types of 
%    objects can be created by the functions "tiddata" and "fiddata" from your 
%    own vectors - see "Help / Getting Started... / Using Time Domain Data", or 
%    "Help / Getting Started... / Using Freq. Domain Data", and the corresponding 
%    function helps for details. The objects allow the use of the 'get' and 
%    'set' functions: e.g. get(dat).
% 
%    In time domain, automatic determination of the period length, the 
%    excitation frequencies, and the Fourier coefficients is provided. However, 
%    if you can set the first two or at least the second one properly, this can 
%    improve speed and calculation accuracy. So, if you can, do not forget to 
%    fill in the "Frequencies" and/or the "PeriodLength" property, e.g. 
% 
%         data.periodlength = 0.03;
% 
%    and/or
%
%         data.frequencies = 1e3*[1:2:19];
% 
%    If  the data of more than one experiments are used, and measurements are 
%    properly synchronized, set also the property "synchronization", e.g. 
% 
%         data.synchronization='on';
%
%    otherwise unnecessarily long processing time may be wasted later, during 
%    the execution of the "Variance Analysis" block.
% 
%    Saving/loading intermediate data can be done by double-clicking on the 
%    appropriate arrow, and selecting "Save arrow data" or "Load arrow data". 
%    The whole session can also be saved for later use by the File/Save/Session 
%    menu of the main window.
% 
%    Other topics are also available, use the Topics menu.