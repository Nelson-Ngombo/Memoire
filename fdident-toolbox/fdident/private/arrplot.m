function arrplot(arrowname, p2, p3)
%ARRPLOT  Make arrow plots and internal plots for several blocks.
%
%  Usage:
%        arrplot(arrowname, options), or
%        arrplot('fidmodel', fidmodel_object, options)
%        arrplot('fiddata', fiddata_object, options)
%        arrplot('tiddata', tiddata_object, options)
%              
%  Possible calls:
%     Arrow plots:
%        arrplot('l1')   % plot excitation signal
%        arrplot('l2')   %          ''
%        arrplot('l3')   %          '' 
%        arrplot('l4')   % plot R/MTDD output (fiddata)
%        arrplot('l5')   % plot R/MFDD output (fiddata)
%        arrplot('l6')   % plot VA output (fiddata with variance)
%        arrplot('l7')   %          ''
%        arrplot('l8')   %          ''
%        arrplot('l9')   % plot EPM output (fidmodel)
%        arrplot('l10')  % plot CAMS output (fidmodel(s))
%        arrplot('l11')  % plot ECPM output (fidmodel)
%        arrplot('arr1') % plot GetData (in R/MTDD) output (tiddata)
%        arrplot('arr2') % plot Segmentation (in R/MTDD) output (segmented tiddata)
%        arrplot('arr3') % plot Conv2Freq (in R/MTDD) output (fiddata)
%        arrplot('arr4') % plot FreqSelect (in R/MTDD) output (fiddata)
%          NB.: All 'arr?' calls can have an optional extra 'infoupdate' option:
%               e.g. arrplot('arr1', 'infoupdate')
%               Call with this option updates R/MTDD window's info field.
%    Window updates:
%        arrplot('gfdd_update')       % R/MFDD internal plot update
%        arrplot('gfdd_update_extra') % R/MFDD external plot update
%        arrplot('tim_sim_update')    % Time Domain simulation result (external) update
%        arrplot('freq_sim_update')   % Freq domain simulation result (external) update
%        arrplot('agv_update')        % VA internal plot update
%        arrplot('agv_update_extra')  % VA external plot update
%        arrplot('sme_update')        % EPM internal plot update
%    Data plots:
%        arrplot('fidmodel', fidmodel_object, options)
%        arrplot('fiddata', fiddata_object, options)
%        arrplot('tiddata', tiddata_object, options)
%          NB.: options is optional (no options implemented yet).
%
%       See also: FDTOOL, GUIBAR3, CAEM.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 05-Jun-2001

local_plot=0;
if findstr(arrowname, 'arr')
   Me='arrow_plot_fig_gettime';
   callfcn='gettime';
elseif strcmp(arrowname, 'agv_update')
   callfcn='agv';
   Me='average_main';
   local_plot=1;
elseif strcmp(arrowname, 'agv_update_extra')
   callfcn='agv';
   Me='arrow_plot_fig_main';
   local_plot=0;
elseif strcmp(arrowname, 'gfdd_update_extra')
   callfcn='gfdd';
   Me='arrow_plot_fig_main';
   local_plot=0;
elseif findstr(arrowname, 'gfdd_update')
   callfcn='gfdd';
   Me='getfreq_main';
   local_plot=1;
elseif findstr(arrowname, 'freq_sim_update')
   callfcn='fdsimul';
   Me='simul_plot_fig_main';
elseif findstr(arrowname, 'freq_meas_update')
   callfcn='fdmeasw';
   Me='meas_plot_fig_main';
elseif findstr(arrowname, 'sme_update')
   callfcn='sme';
   Me='select_main';
   local_plot=1;
elseif strcmp(arrowname,'preload')
   % preload, nothing to do
   return
else
   callfcn='fdtool';
   Me='arrow_plot_fig_main';
end   
feval(callfcn, 'status', 'Please wait, updating plot...');

if ~local_plot 
   ArrPlotHand=findall(0, 'tag',Me);
   Name='View Data';
   if isempty(ArrPlotHand)
      [pos,units]=getfpos;
      ArrPlotHand=figure('Units',units, 'position',pos,...
         'Numbertitle', 'off', ...
         'resize', 'on', ...
         'windowstyle', 'normal', ...
         'Name', Name, ...
         'Tag', Me);
      if ~strncmp('5.2',version,3), set(ArrPlotHand,'toolbar','none'); end
      %plot(1); clf
   else
      figure(ArrPlotHand)
      clf
   end
end

intoscr({Me});

% The above function, intoscr positions the windows given by their labels
% into the actual screen. This might come handy when the session has been saved 
% on a machine with different resolution than that of the present machine.

%plot methods here for each arrow
switch arrowname
case {'l1', 'l2', 'l3'}
   Name='View: Output of Excitation Signal Design Block';
   arrdata=guidtard('fdtool_main','OUTPUT_excitation');
   plot(arrdata)
   %title('Excitation Signal Shape')
   %xlabel('Time (s)')
   %zoom(ArrPlotHand,'on')
   zoom(gcf,'on')
