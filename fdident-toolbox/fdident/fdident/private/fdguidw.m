function fdguidw(labelList,nameList,message);
%FDGUIDW Create a window for playing fdident GUI demos.

% labelList contains the descriptive names of the demos
% nameList contains the actual function names of the demos

if nargin<3,
    figureFlagList=ones(size(labelList,1),1);
end

Name='Demos for Fdident GUI';
Tag='fdident_gui_demos';
% Now initialize the whole figure...
figNumber=findall(0,'tag',Tag);
if ishandle(figNumber), delete(figNumber), figNumber=[]; end

if isempty(figNumber)
  figNumber=figure( ...
    'Name',Name, ...
    'IntegerHandle','off', ...
    'NumberTitle','off',...
    'HandleVisibility','off',...
    'MenuBar','none',...
    'tag',Tag);
else
  set(figNumber,'Name',Name,'HandleVisibility','off','tag',Tag);
end

axes('Visible','off','HandleVisibility','callback','parent',figNumber)

    %===================================
    % Set up the Comment Window
    top=0.32;
    top=0.37;
    left=0.05;
    right=0.75;
    bottom=0.05;
    labelHt=0.05;
    spacing=0.005;
    promptStr=message;

    % First, the Comment Window frame
    frmBorder=0.02;
    frmPos=[left-frmBorder bottom-frmBorder ...
        (right-left)+2*frmBorder (top-bottom)+2*frmBorder];
    uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'BackgroundColor',[0.50 0.50 0.50],'parent',figNumber);
    % Then the text label
    labelPos=[left top-labelHt (right-left) labelHt];
    uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',labelPos, ...
        'BackgroundColor',[0.50 0.50 0.50], ...
        'ForegroundColor',[1 1 1], ...
        'String','Comment Window','parent',figNumber);
    % Then the editable text field
    txtPos=[left bottom (right-left) top-bottom-labelHt-spacing];
    txtHndl=uicontrol( ...
        'Style','edit', ...
        'HorizontalAlignment','left', ...
        'Units','normalized', ...
        'Max',10, ...
        'BackgroundColor',[1 1 1], ...
        'Position',txtPos, ...
        'String',promptStr,'parent',figNumber);

%====================================
% Information for all buttons
labelColor=[0.8 0.8 0.8];
yInitPos=0.90;
top=0.95;
bottom=0.05;
left=0.80;
btnWid=0.15;
btnHt=0.10;
%btnHt=0.08;
% Spacing between the button and the next command's label
spacing=0.03;

%====================================
% The CONSOLE frame
frmBorder=0.02;
yPos=0.05-frmBorder;
frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
h=uicontrol( ...
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos, ...
    'BackgroundColor',[0.5 0.5 0.5],'parent',figNumber);

%====================================
% The INFO button
labelStr='Info';
callbackStr=['helpwin ' mfilename];
infoHndl=uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left bottom+btnHt+spacing btnWid btnHt], ...
    'String',labelStr, ...
    'Callback',callbackStr,'parent',figNumber);

%====================================
% The CLOSE button
labelStr='Close';
callbackStr='close(gcbf)';
closeHndl=uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[left bottom btnWid btnHt], ...
    'String',labelStr, ...
    'Callback',callbackStr,'parent',figNumber);

%====================================
% Information for demo buttons
labelColor=[0.8 0.8 0.8];
btnWid=0.34;
btnHt=0.07;
btnHt=0.08;
if size(labelList,1)>12, btnHt=0.06;
elseif size(labelList,1)>10, btnHt=0.07;
end
top=0.95;
bottom=0.35;
right=0.75;
leftCol1=0.05;
leftCol2=right-btnWid;
% Spacing between the buttons
spacing=0.02;
%spacing=(top-bottom-4*btnHt)/3;

numButtons=size(labelList,1);
col1Count=fix(numButtons/2)+rem(numButtons,2);
col2Count=fix(numButtons/2);

% Lay out the buttons in two columns
for count=1:col1Count,
    
    btnNumber=count;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr=deblank(labelList(count,:));
%    callbackStr='eval(get(gco,''UserData''));';
    cmdStr=[nameList(count,:) ';'];

    % Generic button information
    dbtag='fdgui_demobutton';
    if strcmp('autoorder_demo',cmdStr), dbtag=''; end
    btnPos=[leftCol1 yPos-btnHt btnWid btnHt];
    startHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'tag',dbtag,...
        'Callback',cmdStr,'parent',figNumber);

end;

for count=1:col2Count,
    
    btnNumber=count;
    yPos=top-(btnNumber-1)*(btnHt+spacing);
    labelStr=deblank(labelList(count+col1Count,:));
    cmdStr=[nameList(count+col1Count,:) ';'];

    % Generic button information
    dbtag='fdgui_demobutton';
    if isequal(findstr('autoorder_demo',cmdStr),1), dbtag=''; end
    btnPos=[leftCol2 yPos-btnHt btnWid btnHt];
    startHndl=uicontrol( ...
        'Style','pushbutton', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',labelStr, ...
        'tag',dbtag,...
        'Callback',cmdStr,'parent',figNumber);
      %Mark nonlinear demos with red
      if any(findstr('onlinearity',labelStr))
        set(startHndl,'foregroundcolor',[1,0,0])
      end
end;

figure(figNumber) %Bring window to foreground
set(figNumber,'HandleVisibility','off',...
  'Name',Name, ...
  'tag',Tag);
%