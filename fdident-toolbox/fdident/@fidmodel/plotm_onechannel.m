function plotm_onechannel(pdat,varargin)
% Fdat,plotmod,path,varargin

%  PLOTM_ONECHANNEL Plot model (maybe along with fiddata object) in a similar way as plot
%  
%         A handle of an axes (or a column vector of two handles of two axes)
%            can be passed at the end preceded by argument 'parent', and the
%            horizontal scaling ('lin' or 'log') after 'xscale'
%         A plot modifier argument (a single character) can take one of the following
%         values: '+-=&#nsm*craSNd'
%         '+' means that only the amplitudes are plotted,
%         '-' that only the phases,
%         'e' phase error
%         The following options plot a large plot of the the magnitude response with
%         extensions.
%         'm' plot parametric model only
%         '*' model+FRF+errors.
%         'v' shows the FRF and the variances.
%         'c' makes the std's of the fitted model also be calculated from the
%             parameter covariance matrix, and plotted.
%         'r' makes the model, FRF and complex residuals be plotted.
%         'a' the same as 'r', but also the 50% and 95% bounds of the magnitudes
%             of the residuals (calculated from the given variances) are plotted.
%         'b' the same as 'a' but also with nonlinear errors
%         'S' lets the signal-to-noise ratio plotted along with the frf.
%         'N' lets the noise-to-signal ratio plotted along with the frf.
%         'd' the combination of 'a' and 'c'
%         'A' or 'B' numerator and denominator of model 
%         or can be
%         'p' poles-zeros
%         Default: '+'
%         For MIMO objects, the pair 'channels',stringcell can define the subplots:
%         e.g. 'ch',{'1/2,'','2/1'} define the 1st and 3rd subplots
%         The handle defines not the axes, but the figure.
%         objtype can be 'linear','nonlinear','interpnonlinear'
%  
%         For pole/zero plots, see 'help plotelpz'
%  
%         Usage:
%           h=plot(model,fdata,plotmod,'objtype',objtype,'parent',hax)
%         Examples:
%           plot(model)
%           h=plot(model,fdata,'parent',hax,'flim',[fmin,fmax])
%           plot(model,'*')


str_plot=struct;
for iv=1:nargin-1
   if nargin>iv && ischar(varargin{iv})
      if strcmp(varargin{iv},'xscale'), str_plot.xscale=varargin{iv+1}(1:3); end
      if strcmp(varargin{iv},'parent'), str_plot.parent=varargin{iv+1}; end
      if strcmp(varargin{iv},'flim'),   str_plot.flim=varargin{iv+1}; end
      if strcmp(varargin{iv},'FRF'),    FRF=varargin{iv+1}; end
      if strcmp(varargin{iv},'freq_dta_points'), freq_dta_points=varargin{iv+1}; end
      if strcmp(varargin{iv},'freqdim')
         if (strcmp(varargin{iv+1},'Hz') || (strcmp(varargin{iv+1},'frequency'))), hzradmult=1;
         else hzradmult=2*pi; end
      end
   end
   if iscell(varargin{iv})
      pathsel=varargin{iv}{1,1};
      if isstr(pathsel)
        ind=find(pathsel=='/');
        if ~isempty(ind)
          pathsel=[str2num(pathsel(1:ind-1)),str2num(pathsel(ind+1:end))];
        end
      end
   end
   if ischar(varargin{iv})
      if length(varargin{iv})==1, plotmod=varargin{iv}; end
   end
   if isobject(varargin{iv}), pdat.data=varargin{iv}; end
end

if isempty(pdat.num), modelpres=0;
else 
   sX=get(pdat,'InputChNumber');
   sY=get(pdat,'OutputChNumber');
   modelpres=1; 
   domain=pdat.variable; 
   num=pdat.num{pathsel(1),pathsel(2)};
   denom=pdat.denom;
end

if isempty(pdat.data), datapres=0;
else 
   sX=get(pdat.data,'InputChNumber');
   sY=get(pdat.data,'OutputChNumber');
   datapres=1; 
end


if ~exist('plotmod','var'), plotmod='+'; end

if ~exist('pathsel','var') || (~isfield(str_plot,'flim') && ~datapres) || ...
   (~exist('freq_dta_points','var') && ~datapres)
   return; 
end      


if modelpres || datapres
   if ~isfield(str_plot,'xscale'), str_plot.xscale='lin'; end
   if ~isfield(str_plot,'parent'), str_plot.parent=gca; end
   if ~exist('hzradmult','var'), hzradmult=1; end
   if isfield(get(str_plot.parent),'WindowStyle'), str_plot.parent=axes('parent',str_plot.parent); end
   if ~exist('FRF','var') && datapres, [FRF.HH,FRF.fr]=frf(pdat.data); end
   if datapres && (~isfield(str_plot,'flim') || ~exist('freq_dta_points','var'));
      frf_ph=FRF.fr{pathsel(1),pathsel(2)};
      if strcmpi(str_plot.xscale,'log')
         if ~isfield(str_plot,'flim'),
            str_plot.flim=[min(frf_ph(find(frf_ph>0))),max(frf_ph)];
         elseif ~str_plot.flim(1)
            str_plot.flim(1)=min(frf_ph(find(frf_ph>0)));
         end
         freq_dta_points=logspace(log10(str_plot.flim(1)),log10(str_plot.flim(2)),100);
      else
         str_plot.flim=[min(frf_ph),max(frf_ph)];
         freq_dta_points=linspace(str_plot.flim(1),str_plot.flim(2),100);
      end
   end
         
   if exist('domain','var')
      if domain(1)=='z', fs=pdat.fs; else fs=1; end   
   else
      fs=1;
   end
   
   delete(findall(str_plot.parent,'Parent',str_plot.parent));
   
   if any(plotmod=='+*vcraSNd') && datapres
      hplot=plot(FRF.fr{pathsel(1),pathsel(2)}*hzradmult,20*log10(abs(FRF.HH{pathsel(1),pathsel(2)})),'g+','parent',str_plot.parent);
      haxplot=get(hplot,'parent');
      set(haxplot,'Nextplot','add','xscale',str_plot.xscale,'xlim',str_plot.flim*hzradmult);
      haxplottitle=get(haxplot,'title');
      set(haxplottitle,'String',sprintf('Magnitude of G(%d,%d)',pathsel(1),pathsel(2)));
      haxxlabel=get(haxplot,'xlabel');
      if hzradmult>1, set(haxxlabel,'String','Frequency [Radian/sec]');
      else, set(haxxlabel,'String','Frequency [Hz]'); end
      haxylabel=get(haxplot,'ylabel');
      set(haxylabel,'String','dB');
   end
   if any(plotmod=='+m*vcraSNd') && modelpres % model
      hplot=plot(freq_dta_points*hzradmult,...
         eval(sprintf('20*log10(abs(freq_fd_%s(num,denom,2*pi*freq_dta_points/fs)));',domain(1))),'r','parent',str_plot.parent);
      haxplot=get(hplot,'parent');
      set(haxplot,'Nextplot','add','xscale',str_plot.xscale,'xlim',str_plot.flim*hzradmult);
      haxplottitle=get(haxplot,'title');
      set(haxplottitle,'String',sprintf('Magnitude of G(%d,%d)',pathsel(1),pathsel(2)));
      haxxlabel=get(haxplot,'xlabel');
      if hzradmult>1, set(haxxlabel,'String','Frequency [Radian/sec]');
      else, set(haxxlabel,'String','Frequency [Hz]'); end
      haxylabel=get(haxplot,'ylabel');
      set(haxylabel,'String','dB');
   end
   if (plotmod=='-' && datapres) || (plotmod=='e' && ~modelpres)
      hplot=plot(FRF.fr{pathsel(1),pathsel(2)}*hzradmult,180/pi*unwrap(angle(FRF.HH{pathsel(1),pathsel(2)})),'g+','parent',str_plot.parent);
      haxplot=get(hplot,'parent');
      set(haxplot,'Nextplot','add','xscale',str_plot.xscale,'xlim',str_plot.flim*hzradmult);
      haxplottitle=get(haxplot,'title');
      set(haxplottitle,'String',sprintf('Phase of G(%d,%d)',pathsel(1),pathsel(2)));
      haxxlabel=get(haxplot,'xlabel');
      if hzradmult>1, set(haxxlabel,'String','Frequency [Radian/sec]');
      else, set(haxxlabel,'String','Frequency [Hz]'); end
      haxylabel=get(haxplot,'ylabel');
      set(haxylabel,'String','Degree');
   end
   if (plotmod=='-' && modelpres) || (plotmod=='e' && ~datapres)
      hplot=plot(freq_dta_points*hzradmult,...
         eval(sprintf('180/pi*unwrap(angle(freq_fd_%s(num,denom,2*pi*freq_dta_points/fs)));',domain(1))),'r','parent',str_plot.parent);
      haxplot=get(hplot,'parent');
      set(haxplot,'Nextplot','add','xscale',str_plot.xscale,'xlim',str_plot.flim*hzradmult);
      haxplottitle=get(haxplot,'title');
      set(haxplottitle,'String',sprintf('Phase of G(%d,%d)',pathsel(1),pathsel(2)));
      haxxlabel=get(haxplot,'xlabel');
      if hzradmult>1, set(haxxlabel,'String','Frequency [Radian/sec]');
      else, set(haxxlabel,'String','Frequency [Hz]'); end
      haxylabel=get(haxplot,'ylabel');
      set(haxylabel,'String','Degree');
   end      
   if plotmod=='e' && modelpres && datapres
      hplot=plot(FRF.fr{pathsel(1),pathsel(2)}*hzradmult,...
         eval(sprintf('180/pi*(angle(freq_fd_%s(num,denom,2*pi*FRF.fr{pathsel(1),pathsel(2)}/fs))-angle(FRF.HH{pathsel(1),pathsel(2)}));',...
                              domain(1))),'c+','parent',str_plot.parent);
      haxplot=get(hplot,'parent');
      set(haxplot,'Nextplot','add','xscale',str_plot.xscale,'xlim',str_plot.flim*hzradmult,'ylim',[-180 +180]);
      haxplottitle=get(haxplot,'title');
      set(haxplottitle,'String',sprintf('Phase error of G(%d,%d)',pathsel(1),pathsel(2)));
      haxxlabel=get(haxplot,'xlabel');
      if hzradmult>1, set(haxxlabel,'String','Frequency [Radian/sec]');
      else, set(haxxlabel,'String','Frequency [Hz]'); end
      haxylabel=get(haxplot,'ylabel');
      set(haxylabel,'String','Degree');
   end      

   
   
   if plotmod=='p' && modelpres
      pdats=fidmodel(domain,num,denom,pdat.delay,pdat.fs);
%       plotelpz(pdats,'parent','parent',str_plot.parent);
        plotelpz(pdats,struct('hax',str_plot.parent));
      set(str_plot.parent,'PlotBoxAspectRatioMode','auto')
   end
      
   
      
      
end