case {'gfdd_update', 'gfdd_update_extra', 'freq_sim_update', 'freq_meas_update'}   
   if findstr(arrowname, 'extra')
      Name='View: Read Frequency Domain Data Block';
   elseif findstr(arrowname, 'freq_sim_update')
      Name='View: Frequency domain simulation';
   elseif findstr(arrowname, 'freq_meas_update')
      Name='View: Frequency domain measurement';
   end
   if findstr(arrowname, 'gfdd_update')
      myfig=findobj(allchild(0), 'flat', 'tag', 'getfreq_main');
      ax1=findobj(myfig, 'tag','gfdd_axes_uaxes');
      ax2=findobj(myfig, 'tag','gfdd_axes_laxes');
      outdata=guidtard('getfreq_main', 'OUTPUT_getfreq');
      h1=findobj(myfig, 'tag','gfdd_uic_linloghpop');
      linlogvar=get(h1,'value');
      if linlogvar==1
         fscale='lin';
      else
         fscale='log';
      end
      h=findobj(myfig, 'Tag', 'gfdd_uic_varonoffpop');
      varonoff=get(h,'value');
      h=findobj(myfig, 'Tag', 'gfdd_uic_frffxfypop');
      frffxfy=get(h,'value');
   elseif findstr(arrowname, 'freq_sim_update') % freq simulation plot
      outdata=guidtard('fdsimulation_main', 'DATA_OUTDATA');
      ax2=axes('parent', ArrPlotHand);
      fscale='lin';
      varonoff=1;
      frffxfy=1;
   elseif findstr(arrowname, 'freq_meas_update') % freq simulation plot
      outdata=guidtard('fdmeasurement_main', 'DATA_OUTDATA');
      ax2=axes('parent', ArrPlotHand);
      fscale='lin';
      varonoff=1;
      frffxfy=1;
   else
      error('Arrowname invalid')
   end
   
   if ~isempty(outdata)
      if (varonoff==1)&(outdata.inputchnumber==1)&(outdata.outputchnumber==1)
        vdati=[]; 
        try, vdati=outdata.SisoVariance; catch, end
      else
         vdati=[];
      end
      switch frffxfy
      case 1  %frf
         hAx=[ax2]; msc='*';
      case 2  %mag-phase
         hAx=[ax2 ax1]; msc='=';
      case 3  %fy fu
         hAx=[ax2 ax1]; msc='&';
      end
      
      %fusi !!!
      
      if ~isa(outdata,'fiddata')
         guifreez('all_fdtool', 'unfreeze', 'force');
         error('input is not an fiddata object')
      end
      M=[];
      if isa(outdata,'iddat')
         Fdat=outdata;
         freqvect=outdata.inputfreqpoints; 
         x=outdata.input; y=outdata.output;
         expno=outdata.expn;
         if iscell(x), Fx=length(x{1});
         else Fx=length(x);
         end
         if 0 %not necessary ???
           %Fdat=outdata;
           xl=x; yl=y;
           if iscell(x), xl=x{1}; for ii=2:length(x), xl=[xl;x{ii}]; end, end
           if iscell(y), yl=y{1}; for ii=2:length(y), yl=[yl;y{ii}]; end, end
           if iscell(freqvect),
             fvs=freqvect; freqvect=fvs{1};
             for ii=2:size(fvs,2), freqvect=[freqvect;fvs{1,ii}]; end
           end
           Fdat=expfou(freqvect,xl,yl,[],[],[],[],[],[],'neg');
         end
         M=get(outdata,'M');
      end
      dfi=dfcalc(freqvect);
      F=length(freqvect);
      fmin=min(freqvect);
      fmax=max(freqvect);
      if findstr(arrowname, 'extra')
         if length(hAx)==1
            hAx=axes('parent', ArrPlotHand);
         else
            hAx=[...
                  axes('parent', ArrPlotHand, 'units', 'normal', ...
                  'position', [0.13 0.58 0.78 0.34]), ...
                  axes('parent', ArrPlotHand, 'units', 'normal', ...
                  'position', [0.13 0.11 0.78 0.34])];
         end
      end
      if strcmp(arrowname, 'gfdd_update')
        if dfi>0, fmdfi=fmax/dfi; else fmdfi=NaN; end
        Fstr='F';
        if isa(outdata,'iddat')
          freqvect=outdata.inputfreqpoints; 
          if iscell(freqvect), Fstr='allF'; end
        end
        infotext('gfdd', 'Expno', expno, ...
          'dfi', dfi, Fstr, F, 'fmin', fmin, 'fmax', fmax, 'fmax/dfi', fmdfi,'M',M)
      else
         set(get(hAx(1),'parent'),...
            'WindowButtonDownFcn','zoom down','WindowButtonUpFcn','ones;') %zoom on  
      end
      if isnumeric(vdati), %vdati=vdati/2; %prepare for old call
      elseif iscell(vdati)
        for ii=1:prod(size(vdati))
          %vdati{ii}=vdati{ii}/2; 
        end
      end
      if isequal(Fdat.inputchnumber,1)&isequal(Fdat.outputchnumber,1)
        ploteltf('','',Fdat,fscale,msc,vdati,'','','','','nomesg',hAx);
      else
        warning('not yet ready')
      end
   end
   
