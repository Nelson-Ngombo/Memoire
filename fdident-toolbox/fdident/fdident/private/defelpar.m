function out=defelpar(mode, param1, param2);
% DEFELPAR elis iteration parameters
% helper file of FDTOOL
%
% return the default elis iteration parameters, 
% or determines whether the input parameter set is the default,
% or compares two parameter data variables (not implemented)
% or generates runmod structure for elis

% input variable MODE determines the type of output  
% if MODE == 'default'
%    OUT  = default elis iteration parameters
% elseif MODE == 'isdefault'
%    OUT  = (default elis iteration parameters) == param1
% elseif MODE == 'isequal'
%    OUT  = (param1 == param2) 
% elseif MODE == 'runmod'
%    OUT  = runmod structure for elis from param1
% end
% param1 and param2 are internal data structures to store runparam settings

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2005
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon, 1999
%       Last modified: 15-Mar-2005, IK

% INTERNAL FORMAT
% Fields: 
%       version               : version control string 
%       stabilization         : {off}|reflection|contraction
%       minimumphase          : {off}|reflection|contraction
%       maxiterations         : {default}|selected
%       startingvalues        : AML|IQML|LS|EE|object|weight|Ur-weight|...
%                               Yr-weight|Eqr-weight|{trials}
% optional fields:
%       selectedmaxiterations : an integer value (or empty)
%       selectedmargin        : a nonnegative value (or empty)
%       selectedstartingmodel : fidmodel object (or empty)
%       selectedstartingweight: weight vector (or empty)

Version='1.0';
DEFAULT_MAXITERATION=50;
Me='select_main'; myfig=findall(0, 'tag',Me);
hdom=findobj(myfig,'tag','sme_uic_dompop'); domain=popupstr(hdom);
if strcmp(domain,'z'), DEFAULT_MARGIN=1;
else DEFAULT_MARGIN=0;
end

switch mode
case 'default'
   out=struct(...
      'version', Version,...
      'stabilization', 'off',...
      'minimumphase', 'off',...
      'maxiterations', 'default',...
      'margin', 'default',...
      'startingvalues', 'trials');
   
case 'isdefault'
   defpar=defelpar('default');
   pars=fieldnames(defpar);
   out=1;
   for ii=1:length(pars) 
      if isfield(param1, pars{ii})
         if strcmp(pars{ii}, 'version')
            % do not check version
         elseif strcmp(pars{ii}, 'maxiterations')
            if ~isequal(getfield(defpar, pars{ii}), getfield(param1, pars{ii}))
               if isfield(param1, 'selectedmaxiterations')& ...
                     isequal(getfield(param1, 'selectedmaxiterations'), DEFAULT_MAXITERATION)
                  % OK, this is the same as default
               else
                  out=0; break
               end
            end
         elseif strcmp(pars{ii}, 'selectedmargin')
           if isfield(param1, 'selectedmargin')& ...
               isequal(getfield(param1, 'selectedmargin'), DEFAULT_MARGIN)
             % OK, this is the same as default
           else
             out=0; break
           end
         else
            if ~isequal(getfield(defpar, pars{ii}), getfield(param1, pars{ii}))
               out=0; break
            end
         end
      else
         % probably old version, new param has been added
         % we use deafult in these cases
      end
   end
      
case 'runmod'
   % generate runmod structure for elis, input is param2
   fn={}; out=[];
   if isstruct(param1), fn=fieldnames(param1); end
   for ii=1:length(fn)
     if strcmp(fn{ii},'version') %1.0
     elseif strcmp(fn{ii},'stabilization')
       v=getfield(param1,fn{ii});
       if strcmp(v,'off')
       elseif strcmp(v,'reflection')
         out.stabilization='r';
       elseif strcmp(v,'contraction')
         out.stabilization='c';
       elseif strcmp(v,'limitation')
         out.stabilization='l';
       else
         error(['Unknown field value: ',v])
       end
     elseif strcmp(fn{ii},'minimumphase')
       v=getfield(param1,fn{ii});
       if strcmp(v,'off')
       elseif strcmp(v,'reflection')
         out.forceminimumphase='r';
       elseif strcmp(v,'contraction')
         out.forceminimumphase='c';
       elseif strcmp(v,'limitation')
         out.forceminimumphase='l';
       else
         error(['Unknown field value: ',v])
       end
     elseif strcmp(fn{ii},'maxiterations')
       v=getfield(param1,fn{ii});
       if strcmp(v,'default')
         %out.itmax=DEFAULT_MAXITERATION; %elis sets it by itself
       elseif strcmp(v,'selected')
         if isfield(param1,'selectedmaxiterations')
           out.itmax=param1.selectedmaxiterations;
         else
           error('Maximum number of iterations is missing')
         end
       else
         error(['Unknown field value: ',v])
       end
     elseif strcmp(fn{ii},'selectedmargin')
       if isfield(param1,'selectedmargin')
         out.selectedmargin=param1.selectedmargin;
       else
         error('Stability margin is missing')
       end
     elseif strcmp(fn{ii},'startingvalues')
       v=getfield(param1,fn{ii});
       if strcmp(v,'AML')
         out.initset='AML';
       elseif strcmp(v,'IQML')
         out.initset='IQML';
         if isfield(param1,'selectedstartingmodel')
           out.initmodel=param1.selectedstartingmodel;
         else
           error('Starting model object is missing')
         end
       elseif strcmp(v,'LS')
         out.initset='svd';
       elseif strcmp(v,'Ur-weight')
         out.initset='u';
       elseif strcmp(v,'Er-weight')
         out.initset='r';
       elseif strcmp(v,'Yr-weight')
         out.initset='v';
       elseif strcmp(v,'EE')
         out.initset='eem';
       elseif strcmp(v,'object')
         out.initset='object';
         if isfield(param1,'selectedstartingmodel')
           out.initmodel=param1.selectedstartingmodel;
         else
           error('Starting model object is missing')
         end
       elseif strcmp(v,'weight')
         out.initset='eW';
         if isfield(param1,'selectedstartingweight')
           out.initweight=param1.selectedstartingweight;
         else
           error('Initial weight is missing')
         end
       elseif strcmp(v,'trials')
         out.initset='trials';
       else
         error(['v=''',v,''' is not allowed'])  
       end
     end
   end %for ii
otherwise
  error('defelpar called with incorrect parameter')
end
%