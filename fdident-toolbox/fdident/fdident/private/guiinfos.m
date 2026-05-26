function info=guiinfos(infotype, p2)
% INFOS ON GUI - helper fcn of FDTool
%
% -------        SERVICES      ---------
% 'userlevel' [Automatic|Interactive|Advanced]
% 'modeltype' [Linear|Nonlinear error]
% 'playback'  [0|1] determine playback status at the time of the 
%                 last click on an arrow or a box
%
% 'mother', wintag     mother window
% 'allchild', wintag   all the descendents of a window
% 'children', wintag   children only
% 'masterfcn', wintag  handler fcn (if window is not to be stored, the first character is '*')
%
% 'ishelpmode', winh   [0|1] help status of a window
% 'isdevelopment'      development mode
% 'ismeasurement'      measurement on (true also in development mode)
% 'islinear'           linear model

% 'isrecorderopen'     recorder is open
% 'istestrecordermode' OBSOLETE
% 'isrecorderplayback' recorder is playing back
% 'isrecorderrecord'   recorder is recording

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 22-Nov-2003, IK

% Old: 'userlevel' [Basic|Intermediate|Advanced]

hMainfig=findobj(allchild(0), 'flat', 'tag', 'fdtool_main');

if nargin==1 % global infos
   switch lower(infotype)
   case 'userlevel'
      % returns UserLevel status
      hm=findobj(allchild(hMainfig), 'tag','fdtool_menu_userlevel');
      if strcmp(get(hm,'type'), 'uimenu') %old call
        hChecked=findobj(allchild(hMainfig), 'type', 'uimenu', ...
          'userdata', 'fdtool_menu_userlevel', 'checked', 'on');
        tChecked=get(hChecked, 'Label');
        %info=tChecked(23:end);
        info=tChecked;
        ind=find(info=='&'); if ~isempty(ind), info(ind)=''; end
      elseif strcmp(get(hm,'type'),'uicontrol') %popup call
        val=get(hm,'value');
        str=get(hm,'string');
        info=str{val};
      else %toolbar
        hChecked=findobj(allchild(hMainfig), ...
          'userdata', 'fdtool_menu_userlevel', 'state', 'on');
        if length(hChecked)==1
          if any(findstr(get(hChecked,'tag'),'fdtool_menu_userlevel_simple')), info='Simple';
          elseif any(findstr(get(hChecked,'tag'),'fdtool_menu_userlevel_basic')), info='Automatic';
          elseif any(findstr(get(hChecked,'tag'),'fdtool_menu_userlevel_intermediate')), info='Interactive';
          elseif any(findstr(get(hChecked,'tag'),'fdtool_menu_userlevel_advanced')), info='Advanced';
          end
        else
          error('hChecked is improper')  
        end
      end
    case 'modeltype'
      % returns Model type
      hm=findobj(allchild(hMainfig), 'userdata','fdtool_menu_modeltype');
      hmt=findobj(allchild(hMainfig), 'tag','fdtool_text_modeltype');
      if ~isempty(hm)&strcmp(get(hm(1),'visible'),'on')
        if strcmp(get(hm(1),'type'),'uicontrol')
          val=get(hm,'value');
          str=get(hm,'string');
          info=str{val};
        else %toolbar
          hchecked=findobj(hm,'state','on');
          if any(findstr(get(hchecked,'tag'),'fdtool_menu_modeltype_linear')), info='Linear';
          elseif any(findstr(get(hchecked,'tag'),'fdtool_menu_modeltype_nonlinear_errors')), info='Nonlinear errors';
          else info='Linear';
            %error('info cannot be filled in')
          end
        end
      else
        info='Linear';
      end
    case 'signaltype'
      % returns signal type
      hm=findobj(allchild(hMainfig), 'userdata','fdtool_menu_signaltype');
      hmt=findobj(allchild(hMainfig), 'tag','fdtool_text_signaltype');
      if ~isempty(hm)&strcmp(get(hm(1),'visible'),'on')
        if strcmp(get(hm(1),'type'),'uicontrol')
          val=get(hm,'value');
          str=get(hm,'string');
          info=str{val};
        else %toolbar
          hchecked=findobj(hm,'state','on');
          if any(findstr(get(hchecked,'tag'),'fdtool_menu_signaltype_all')), info='all';
          elseif any(findstr(get(hchecked,'tag'),'fdtool_menu_signaltype_periodic')), info='periodic';
          else 
            error('info cannot be filled in')
          end
        end
      else
        info='all';
      end
    case 'playback'
      error('Obsolate call of guiinfos: ''playback''. Use ''isrecorderplayback'' instead')
      %   info=guidtard('fdtool_main', 'ACTION_INFO');
      %   % The ACTION_INFO uprop contains info on the playback mode at time of the last 
      %   % activation of a box or arrow
      %   if isempty(info), info=0; end
   case 'islinear'
      typestr=guiinfos('ModelType');
      info=strcmp(typestr,'Linear');
   case 'isdevelopment'
      modestr=fdtool('getguimodes');
      info=any(findstr(modestr, 'D'));
   case 'ismeasurement'
      modestr=fdtool('getguimodes');
      info=any(findstr(modestr, 'M'));
   case('isrecorderopen')
     if exist('gui_recorder.m') %new recorder
       info=gui_recorder('isrecorderopen','fdtool');
     else
       info=~isempty(findobj(allchild(0), 'flat', 'tag', 'fdtool_recorder_fig'));
     end
  case 'isrecorderplayback'
     if exist('gui_recorder.m') %new recorder
       info=gui_recorder('isrecorderplayback','fdtool');
     else
       hRecFig=findobj(allchild(0), 'flat', 'tag', 'fdtool_recorder_fig');
       hplay=findobj(allchild(hRecFig), 'flat', 'tag', 'fdtool_recorder_playpb');
       if isempty(hplay)
         info=0;
       else
         info=~~get(hplay, 'userdata');
       end
     end
  case 'isrecorderrecord' 
     if exist('gui_recorder.m') %new recorder
       info=gui_recorder('isrecorderrecord','fdtool');
     else
       hRecFig=findobj(allchild(0), 'flat', 'tag', 'fdtool_recorder_fig');
       hrec=findobj(allchild(hRecFig), 'flat', 'tag', 'fdtool_recorder_recordpb');
       info=~~get(hrec, 'userdata');
     end
  case 'gettime_datacharacter' 
    info='';
    hGettFig=findobj(allchild(0), 'flat', 'tag', 'gettime_main');
    if ~isempty(hGettFig)
      data=[];
      for ii=1:2
        if isempty(data)
          if ii==1
            data=guidtard('gettime_main', 'DATA_segmenteddata');
          else
            data=guidtard('gettime_main', 'DATA_gotdata');
          end
        end
      end
      if ~isempty(data)
        info=get(data,'inputcharacter');  
      end
    end
    
  otherwise
     error(['INTERNAL ERROR in guiinfos: bad parameter ' infotype])
  end
