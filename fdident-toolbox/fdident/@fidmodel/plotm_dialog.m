function plotm_dialog(pdat,p1,p2,p3,p4,p5,p6,p7,p8,p9);

extendstr='_dialog';

if isnumeric(p1)
   sY=p1; sX=p2;
   parenttag=p3; myfigtag=[parenttag,extendstr];
   maxY=p4; maxX=p5;
   modelpres=p6; datapres=p7;

   
   c2=fdtool('callback','guidtard',parenttag,'PLOTM_DATA');
   [cuY,cuX]=size(c2.plot_TF);
   plot_TF=cell(maxY,maxX);
   for iy=1:maxY
      for ix=1:maxX
         plot_TF{iy,ix}=[1 1 0];
      end
   end
   plot_TF(1:cuY,1:cuX)=c2.plot_TF;
   
   if isempty(findall(allchild(0),'Tag',parenttag)), return; end;
   if ~isempty(findall(allchild(0),'Tag',myfigtag)), return; end;
   
   xcmb=80; ycmb=20; gapfr=8;
   xfro=xcmb+2*gapfr; yfro=ycmb*2+3*gapfr; 
   yoth=150; xoth=400; gapb=10; 
   xbut=66; ybut=23;
   xfr1=110; xfr2=150; xfr3=100;
   posfig_w=[10 50 max([2*gapb+gapb*(1+maxX)+xfro*maxX,5*gapb+xfr1+xfr2+xfr3+xbut]) 2*gapb+gapb*(1+maxY)+yfro*maxY];
   posfig=posfig_w+[0 0 0 gapb+yoth];

   
   ytxt=18;
   myfig=figure('Position',posfig,'Tag',myfigtag,'Resize','off','Menubar','None');

   str_combo_pth=cell(sX*sY+1,1); str_combo_pth{sX*sY+1,1}='None';
   for ii=1:sX*sY
      str_combo_pth{ii}=sprintf('G(%d,%d)',ceil(ii/sX),mod(ii-1,sX)+1);
   end
   str_combo_tft={'Magnitude';'Phase'}; 
   if modelpres 
      str_combo_tft{3,1}='Poles-zeros'; 
      if datapres, str_combo_tft{2,1}='Phase error'; end
   end
   
   strcellY=cell(maxY,1);
   for ii=1:maxY, strcellY{ii}=sprintf('%d',ii); end
   strcellX=cell(maxX,1);
   for ii=1:maxX, strcellX{ii}=sprintf('%d',ii); end

   NOFRQ=sort(unique([50 100 200 300 400 500 1000 2000 3000 c2.numb_freq_points length(c2.allfreq)]));
   val_NOFRQ=find(c2.numb_freq_points==NOFRQ);
   cell_NOFRQ=[];
   for ifr=1:length(NOFRQ), cell_NOFRQ{ifr}=sprintf('%d',NOFRQ(ifr)); end
   
   posbfr=[gapb posfig(4)-gapb-yoth*0.68 xfr1 yoth*0.68];
   bfr=uicontrol('Parent',myfig,'Position',posbfr,'Style','Frame','Tag','Frame1');
   posnox_txt=[posbfr(1)+gapfr posbfr(2)+posbfr(4)-gapfr-ytxt 80 ytxt];
   nox_txt=uicontrol('Parent',myfig,'Position',posnox_txt,'Style','Text',...
      'String','Number of rows:','HorizontalAlignment','Left','Tag','no_of_row_txt');
   posnox_cmb=[posnox_txt(1)+gapfr posnox_txt(2)-ycmb 80 ycmb];
   nox_cmb=uicontrol('Parent',myfig,'Position',posnox_cmb,'Style','Popupmenu','String',strcellY,'Value',cuY,...
      'Tag','no_of_row_cb','Callback',sprintf('plotm_dialog(fidmodel,''ui_rowcol_cb'',''no_of_row_cb'',''%s'');',myfigtag));
   posnoy_txt=[posnox_txt(1) posnox_cmb(2)-gapfr-ytxt 100 ytxt];
   noy_txt=uicontrol('Parent',myfig,'Position',posnoy_txt,'Style','Text',...
      'String','Number of columns:','HorizontalAlignment','Left','Tag','no_of_col_txt');
   posnoy_cmb=[posnoy_txt(1)+gapfr posnoy_txt(2)-ycmb 80 ycmb];
   noy_cmb=uicontrol('Parent',myfig,'Position',posnoy_cmb,'Style','Popupmenu','String',strcellX,'Value',cuX,...
      'Tag','no_of_col_cb','Callback',sprintf('plotm_dialog(fidmodel,''ui_rowcol_cb'',''no_of_col_cb'',''%s'');',myfigtag));
   
   posffr=[posbfr(1)+posbfr(3)+gapb posfig(4)-gapb-yoth xfr2 yoth];
   ffr=uicontrol('Parent',myfig,'Position',posffr,'Style','Frame','Tag','Frame2');
   posnofrqp_txt=[posffr(1)+gapfr posbfr(2)+posbfr(4)-gapfr-ytxt 140 ytxt];
   nofrqp_txt=uicontrol('Parent',myfig,'Position',posnofrqp_txt,'Style','Text',...
      'String','Number of frequency points:','HorizontalAlignment','Left','Tag','nofreq_txt');
   posnofrqp_cmb=[posnofrqp_txt(1)+gapfr posnofrqp_txt(2)-ycmb 80 ycmb];
   nofrqp_cmb=uicontrol('Parent',myfig,'Position',posnofrqp_cmb,'Style','Popupmenu',...
      'String',cell_NOFRQ,'Value',val_NOFRQ,'Tag','nofreq_cb');
   poslin_txt=[posnofrqp_txt(1) posnofrqp_cmb(2)-gapfr-ytxt 140 ytxt];
   lin_txt=uicontrol('Parent',myfig,'Position',poslin_txt,'Style','Text',...
      'String','Scale of frequency:','HorizontalAlignment','Left');
   poslin_cmb=[poslin_txt(1)+gapfr poslin_txt(2)-ycmb 80 ycmb];
   lin_cmb=uicontrol('Parent',myfig,'Position',poslin_cmb,'Style','Popupmenu',...
      'String',{'Linear','Logarithmic'},'Value',strcmp(c2.xscale,'log')+1);
   posdimfrq_txt=[posnofrqp_txt(1) poslin_cmb(2)-gapfr-ytxt 140 ytxt];
   dimfrq_txt=uicontrol('Parent',myfig,'Position',posdimfrq_txt,'Style','Text',...
      'String','Frequency dimension:','HorizontalAlignment','Left');
   posdimfrq_cmb=[posdimfrq_txt(1)+gapfr posdimfrq_txt(2)-ycmb 80 ycmb];
   dimfrq_cmb=uicontrol('Parent',myfig,'Position',posdimfrq_cmb,'Style','Popupmenu',...
      'String',{'Hz','Radian/sec'},'Value',-(strcmp(c2.freqdim,'frequency')+strcmp(c2.freqdim,'Hz'))+2);

   str_var={'None','SNR','NSNR','Error','Variance','Stds','Residual','Bounds'};
   posexfr=[posffr(1)+posffr(3)+gapb posfig(4)-gapb-90 xfr3 90];
   exfr=uicontrol('Parent',myfig,'Position',posexfr,'Style','Frame');
   posmodel_cb=[posexfr(1)+gapfr posbfr(2)+posbfr(4)-gapfr-ytxt 80 ytxt];
   model_cb=uicontrol('Parent',myfig,'Position',posmodel_cb,'Style','CheckBox',...
      'String','Plot model','Tag','model_cb','Callback',...
      sprintf('plotm_dialog(fidmodel,''ui_moddta_cb'',''model_cb'',''%s'');',myfigtag));
   posdata_cb=[posmodel_cb(1) posmodel_cb(2)-ytxt 80 ycmb];
   data_cb=uicontrol('Parent',myfig,'Position',posdata_cb,'Style','CheckBox',...
      'String','Plot data','Tag','data_cb','Callback',...
      sprintf('plotm_dialog(fidmodel,''ui_moddta_cb'',''data_cb'',''%s'');',myfigtag));
   posvar_txt=[posmodel_cb(1) posdata_cb(2)-gapfr-ytxt 80 ytxt];
   var_txt=uicontrol('Parent',myfig,'Position',posvar_txt,'Style','Popupmenu',...
      'String',str_var,'HorizontalAlignment','Left');

   if ~modelpres, set(model_cb,'Enable','off');
   else set(model_cb,'Value',c2.modelplot); end
   if ~datapres, set(data_cb,'Enable','off');
   else set(data_cb,'Value',c2.dataplot); end
   
   posOK_bt=[posfig(3)-gapb-xbut posfig(4)-gapb-ybut xbut ybut];
   OK_bt=uicontrol('Parent',myfig,'Position',posOK_bt,'Style','PushButton',...
      'String','OK','Callback',sprintf('plotm_dialog(fidmodel,''ui_ok_bt'','''',''%s'');',myfigtag));
   posCancel_bt=[posOK_bt(1) posOK_bt(2)-gapb-ybut xbut ybut];
   Cancel_bt=uicontrol('Parent',myfig,'Position',posCancel_bt,'Style','PushButton',...
      'String','Cancel','Callback',sprintf('plotm_dialog(fidmodel,''ui_cancel_bt'','''',''%s'');',myfigtag));
   
   variables=who; c=struct; nocalc={'p1','p2','p3','p4','p5','variables','c','iv','iy','ix','fd'};
   for iv=1:length(variables)
      if ~any(strcmpi(variables{iv},nocalc))
         eval(sprintf('c=setfield(c,''%s'',eval(variables{iv}));',variables{iv}));
      end
   end
   fdtool('callback','guidtawr',myfigtag,'PLOTM_DATA','direct',c);
   plotm_dialog(fidmodel,'ui_rowcol_cb','',myfigtag);
   