case {'l6', 'l7', 'l8', 'agv_update', 'agv_update_extra'}
   if findstr(arrowname, 'extra')
      Name='View: Variances and/or Averaging Block';
   else
      Name='View: Output of Variances and/or Averaging Block';
   end
   if any(findstr(arrowname, 'agv_update'))
      myfig=findobj(allchild(0), 'flat', 'tag', 'average_main');
      ax1=findobj(myfig, 'tag','agv_axes_laxes');
      ax2=findobj(myfig, 'tag','agv_axes_uaxes');
      bfcn_uaxes=get(ax1,'buttondownfcn');
      bfcn_laxes=get(ax2,'buttondownfcn');
      
      fvdata=guidtard('average_main','FINAL_DATA');
      inpdata=guidtard('average_main','DATA_Fdat');
      if isa(fvdata,'iddat')
         Fdat=fvdata;
      else
         Fdat=inpdata;
      end
      h=findobj(myfig, 'Tag', 'agv_uic_linloghpop');
      val=get(h,'value');
      if val==1 %lin
         fscale='lin';
      else
         fscale='log';
      end
      h=findobj(myfig, 'Tag', 'agv_uic_frffxfypop');
      plstr=popupstr(h);
      val=get(h,'value');
      hv=findobj(myfig, 'Tag', 'agv_uic_varpop');
      valv=get(hv,'value');
      if strcmpi(plstr,'frf')&(valv==1) %frf+var
         msc='*';
         if ~guiinfos('islinear'), msc='@'; end
         axhand=ax1;
      elseif strcmpi(plstr,'frf')&(valv==2) %frf
         msc='+';
         axhand=ax1;
      elseif strcmpi(plstr,'mag-phase')&(valv==1) %mag-phase + var
         msc='=';
         axhand=[ax2 ax1];
         if ~any(findstr(arrowname, 'extra'))
           delete(allchild(axhand(1)))
           delete(allchild(axhand(2)))
         end
       elseif strcmpi(plstr,'mag-phase')&(valv==2) %mag-phase
         msc='=';
         axhand=[ax2 ax1];
         if any(findstr(arrowname, 'extra'))
           delete(allchild(axhand(1)))
           delete(allchild(axhand(2)))
         end
       elseif strcmpi(plstr,'output-input')&(valv==1) %f-U,f-Y + var
         msc='#';
         if ~guiinfos('islinear'), msc='2'; end
         axhand=[ax1 ax2];
         if ~any(findstr(arrowname, 'extra'))
           delete(allchild(axhand(1)))
           delete(allchild(axhand(2)))
         end
      elseif strcmpi(plstr,'output-input')&(valv==2) %f-U,f-Y
         msc='&';
         axhand=[ax1 ax2];
         if ~any(findstr(arrowname, 'extra'))
           delete(allchild(axhand(1)))
           delete(allchild(axhand(2)))
         end
      elseif strcmpi(plstr,'output only') %output only
         msc='1';
         axhand=ax1;
      else
         error('unidentified case')  
      end
      if valv==2, vdat=[];
      else vdat=Fdat.SisoVariance;
      end
      if findstr(arrowname, 'extra')  % enlarge figure
        if length(axhand)==1
          axhand=axes('parent', ArrPlotHand);
        else
          axhand=[...
              axes('parent', ArrPlotHand, 'units', 'normal', ...
              'position', [0.13 0.58 0.78 0.34]), ...
              axes('parent', ArrPlotHand, 'units', 'normal', ...
              'position', [0.13 0.11 0.78 0.34])];
            h=findobj(myfig, 'Tag', 'agv_uic_frffxfypop');
            if strcmp(popupstr(h),'output-input')
              axhand=fliplr(axhand);
            end
        end
      else %normal agv plot
        if ~isempty(findobj(0,'type','figure','tag','arrow_plot_fig_main'))
          arrplot('agv_update_extra')
        end
      end
   else % arrow plot
      Fdat=guidtard('fdtool_main','OUTPUT_average');
      axhand=axes('parent', ArrPlotHand);
      msc='*';
      %if ~guiinfos('islinear'), msc='%'; end
      fscale='lin';
      vdat=Fdat.SisoVariance;
   end
   if isa(Fdat,'iddat')
      %oldFdat=Fdat;
      x=Fdat.input; y=Fdat.output; fv=Fdat.inputfreqpoints;
      if iscell(fv)
        x=cat(1,x{:}); y=cat(1,y{:}); fv=cat(1,fv{:});
      end
      xl=x; yl=y; fvl=fv;
      if 0&iscell(x)&iscell(y) %expno>1
         delayx=Fdat.inputdelay; delayy=Fdat.outputdelay;
         if ~iscell(delayx)|isempty(delayx), delayx={0}; end
         if ~iscell(delayy)|isempty(delayy), delayy={0}; end
         dmodx=exp(-j*2*pi*fv*delayx{1});
         dmody=exp(-j*2*pi*fv*delayy{1});
         xsav=x; xl=dmodx.*xsav{1}; ysav=y; yl=dmodx.*ysav{1};
         for ii=2:size(xsav,2)
            if size(delayx,2)>1, dmodx=exp(-j*2*pi*fv*delayx{ii}); end
            if size(delayy,2)>1, dmody=exp(-j*2*pi*fv*delayy{ii}); end
            xl=[xl;dmodx.*xsav{ii}]; 
            yl=[yl;dmody.*ysav{ii}]; 
         end
         oldFdat=expfou(fv,xl,yl,[],[],[],[],[],[],'neg');
       else
         oldFdat=Fdat;
       end
    else
      [F, p, expno]=size(Fdat.data);
      oldFdat=expfou(Fdat.places, reshape(Fdat.u, F*expno,1), ...
         reshape(Fdat.y, F*expno,1));
   end
   set(axhand,'visible','on') %Hz disappears at first appearance
   %plot(0,0,'parent',axhand(1)) %let system initialize figure
   %if length(axhand)>1, plot(0,0,'x','parent',axhand(2)), end
   if isnumeric(vdat)
     %vdat=vdat/2; %prepare old call
   else
     for ii=1:length(vdat)
       %vdat{ii}=vdat{ii}/2; 
     end
   end
   %
   if any(findstr(arrowname, 'agv_update'))
     %try
       if guiinfos('islinear'), objtype='linear';
       elseif isempty(Fdat.nonlincovariancematrix), objtype='interpnonlin';
       else objtype='nonlin';
       end
       hf=get(axhand(1),'parent');
       if any(findstr(arrowname, 'extra'))
         plot(fidmodel,oldFdat,msc,'xscale',fscale,'parent',hf,'menu','on')
         axhand=findobj(hf,'type','axes','visible','on');
       else
         %ploteltf('','',oldFdat,fscale,msc,vdat,'','','','','nomesg',axhand,'',objtype);
         plot(fidmodel,oldFdat,msc,'xscale',fscale,'parent',axhand)
       end
     %catch
     %  fdtool('status','Error: something is wrong with the data')
     %  error(lasterr)
     %end
   else
     if any(findstr(fscale,'log')), xcsc='log'; else xsc='lin'; end
     hf=get(axhand,'parent');
     plot(fidmodel,Fdat,msc,'xscale',xsc,'parent',hf,'menu','on')
     axhand=findobj(hf,'type','axes','visible','on');
   end
   %
   hftyp=findobj(findall(0,'type','figure','tag','average_main'), 'Tag', 'agv_uic_frffxfypop');
   if strcmp(popupstr(hftyp),'output only')
     if isempty(vdat), xstr='Amplitudes: +'; titlstr='Magnitudes of output';
     else xstr='Amplitudes: +, variances: x'; 
       if ~guiinfos('islinear')
         titlstr='Magnitudes of output and error levels';
       else
         titlstr='Magnitudes of output and variances';
       end
     end
   else
     if isempty(vdat), xstr='Amplitudes: +'; titlstr='Magnitudes of frf';
     else xstr='Amplitudes: +, variances: x'; titlstr='Magnitudes of frf and Variances';
     end
   end
   titladd='';
   if strcmp(arrowname, 'agv_update')
      if ~isempty(fvdata)
        titladd='Result: '; 
      else
        titladd='';
      end
   end
   if length(axhand)<2 %one plot
      %set(get(axhand(1),'xlabel'),'string',xstr)
      set(get(axhand(1),'ylabel'),'string','dB')
      set(get(axhand(1),'title'),'string',[titladd,titlstr])
    elseif strcmp(msc(end),'=')
      set(get(axhand(1),'ylabel'),'string','dB')
      set(get(axhand(2),'ylabel'),'string','degrees')
      set(get(axhand(1),'title'),'string',[titladd,'Magnitude of FRF'])
      set(get(axhand(2),'title'),'string',[titladd,'Phases'])
    else
      set(get(axhand(1),'ylabel'),'string','dB')
      set(get(axhand(2),'ylabel'),'string','dB')
      set(get(axhand(1),'title'),'string',[titladd,'Input amplitudes'])
      set(get(axhand(2),'title'),'string',[titladd,'Output amplitudes'])
   end
   if strcmp(arrowname, 'agv_update')
      set(ax2,'tag','agv_axes_uaxes','buttondownfcn', bfcn_uaxes);
      set(ax1,'tag','agv_axes_laxes','buttondownfcn', bfcn_laxes);
      agv('resize');  % ide kell egy opcio: csak axes update
      agv('status', 'Done')
   else
      set(get(axhand(1),'parent'),...
         'WindowButtonDownFcn','zoom down','WindowButtonUpFcn','ones;') %zoom on  
   end
   
   %plot here