elseif isstr(p2) % figure hierarchy info
   object=p2; property=infotype;
         
   switch lower(property)
   case 'mother'
      [m,o,c]=findintree(figurehierarchy, p2, {});
      info=m;
      if isempty(info), 
         error(['Possible bad window tag: ' p2, ', or bad hierarchy info.' ])
      end
   case 'allchild'
      [m,o,c]=findintree(figurehierarchy, p2, {});
      [m,o,c]=findintree(o, 'XXXXXXX', {});
      info=c;
   case 'children'
      [m,o,c]=findintree(figurehierarchy, p2, {});
      ch={};
      for ii=3:length(o)
         childii=o{ii};
         ch{ii-2}=childii{1};
      end
      info=ch;
   case 'masterfcn'
      [m,o,c]=findintree(figurehierarchy, p2, {});
      info=o{2};

   otherwise
      error(['INTERNAL ERROR in guiinfos: bad property ' infotype])
   end
else % window properties   
   switch(lower(infotype))   
   case 'ishelpmode'
      winHand=p2;
      if strcmp(get(winHand,'pointer'),'custom') & ...
            ~isempty(guidtard(get(winHand,'tag'), 'ui_props_save'));
         info=1;
      else 
         info=0;
      end
   otherwise
      error(['INTERNAL ERROR in guiinfos: bad question ' infotype])
   end
end

function [m, o, c]=findintree(tree, objname, c);
m=[]; o=[]; 
if isempty(tree)
   return
else
   if strcmp(tree{1}, objname)
      m='root'; o=tree; 
      return
   end
   for ii=3:length(tree);
      childii=tree{ii};
      nameii=childii{1}; c{end+1}=nameii;
      if strcmp(nameii, objname)
         m=tree{1}; o=childii;
         return
      else
         [m, o, c]=findintree(childii, objname, c);
         if ~isempty(o)
            return
         end
      end
   end
end


function y=figurehierarchy
% windowinf = {windowname, masterfcn, {childinfo1},..., {childinfon}}
y={'fdtool_main',         'fdtool',...
      {'excitation_main', 'essd'...
      }, ...
      {'gettime_main',    'gettime',...
         {'gettdatafig',  'gettdata'...
            {'fdsimulation_main',  'fdsimul'...
            },...
            {'fdmeasurement_main',  'fdmeasw'...
            },...
         },...
         {'segmentfig',   'segmdata'...
         },...
         {'convertfig',   ''...
         },...
         {'freqselfig',   'freqsel'...
         }...
      },...
      {'getfreq_main',    'gfdd'...
         {'fdsimulation_main',  'fdsimul'...
         },...
         {'freqsel3fig',  'freqsel'...
         }...
         {'fdmeasurement_main',  'fdmeasw'...
            {'fdtool_getcaldata',  ''...
            },...
         },...
      },...
      {'average_main',    'agv',...
         {'freqsel2fig',  'freqsel'...
         }...
      },...
      {'select_main',     'sme'...
      },...
      {'aided_main',      'sme'...
      },...
      {'compare_main',    'caem'...
      },...
      {'fdtool_importfig',    '*guiimpv'...
      },...
      {'fdtool_exportfig',    '*guiimpv'...
      },...
      {'fdtool_compinput_time_main',    'compinp'...
      },...
      {'fdtool_compinput_time2_main',    'compinp'...
      },...
      {'fdtool_compinput_freq_main',    'compinp'...
      },...
      {'fdident_gui_demos',    '*'...
      },...
   };
% NOTE: If window should not be stored/restored 
%       then masterfcn is empty or must start with a * char !!!!
%
