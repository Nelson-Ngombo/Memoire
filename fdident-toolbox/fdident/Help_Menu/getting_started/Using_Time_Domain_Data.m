%Help on Getting Started...: Using Time Domain Data
%
%    Example: open "Read Time Domain Data", and import data with the choices 
%    "Get Data", "From File", "Browse demos", "robotarm.mat", variable 
%    "robotarm_rawdata". If you have left "UserLevel" set to "Automatic" in the 
%    menu of the main window, this block will now automatically preprocess the 
%    data. If "UserLevel" is set to "Interactive" or higher, you may experiment 
%    with the settings at each step.
%
%    If you have your data at vectors/arrays in the workspace, use the 
%    "Compose" button: this allows to automatically assemble your data object 
%    from common Matlab variables in the workspace. If you have your data in 
%    files, load them first into the workspace, and then execute "Compose".
%
%    When you generate your own data in the command window with the function 
%    'tiddata', keep in mind how you want to process the data. You must have 
%    either at least 3 experiments, or at least 3 segments from one experiment. 
%    Either automatic preprocessings needs to be used, or proper manual 
%    segmentation can only be done if the period length of the data is known. 
%    Therefore, fill in one of the tiddata properties "PeriodLength" or 
%    "Frequencies", e.g.
%
%         data.periodlength = 0.03;
%
%    and/or
% 
%         data.frequencies = 1e3*[1:2:19];
% 
%    If you have more than on experiment, it is important to tell if the 
%    experiments were synchronized (proper triggering was used always at the 
%    same phase of the excitation signal), otherwise lengthy tests follow. 
%    E.g.
%
%         data.synchronization='on';
% 
%    Other topics are also available, use the Topics menu.