case {'l9', 'sme_update', 'l11','l10', 'fidmodel'}
   if strcmp(arrowname, 'sme_update')
      % frf case
      sme('status', 'Updating plot...')
      ax=findall(0, 'tag','sme_axes_ax');
      bfcn_axes=get(ax,'buttondownfcn');
      inp_data=guidtard(Me,'DATA_INPUT');
      if guiinfos('islinear')
        inp_data.NonlinCovariance=[]; %eliminate nonlinear variance if not needed
      end
      final_data=guidtard(Me,'FINAL_DATA');
      if iscell(final_data)&~isempty(final_data)
         final_data=final_data{1};
      end
      h1=findall(0, 'tag','sme_uic_linloghpop');
      linlogvar=get(h1,'value');
      if linlogvar==2, fscale='log';
      else fscale='lin';
      end
      h2=findall(0, 'tag','sme_uic_varpop');
      %if ~isempty(final_data), set(h2,'enable','off')
      %else set(h2,'enable','on')
      %end
      if strcmp(popupstr(h2),'var on')
        if guiinfos('islinear'), vdat=inp_data.SisoVariance;
        else vdat=[inp_data.OutputNonlinVariance];
          try, vdat=[vdat,inp_data.OutputNonlinVariance,inp_data.NonlinCovVector];
          catch, if (size(vdat,2)==1)|(size(vdat,2)==2), vdat(1,3)=0; end
          end
        end
      else vdat=[];
      end
      
   else % arrow plot, output data
      if strcmp(arrowname,'l11')
         Name='View: Output of Evaluate or Compare and Plant Models Block';
         final_data=guidtard('fdtool_main','OUTPUT_compare');
         inp_data=final_data.data; 
         %inp_data=final_data.userdata.inputFv; 
      elseif strcmp(arrowname,'l10')
         Name='View: Output of Computer Aided Model Scan Block';
         final_data=guidtard('fdtool_main','OUTPUT_aided');
         if isempty(final_data)
            fdtool('status','Error: empty CAMS output data')
            return
         elseif ~isa(final_data, 'fidmodel')   
            fdtool('status', 'Error: not fidmodel data!')
            return
         end
         inp_data=final_data(:,:,1).data;
         
      elseif strcmp(arrowname,'l9')
         Name='View: Output of Estimate Plant Model Block';
         final_data=guidtard('fdtool_main','OUTPUT_select');
         if isempty(final_data)
            fdtool('status','Error: empty EPM output data')
            return
         elseif ~isa(final_data, 'fidmodel')   
            fdtool('status', 'Error: not fidmodel data!')
            return
         end
         inp_data=final_data.data; 
      else % fidmodel, plot data = p2
         % p3: options, not used yet
         Name='View: fidmodel data';
         final_data=p2;
         if isempty(final_data)
            fdtool('status','Error: empty data')
            return
         elseif ~isa(final_data, 'fidmodel')   
            error('Input data is not fidmodel!')
         end
         inp_data=final_data(:,:,1).data; 
         
      end
      ax=axes('parent', ArrPlotHand);
      fscale='lin';   
   end
   mn='';
   try, if feval(['fdc','fs'],['l','ic'])>1, mn='on'; else mn='off'; end, catch, end
   %
   if isa(inp_data,'iddat')
      Fdat=inp_data;   
   elseif ~isempty(inp_data)
      fv=inp_data.places; x=inp_data.u; y=inp_data.y;
      [F, p, expno]=size(x);
      Fdat=expfou(fv, reshape(x,F*expno,1), reshape(y,F*expno,1));
   else
     Fdat=[];
     if strcmp(msc,'r'), msc='*'; end
   end
   %
   if isempty(final_data) % input data
      pdat=[];
      val=get(findall(0,'tag','sme_uic_varpop'),'value');
      if val==2, von=0; else von=1; end %variance on or off
      %von=0; %egyelore variancia rajzolas a kezelesig kikapcsolva
      if von==0, vdat=[]; 
        inp_data.M=[]; inp_data.covariancematrix=[]; 
        inp_data.nonlinM=[]; inp_data.nonlincovariancematrix=[];
        % not inp_data.SisoVariance;
      else vdat=inp_data.SisoVariance;
      end
      if guiinfos('islinear'), msc='*';
      else msc='w';
      end
   else % output data available
      pdat=final_data;
      if strcmp(arrowname, 'sme_update'), Fdat=pdat.data; end
      %vdat=final_data.CR;
      %vdat=[];
      if guiinfos('islinear'), msc='a';
      else msc='b';
      end
   end
   %fusi !!!
   
   %if isnumeric(vdat), vdat=vdat/2; %prepare old call
   %else for ii=1:length(vdat), vdat{ii}=vdat{ii}/2; end
   % end
   if strcmp(arrowname, 'sme_update')
     ploteltf(pdat,'',Fdat,fscale,msc,vdat, '','','','','nomesg',ax);
     if ~isempty(pdat)
       hFig=get(ax,'parent');
       hmodelhelp=[findobj(hFig,'type','uimenu','tag','select_menu_help_model'), ...
           findobj(hFig,'type','uimenu','tag','select_menu_help_advice'), ...
           findobj(hFig,'type','uimenu','tag','aided_menu_help_model')];
       set(hmodelhelp,'enable','on')
     end
   else
     if any(findstr(fscale,'log')), xsc='log'; else xsc='lin'; end
     hf=get(ax,'parent');
     plot(pdat,Fdat,msc,'xscale',xsc,'parent',hf,'menu',mn)
     ax=findobj(hf,'type','axes','visible','on');
   end

   %
   if (exist('vdat')&isempty(vdat))|strcmp(callfcn,'sme'), xstr=''; 
   else xstr='Amplitudes: +, variances: x';
   end 
   set(get(ax,'xlabel'),'string',xstr) 
   if strcmp(arrowname, 'sme_update')
      set(ax,'tag','sme_axes_ax', 'buttondownfcn', bfcn_axes);
   else 
      set(get(ax(1),'parent'),...
         'WindowButtonDownFcn','zoom down','WindowButtonUpFcn','ones;') %zoom on  
   end
   %case 'l10'
   %Name='View: Output of Computer Aided Model Scan Block';
   %plot here