elseif ischar(p1)
   c=fdtool('callback','guidtard',p3,'PLOTM_DATA');
   fd=fieldnames(c);
   for iv=1:length(fd)
      eval(sprintf('%s=getfield(c,''%s'');',fd{iv},fd{iv}));
   end

   
   if strcmp(p1,'ui_rowcol_cb')
      if strcmp(p2,'no_of_row_cb')
         cuY=get(findall(myfig,'Tag',p2),'Value');
      elseif strcmp(p2,'no_of_col_cb')
         cuX=get(findall(myfig,'Tag',p2),'Value');
      end
      
      xfr=(posfig_w(3)-gapb*3)/cuX-gapb;
      yfr=(posfig_w(4)-gapb*3)/cuY-gapb;
      gapfrx=(xfr-xfro)/2+gapfr;
      gapfry=(yfr-yfro)/2+gapfr;
      
      posbigframe=[gapb gapb posfig_w(3)-2*gapb posfig_w(4)-2*gapb];
      bigframe=uicontrol('Parent',myfig,'Position',posbigframe,'Style','Frame','Userdata','fig_model');
      combo_pth=cell(maxY,maxX); combo_tft=cell(maxY,maxX);
      for iy=cuY:-1:1
%          iy=cuY-iy_v;
         for ix=1:cuX
            posframe=[2*gapb+(ix-1)*(xfr+gapb) 2*gapb+(cuY-iy)*(yfr+gapb) xfr yfr];
            fr=uicontrol('Parent',myfig,'Position',posframe,'Style','Frame','Userdata','fig_model');
            poscombo=[posframe(1)+gapfrx posframe(2)+posframe(4)-gapfry-ycmb xcmb ycmb];
            combo_pth{iy,ix}=uicontrol('Parent',myfig,'Style','Popupmenu','Position',poscombo,'String',str_combo_pth,...
               'Tag',sprintf('combo_pth_%d_%d',iy,ix),'TooltipString','Path: G(output,input)',...
               'Callback',sprintf('plotm_dialog(fidmodel,''ui_pthtft_cmb'','''',''%s'');',myfigtag)...
               );
%                ,'Callback','plotm_dialog(fidmodel,''ui_pth_cb'');','Userdata','fig_model');
            poscombo=poscombo-[0 gapfr+ycmb 0 0];
            combo_tft{iy,ix}=uicontrol('Parent',myfig,'Style','Popupmenu','Position',poscombo,'String',str_combo_tft,...
               'Tag',sprintf('combo_tft_%d_%d',iy,ix),'Userdata','fig_model',...
                              'Callback',sprintf('plotm_dialog(fidmodel,''ui_pthtft_cmb'','''',''%s'');',myfigtag));
            if any(~plot_TF{iy,ix}(1:2)), 
               set(combo_pth{iy,ix},'Value',length(get(combo_pth{iy,ix},'String'))); 
            else
               set(combo_pth{iy,ix},'Value',sX*(plot_TF{iy,ix}(1)-1)+plot_TF{iy,ix}(2));
               set(combo_tft{iy,ix},'Value',plot_TF{iy,ix}(3)+1);
            end
         end
      end

   elseif strcmp(p1,'ui_moddta_cb')
      if get(findall(myfig,'Tag','data_cb'),'Value') || get(findall(myfig,'Tag','model_cb'),'Value')
         set(OK_bt,'Enable','on');
      else
         set(OK_bt,'Enable','off');
      end
   elseif strcmp(p1,'ui_cancel_bt')
      close(findall(0,'Tag',p3));
      return;
   elseif strcmp(p1,'ui_pthtft_cmb')
      for iy=1:cuY
         for ix=1:cuX
            pth_value=get(combo_pth{iy,ix},'Value');
            if pth_value~=length(get(combo_pth{iy,ix},'String'))
               plot_TF{iy,ix}=[floor((pth_value-1)/sX)+1 mod(pth_value-1,sX)+1 get(combo_tft{iy,ix},'Value')-1];
            else
               plot_TF{iy,ix}=[0 0 get(combo_tft{iy,ix},'Value')-1];
            end
         end
      end
         
      
   elseif strcmp(p1,'ui_ok_bt')
      c2=fdtool('callback','guidtard',parenttag,'PLOTM_DATA');

      if get(lin_cmb,'Value')==1, c2.xscale='linear';
      else c2.xscale='log'; end
      if get(dimfrq_cmb,'Value')==1, c2.freqdim='frequency';
      else c2.freqdim='radians'; end
      c2.freq_dta_points=[];
      c2.numb_freq_points=NOFRQ(get(nofrqp_cmb,'Value'));
      
      c2.plot_TF=plot_TF(1:cuY,1:cuX);
      if get(model_cb,'Value'), c2.modelplot=1; else c2.modelplot=0; end
      if get(data_cb,'Value'), c2.dataplot=1; else c2.dataplot=0; end
     
      parent=findall(allchild(0),'Tag',parenttag);
      if ~isempty(parent)
          fdtool('callback','guidtawr',parenttag,'PLOTM_DATA','direct',c2);
          parent=parent(1);
          plotm(fidmodel,'parent',parent);
      end
                  
      
      close(findall(0,'Tag',p3));
      return;
   end
   
   variables=who; c=struct; nocalc={'p1','p2','p3','p4','p5','variables','c','iv','iy','ix','fd'};
   for iv=1:length(variables)
      if ~any(strcmpi(variables{iv},nocalc))
         eval(sprintf('c=setfield(c,''%s'',eval(variables{iv}));',variables{iv}));
      end
   end
   fdtool('callback','guidtawr',myfigtag,'PLOTM_DATA','direct',c);
   
end
