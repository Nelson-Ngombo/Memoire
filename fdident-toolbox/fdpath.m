function fdpath(arg)
    %FDPATH adds the necessary directories to the MATLAB search path for the fdident-toolbox to work.
    %   It can also remove these directories from the MATLAB search path if supplied with the 'remove' argument.
    if nargin>0 && strcmp(arg,'remove')
        rmpath('fdident','fddemos','fdtest','fdidguid','fdident/Help_Menu')
    else
        if exist('fdident.m')==2 %if fdident.m exists in the path and is a file (2) then we exit
            error('fdident is already in the path, please remove all of its directories from the path first');
            %it does not check for other directories in the path though, so it's not 100% foolproof
        end
        addpath('fdident','fddemos', 'fdtest'); %add these directories to the path always
        addpath fdident/Help_Menu
        addpath(genpath('fdident/Help_Menu'))
        if exist('fdidguid','dir')
            addpath('fdidguid'); %this is if you use the toolbox for development locally
            warning('You are in the development environment')
        end
    end
end