case {'arr1', 'arr2', 'arr12', 'tim_sim_update', 'tim_meas_update', 'tiddata'}
   Name='View: Time Domain Data ';
   if strcmp(arrowname, 'arr1')
      caller_name='gettdata';
   elseif strcmp(arrowname, 'arr2')|strcmp(arrowname, 'arr12')
      caller_name='segment';
      if strcmp(arrowname, 'arr2'), Name=[Name '(segmented)']; end
   elseif strcmp(arrowname, 'tim_sim_update')
      caller_name='t_simul';
      Name='Time Domain Simulation';   
   elseif strcmp(arrowname, 'tim_meas_update')
      caller_name='t_meas';
      Name='Time Domain Measurement';   
   else
      caller_name='default_plot';
      Name='View: tiddata object';   
   end   
   
   %plot here
   tGettimeWin='gettime_main';
   if strcmp(caller_name, 'gettdata')
      inpdata=guidtard(tGettimeWin, 'DATA_gotdata');
      gdata=[];
   elseif strcmp(caller_name, 'segment')
      inpdata=guidtard(tGettimeWin, 'DATA_segmenteddata');
      gdata=guidtard(tGettimeWin, 'DATA_gotdata');
   elseif strcmp(caller_name, 't_simul')  
      inpdata=guidtard('fdsimulation_main', 'DATA_OUTDATA');
      gdata=[];  % ????
   elseif strcmp(caller_name, 't_meas')  
      inpdata=guidtard('fdmeasurement_main', 'DATA_OUTDATA');
      gdata=[];  % ????
   elseif strcmp(caller_name, 'default_plot')
      inpdata=p2; 
      p2=''; if nargin>2; p2=p3; end % options -> p2
      gdata=[];  % ????
   end
   
   if isa(inpdata,'tiddata')
      timevect=inpdata.samplinginstants;
      xt=inpdata.input; yt=inpdata.output; expno=inpdata.expn;
      if isempty(timevect)
         dt=inpdata.ts; fs=1/dt;
         timevect=[0:inpdata.samplen-1]'*dt;
      else
         fs=1/mean(diff(timevect)); dt=1/fs;
      end
   else
      timevect=inpdata.places;
      xt=inpdata.u;
      yt=inpdata.y;
      expno=size(xt,3);
      fs=1/mean(diff(timevect)); dt=1/fs;
   end
   expnopl=expno;
   N=length(timevect);
   Tr=N*dt; df=fs/N;
   %caller_name, arrowname - segment, arr2
   if strcmp(caller_name, 'segment') 
     ovl=inpdata.userdata; 
     if isempty(ovl); ovls=-0.2; else ovls=ovl; end 
   else % gettdata
     ovl=[];
     if expno>1, ovls=-0.2; else ovls=0; end 
   end
   if (nargin>1) & strcmp(p2, 'infoupdate')
      hist=inpdata.history;
      if iscell(hist), hist=hist{end}; end
      gettime('setinfo','text_info11',hist)
      gettime('setinfo','text_info21', sprintf('fs = %.4g Hz', fs),'Sampling frequency')
      gettime('setinfo','text_info31', sprintf('Tri = %.4g s', Tr),'Record length in an experiment')
      gettime('setinfo','text_info41', sprintf('Ni = %.0f', N),'Number of samples in an experiment')
      gettime('setinfo','text_info51', sprintf('Expno = %.0f', expno),'Number of experiments')
      gettime('setinfo','text_info22', sprintf('dt = %.4g s', dt),'Sampling interval')
      gettime('setinfo','text_info32', sprintf('dfi = %.4g Hz', df),'Frequency resolution in DFT of an experiment')
      Nper=get(inpdata,'periodnumber');
      if isnumeric(Nper)&(length(Nper)==1)&isfinite(Nper)&(Nper>0)
        gettime('setinfo','text_info42', sprintf('Pno = %.0f',Nper),'Number of periods')
      end
      gettime('setinfo','text_info52', sprintf(''))
   end
   h=ArrPlotHand;
   figure(h)
   %clf
   if ~isempty(xt)
     ax1=axes('parent',h,'units','normalized',...
       'position', [0.13, 0.11, 0.775, 0.3239]); %0.3439
     ax2=axes('parent',h,...
       'units', 'normalized',...
       'position', [0.13, 0.6011, 0.775, 0.3239]); %0.5811 0.3239
     if ~isa(inpdata,'tiddata')|~isequal(ovl,0)
       if isa(gdata,'iddat')&(gdata.expn==1)
         %original time function is to be plotted
         %Gyuszi! Hogyan lehet megfekezni, ha nem osszetartozo a segm bemenete
         %es kimenete? Ilyenkor a masik ag kell!
         xt=gdata.input;
         if iscell(xt)
           error('xt is a cell array')
           xtc=xt; xt=xtc{1};
           for ii=2:size(xtc,2), xt=[xt;xtc{ii}]; end
         end
         timevect=gdata.samplinginstants;
         if isempty(timevect)
           dt=gdata.ts; fs=1/dt;
           timevect=[0:gdata.samplen-1]'*dt;
         end
         plot(timevect, xt, 'parent', ax1);
         if (length(timevect)==1)&isequal(timevect,0), mod=1e-6; else mod=0; end
         set(ax1,'xlim',[min([timevect(:);0])-mod,max([timevect(:);0])+mod])
       else
         for ii=1:expnopl
           if iscell(xt)
             plot(timevect+(ii-1)*(1-ovls)*N*dt, xt{1,ii}, 'parent', ax1)
           else
             plot(timevect+(ii-1)*(1-ovls)*N*dt, xt, 'parent', ax1)
           end
           set(ax1, 'nextplot', 'add')
         end
         set(ax1, 'nextplot', 'replace')
         ax=get(ax1, 'xlim');
         ax(2)=length(timevect)*dt+(expnopl-1)*N*(1-ovls)*dt;
         set(ax1, 'xlim', ax);
       end
       if  (strcmp(caller_name, 'segment') | (expno>1)) & ~isempty(ovl)
         set(ax1,'nextplot','add')
         plotsegm(Tr, expno, ovl, ax1)
         figure(get(ax1,'parent'))
         %drawnow %pop figure to front
         set(ax1,'nextplot','replace')
       end
       ititle=inpdata.inputname;
       set(get(ax1,'ylabel'),'string',ititle)
       set(get(ax1,'title'),'string','Input');
       set(get(ax1,'xlabel'),'string','Time (s)');
     else
       plot(inpdata,'parent',[ax1;ax2]);
     end %~isempty(xt)
   end
   
   if ~isempty(yt)
     if ~isa(inpdata,'tiddata')|~isequal(ovl,0)
       if isa(gdata,'iddat')&(gdata.expn==1)
         %original time function is to be plotted
         %Gyuszi! Hogyan lehet megfekezni, ha nem osszetartozo a segm bemenete
         %es kimenete? Ilyenkor a masik ag kell!
         yt=gdata.output;
         if iscell(yt)
           error('yt is a cell array')
           ytc=yt; yt=ytc{1};
           for ii=2:size(ytc,2), yt=[yt;ytc{ii}]; end
         end
         plot(timevect, yt, 'parent', ax2);
         if (length(timevect)==1)&isequal(timevect,0), mod=1e-6; else mod=0; end
         set(ax2,'xlim',[min([timevect(:);0])-mod,max([timevect(:);0])+mod])
       else
         for ii=1:expnopl
           if iscell(yt)
             plot(timevect+(ii-1)*(1-ovls)*N*dt, yt{1,ii}, 'parent', ax2)
           else
             plot(timevect+(ii-1)*(1-ovls)*N*dt, yt, 'parent', ax2)
           end
           set(ax2, 'nextplot', 'add')
         end
         ax=get(ax2, 'xlim');
         ax(2)=length(timevect)*dt+(expnopl-1)*N*(1-ovls)*dt;
         set(ax2, 'xlim', ax);
       end
       set(ax2, 'nextplot', 'replace')
       if  (strcmp(caller_name, 'segment') | (expno>1)) & ~isempty(ovl)
         set(ax2,'nextplot','add')
         plotsegm(Tr, expno, ovl, ax2)
         figure(get(ax2,'parent'))
         %drawnow %pop figure to front
         set(ax2,'nextplot','replace')
       end
       %
       %Unfortunately, the following	commands replot on a Sun!
       otitle=inpdata.outputname;
       set(get(ax2,'ylabel'),'string',otitle)
       set(get(ax2,'title'),'string','Output');
         set(get(ax2,'xlabel'),'string','Time (s)');
     else
       %other half of plot
       if ~exist('ax2')
         ax2=axes('parent',h,...
           'units', 'normalized',...
           'position', [0.13, 0.6011, 0.775, 0.3239]); %0.5811 0.3239
         plot(inpdata,'parent',[ax1;ax2])
       end
     end
   end %isempty(yt)
     
   set(h,'WindowButtonDownFcn','zoom down','WindowButtonUpFcn','ones;') %zoom on
   
   gettime('status', 'Done.')
   
