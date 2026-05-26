function guiclose(name)
% GUICLOSE helper function of FDTool

% function guiclose(NAME)
% close gui window called NAME

% windows with dismiss pushbutton must be closed with CLOSE instead of DELETE if
% test plot is required automatically (eg. when it's mother window is closed, but
% the dismisspb was not pressed before).
% delete must be used if auto test is not required.
% NOTE: test plot is made if dismisspb is pressed, independently of the way of
% window closing.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon 1998-99
%       Last modified: 20-Sep-2001, GYS

switch name
case 'fdtool'
   guiclose('excitation')
   guiclose('gettime')
   guiclose('getfreq')
   guiclose('average')
   guiclose('select')
   guiclose('aided')
   guiclose('compare')
   guirecrd('close')
   try, guiclose('fdtool_recorder_fig'),
   catch, guiclose('guirecrd_fdtool'),
   end
   delete(findall(0,'type','figure','tag','gui_recorder_fdtool')) %separate recorder
   guiclose('fdident_gui_demos')
   guiclose('arrow_plot_fig_main')
   guiclose('arrowdlg')
   h=findall(0,'tag','fdtool_main');
   delete(h)
   h=findall(0,'tag','fdtool_intro_screen');
   delete(h)
   
   % level1 windows
case 'gettime'
   guiclose('gettdata')
   guiclose('importv')
   guiclose('segment')
   %   guiclose('convert')
   guiclose('arrowdlg')
   guiclose('freqsel')
   h=findall(0, 'tag', 'arrow_plot_fig_gettime');
   
   %%%%%%%%%%%%%%%%% Matlab suggests delete instead...
   %close(h)
   delete(h)
   %
   h=findall(0, 'tag', 'arrow_plot_fig_main');
   %close(h)
   delete(h)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   h=findall(0,'tag','gettime_main');
   delete(h)
   
case 'getfreq'
   guiclose( 'fdsimulation')
   guiclose( 'fdmeasurement')
   guiclose('importv')
   guiclose('compose')
   guiclose('freqsel')
   h=findall(0, 'tag', 'arrow_plot_fig_main');
   %Matlab suggests delete
   %if ~isempty(h), close(h), end
   if ~isempty(h), delete(h), end
   h=findall(0,'tag','getfreq_main');
   delete(h)

case 'excitation'
   guiclose('importv')
      
   h=[findall(0, 'tag', 'amplitude_spectrum'), findall(0, 'tag', 'signal_shape')];
   delete(h) % maybe close(h) !?  test plot is not made for this figures 
      
   h=findall(0,'tag','excitation_main');
   delete(h)
   
case 'average'
   guiclose('freqsel')
   guiclose('importv')
   h=findall(0,'tag','average_main');
   delete(h)
   
case 'aided'
   h=findall(0,'tag','aided_main');
   delete(h)
   
case 'compare'
   h=findall(0,'tag','compare_main');
   delete(h)
   guiclose('compare_models')
   guiclose('zoom_models')
   guiclose('importv')
   
case 'select'
   h=findall(0,'tag','select_main');
   delete(h)
   h=findall(0,'tag','aided_main');
   delete(h)
   guiclose('elis')
   h=findall(0,'tag','idbeard_tells_his_opinion');
   delete(h)
   h=findall(0,'tag','AutoModelSelectionDemoFig');
   delete(h)
   
   
% level2 windows
case 'gettdata'
   guiclose( 'fdsimulation')
   guiclose( 'fdmeasurement')
   guiclose( 'importv')
   guiclose( 'compose')
   h=findall(0,'tag','gettdatafig');
   delete(h)
  
case 'segment'
   h=findall(0,'tag','segmentfig');
   delete(h)
case 'freqsel'
   h=findall(0,'tag','freqselfig');
   delete(h)
   h=findall(0,'tag','freqsel2fig');
   delete(h)
   h=findall(0,'tag','freqsel3fig');
   delete(h)
   
case ('importv')
   h=[findall(0,'tag','fdtool_importfig'), ...
         findall(0,'tag','fdtool_exportfig')];
   % if ~isempty(h), set(h, 'visible', 'off'), else return, end
   delete(h)
   
case ('compose')
   h=[findall(allchild(0), 'flat', 'tag', 'fdtool_compinput_time_main');...
         findall(allchild(0), 'flat', 'tag', 'fdtool_compinput_freq_main')];
   delete(h)
   
case 'elis'
   h=findall(0,'tag','elis_window');
   %close(h)
	 delete(h)
   
case 'compare_models'
   h=findall(0,'tag','caem_compare_model_fig');
   %Matlab suggests delete
   %if ~isempty(h), close(h), end
   if ~isempty(h), delete(h), end
   h=findall(0,'tag','caem_model_zoom_fig');
   %Matlab suggests delete
   %if ~isempty(h), close(h), end
   if ~isempty(h), delete(h), end
	 
case 'zoom_models'
   h=findall(0,'tag','caem_view_bar_figure');
   %Matlab suggests delete
   %if ~isempty(h), close(h), end
   if ~isempty(h), delete(h), end
case 'fdsimulation'
   h=findobj(allchild(0), 'flat', 'tag', 'simul_plot_fig_main');
   delete(h)
   guiclose( 'importv')
   h=findall(0,'tag','fdsimulation_main');
   delete(h)
case 'fdmeasurement'
   h=findobj(allchild(0), 'flat', 'tag', 'meas_plot_fig_main');
   delete(h)
   guiclose( 'importv')
   guiclose( 'getcaldata')
   h=findall(0,'tag','fdmeasurement_main');
   delete(h)
case {'fdtool_recorder_fig','guirecrd_fdtool'}
	h=[findobj(allchild(0), 'flat', 'tag', 'fdtool_recorder_fig');
    findobj(allchild(0), 'flat', 'tag', 'guirecrd_fdtool')];
  delete(h)
   
case 'fdident_gui_demos'
   h=findobj(allchild(0), 'flat', 'tag', 'fdident_gui_demos');
   delete(h)
   
case 'getcaldata'
   h=findobj(allchild(0), 'flat', 'tag', 'fdtool_getcaldatafig');
   delete(h)
   
case 'arrow_plot_fig_main'
   h=findobj(allchild(0), 'flat', 'tag', 'arrow_plot_fig_main');
   %Matlab suggests delete
   %if ~isempty(h), close(h), end
   if ~isempty(h), delete(h), end
case 'arrowdlg'
   h=findobj(allchild(0), 'flat', 'tag', 'fdtool_arrowdlg');
   %Matlab suggests delete
   %if ~isempty(h), close(h), end
   if ~isempty(h), delete(h), end
   
   otherwise
   
   disp(['Warning: Guiclose undefined for ' name])
   
end
drawnow
