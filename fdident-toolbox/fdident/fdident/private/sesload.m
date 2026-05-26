function out=sesload(fullname);
% session load from file
% helper file of FDTool

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 23-Aug-2001 by GYS

% function out=sesload(full_session_file_name);
% out=1: success
% out=2; success, but old file
% out=0; error

fdtool('status', ['Loading session from file: ' fullname]);
if ~exist(fullname, 'file')
   fullname1=[fullname '.mat'];
   if exist(fullname1, 'file')
      fullname=fullname1;
   else
      fdtool('status', ['Error: session file ''' fullname ''' does not exist.'])
      out=0; return
   end   
end

load(fullname);

if ~exist('session_data', 'var')
   fdtool('status', ['Error: ''' fullname ''' is not a session file.'])
   out=0; return
else
   ses_version=CheckVersion(session_data);
   if ses_version % not too old data: 1 OK, -1 for slightly old but working
      % close open windows 
      fdtool('status','Closing windows...')
      c=guiinfos('children', 'fdtool_main');
      for ii=1:length(c)
         try, close(findall(0, 'tag', c{ii})), catch, end
      end
      
      guifreez('all_fdtool', 'unfreeze', 'force'); % unfreeze if necessary before load
      if ~isfield(session_data, 'SignalType'), session_data.SignalType='Periodic'; end
      loadwindow('fdtool_main', session_data, ['Session is being loaded from file ' fullname ' ...'])
      if ses_version==1
         fdtool('status',['Session successfully loaded from file ' fullname '.'])
         out=1;
         intoscr('fdtool_main') %pull main window into screen if necessary
      else %-1, slightly old
         if isfield(session_data, 'UserLevel')
            if strcmp(session_data.UserLevel,'Basic')
               ul='Automatic';
               warning(['Obsolete UserLevel ''',session_data.UserLevel,''''])
            elseif strcmp(session_data.UserLevel,'Intermediate')
               ul='Interactive';
               warning(['Obsolete UserLevel ''',session_data.UserLevel,''''])
            elseif strcmp(session_data.UserLevel,'Advanced')|...
                  strcmp(session_data.UserLevel,'Automatic')|...
                  strcmp(session_data.UserLevel,'Interactive')
               ul=session_data.UserLevel;
            else error('Invalid UserLevel')
            end
            fdtool('userlevel_set', ul);
         end
         if isfield(session_data, 'ModelType')
           if strcmp(session_data.ModelType,'Linear')
           elseif strcmp(session_data.ModelType,'Nonlinear error')
           else error('Invalid ModelType')
           end
           fdtool('modeltype',session_data.ModelType);
         end
         fdtool('status',['Warning: File ' fullname ' contains old session data. Some functions may not work properly.'])
         out=2;
      end
   else % too old session data
      fdtool('status',['Error: File ' fullname,...
            ' contains an old version of session data.',...
            ' Delete it or replace it.'])
      out=0;
   end
end

function loadwindow(tWin, data, msg)
masterfcn=guiinfos('masterfcn', tWin);
if any(findstr(masterfcn, '*'))
   masterfcn=''; % * shows that window is not to be stored
end
if ~isempty(data) & ~isempty(masterfcn) 
   fdtool('status', msg)
   if strcmp(tWin, 'fdtool_main')
      storewin('restore', tWin, data);
   else
      feval(masterfcn, 'init', data)
   end
   data.figuretag;
   if ~isempty(data.children)
      for ii=1:length(data.children)
         childdata=data.children{ii};
         loadwindow(childdata.figuretag, childdata, msg)
      end
   end
   %disp(data.figuretag [' restored'])
end

function out=CheckVersion(data)
%CHECKVERSION check session version
%
LatestVersion=sessave('Hello!', 'What is the latest version, please ?');

tmp=char(fieldnames(data))'; fields=tmp(:)';
if findstr(fields, 'version')
   version=data.version;
   if str2num(version) >= str2num(LatestVersion) % this is the latest session, OK
      out=1;
   elseif floor(str2num(version)) >= floor(str2num(LatestVersion)) % this is not the latest, but no major difference
      out=-1;
   else % too old version, this does not work any more
      out=0;
   end
else
   out=0;
end