case {'arr3', 'arr4', 'l4', 'l5', 'fiddata'}
   
   if strcmp(arrowname, 'arr3')
      Name='View: Frequency Domain Data ';
      arrdata=guidtard('gettime_main', 'DATA_converteddata');
   elseif strcmp(arrowname, 'arr4')
      Name='View: Frequency Domain Data (selected)';
      arrdata=guidtard('gettime_main', 'DATA_selecteddata');
   elseif strcmp (arrowname, 'l4')
      Name='View: Output of Read Time Domain Data Block';
      arrdata=guidtard('fdtool_main', 'OUTPUT_gettime');
   elseif strcmp (arrowname, 'l5')
      Name='View: Output of Read Freq. Domain Data Block';
      arrdata=guidtard('fdtool_main', 'OUTPUT_getfreq');
   else % fiddata   
      Name='View: fiddata object';
      arrdata=p2;
      p2=''; if nargin>2; p2=p3; end %options -> p2
   end
   options=p2;
   
   fdata=arrdata;
   
   if isa(fdata,'iddat')
      u=fdata.input; y=fdata.output; places=fdata.freqpoints;
      if isempty(places), error('Freqpoints is empty in object'), end
      expno=fdata.expn; M=get(fdata,'M');
   else
      u=fdata.u; y=fdata.y; places=fdata.places;
      expno=size(u,3); M=[];
   end
   F=length(places);
   fmax=max(places);
   fmin=min(places);
   dfi=dfcalc(places);
   if (nargin>1) & strcmp(options, 'infoupdate')
      hist=fdata.history'; hist=hist{end}; 
      gettime('setinfo','text_info11',hist)
      gettime('setinfo','text_info21', sprintf('freqs = %.4g', F),'Number of frequencies')
      gettime('setinfo','text_info31', sprintf('fmin = %.4g Hz', fmin),'Minimum frequency')
      gettime('setinfo','text_info41', sprintf('fmax = %.4g', fmax),'Maximum frequency')
      gettime('setinfo','text_info51', sprintf('Expno = %.0f', expno),'Number of experiments')
      gettime('setinfo','text_info22', sprintf('dfi = %.4g Hz', dfi),'Maximum common divisor of frequencies')
      gettime('setinfo','text_info32', sprintf('fmax/dfi = %.4g', fmax/dfi),'Maximum harmonic number')
      if ~isempty(M),  gettime('setinfo','text_info42', sprintf('M = %.0f',M))
      else gettime('setinfo','text_info42', sprintf(''))
      end
      gettime('setinfo','text_info52', sprintf(''))
   end
   
   
   
   figure(ArrPlotHand)
   %delete(allchild(ArrPlotHand))
   delete([findobj(ArrPlotHand,'type','axes');findobj(ArrPlotHand,'type','uicontrol')])
   [su,pu,eu]=size(u); [sy,py,ey]=size(y);
   
   % ide be kellene tenni a handlert :
   % ez a tobbszoros plot?
   axh(1)=axes('position',[0.1300 0.5811 0.7750 0.3439],'parent',ArrPlotHand);
   axh(2)=axes('position',[0.1300 0.1100 0.7750 0.3439],'parent',ArrPlotHand);
   if isa(fdata,'iddat')
     hf=get(axh(1),'parent');
     switch arrowname
       case {'arr3', 'arr4', 'l4', 'l5'}, msc='*';
       otherwise, msc='+';
     end
     plot(fdata,[],msc,'parent',hf,'menu','on');
     %
   elseif iscell(u) %iddat with several experiments
      usav=u; u=usav{1}; ysav=y; y=ysav{1};
      for ii=2:length(usav)
         u=[u;usav{ii}];
         y=[y;ysav{ii}];
      end
      [ha1,ha2,fsc]=ploteltf('','',expfou(places,u,y,[],[],[],[],[],[],'neg'),[],'=',[],[],[],[],[],[],axh); 
   else
      [ha1,ha2,fsc]=ploteltf('','',expfou(places,reshape(u,su*pu*eu,1),...
         reshape(y,sy*py*ey,1),[],[],[],[],[],[],'neg'),[],'=',[],[],[],[],[],[],axh);
   end
   %if eu>1
   %  yl=get(ha1,'ylim');
   %  meanu=mean(u,3); meany=mean(y,3);
   %  set(ha1,'nextplot','add')
   %  hm=plot(places/fsc,20*log10(abs(meany./meanu)),'*c','parent',ha1,...
   %    'markersize',4);
   %  set(ha1,'nextplot','replacechildren')
   %  set(ha1,'ylim',yl);
   %end
   zoom(ArrPlotHand,'on') %Gyuszi! Jo ez igy?
   feval(callfcn, 'status', 'Done.')
   
