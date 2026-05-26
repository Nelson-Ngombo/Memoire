function fdidpaus(mode,ypos,tim)
%FDIDPAUS Utility to stop in demontrations to show messages in Command Window
%
%       Input argument:
%       mode = 'y' or empty: stop with message in command window
%              'n': don't stop
%              'p': allow switch to command window by pressing a key
%       ypos = vertical position of text
%       tim  = time to wait in seconds
%
%       Usage: fdidpaus(mode,ypos,tim)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Sep-1997

if nargin<1, error('no input argument'), end
if nargin<2, ypos=[]; end, if isempty(ypos), ypos=0; end
if nargin<3, tim=[]; end, if isempty(tim), tim=10; end
%
if ~strcmp(mode,'n')
  if strcmp(mode,'y')|isempty(mode)
    fprintf('Press any key to continue ...'), pause, disp(' ')
  else %'p'
    txth1=axes('Position',[0,0,1,.1]); axis off
    th=text(1,10*ypos,'Press a key for text ...','VerticalAlignment','bottom',...
             'Horizontalalignment','right');
    drawnow
    %
    %Detect texts on each other
    ht=findobj(gcf,'type','text');
    %ht=[]; %don't do anything
    for iht=1:length(ht)
      string=get(ht(iht),'string');
      pointer=findstr(string,'Press a');
      if ~isempty(pointer)
        if isempty(findstr(string,'Press a key for text'))
          disp(['Overlaying text: ',string])
        end
      end
    end
    %
    %global KeyPressFcnVal
    KeyPressFcnVal=0;
    %set(gcf,'KeyPressFcn','global KeyPressFcnVal, KeyPressFcnVal=1;')
    cl0=clock;
    while (KeyPressFcnVal==0) & (etime(clock,cl0)<tim)
      %continue if key has been pressed, or tim (10) seconds are gone
      cl1=clock;
      while etime(clock,cl1)<1, end
    end
    delete(txth1)
    fprintf('Press any key to continue ...'), pause, disp(' ')
  end
end
%
% End of fdidpaus
