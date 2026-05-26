function makehist(varargin);
% MAKEHIST generates history for FDID GUI
% Private function of the FDID Toolbox

% function makehist(varargin)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 23-Jan-2002, GYS

if guiinfos('isrecorderrecord');
    Cmd=varargin{2};
    if ~isstr(Cmd), Cmd=''; end % 
    if ~isempty(findstr('click_on', Cmd))|  ...
            ~isempty(findstr('ui_', Cmd))   | ~isempty(findstr('uic_', Cmd))
        if strcmp(varargin{1}, 'fdtool_command_execution_finished') 
            guirecrd('command_execution_finished'); % notify recorder that the execution has ended
            % used for determining the error status of the command
        else
            [FcnName, hCurObj, hWin, SelType, XParam]=extrtcal(varargin{:});
            CurObj=get(hCurObj, 'tag'); WinName=get(hWin, 'tag');
%             histstruct=struct('Cmd', Cmd, 'Fcn', FcnName, 'Win', WinName, ...
%                 'CurObj', CurObj, 'SelType', SelType, 'XParam', XParam);
            histstruct=struct('Cmd', Cmd, 'Fcn', FcnName, 'Win', WinName, ...
                'CurObj', CurObj, 'SelType', SelType);
            histstruct.XParam=XParam;                         % modified by Zoltan (multiple selection of listbox) 13/11/2004
            guirecrd('addhist', histstruct);
%             for ihist=1:length(histstruct)                  % modified by Zoltan (multiple selection of listbox) 13/11/2004
%                 guirecrd('addhist', histstruct(ihist));
%             end

        end
    end
end 