end

if ~local_plot
   set(ArrPlotHand, 'Name', Name)   
   hax=findobj(ArrPlotHand,'type','axes');
   for ii=1:length(hax)
      prepzoom(hax(ii)) %prepare zooming
   end
   dismispb(Me)
   %
   if 1==2
   %definition of plot type pulldown menu
   winpos=get(ArrPlotHand,'position');
   if exist('pdat')&isa(pdat,'fidmodel')
     %r m *  c a  N + - =
     string={'Model + FRF + residuals','Model','Model + FRF + std''s',...
         'Model + std''s + FRF','Model + FRF + bounds','Model + FRF + SNR',...
         'Magnitude','Phase','Magnitude and phase'};
   elseif exist('Fdat')&isa(Fdat,'fiddata')
     %*  &  n N  + - =
     string={'FRF + variances','f-U and f-Y','f-U and f-Y + SNR''s','FRF + SNR',...
         'Magnitude','Phase','Magnitude and phase'};
   else
     string='';
   end
   if ~isempty(string)
     callb='';
     callb='set(findall(0,''tag'',''arrplot_type_pulldownmenu''),''value'',1)';
     %ploteltf(pdat,'',Fdat,fscale,msc,vdat, '','','','','nomesg',ax);
     %fscale='lin', vdat=[]
     h_pd=uicontrol('parent', ArrPlotHand, ...
       'units', 'pixel',...   
       'position', [winpos(3)-160, winpos(4)-20, 160 20],...
       'style','popupmenu',...
       'string', string,...
       'Tooltipstring','Type of plot',...
       'callback', callb,...
       'userdata', now,...
       'enable','off',...
       'tag', 'arrplot_type_pulldownmenu');
   end
   end
end
feval(callfcn, 'status', 'Done.');
%
%End of file
