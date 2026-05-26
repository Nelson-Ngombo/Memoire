function [varargout]=plotm(pdat,varargin)

MaxPlotY=3;
MaxPlotX=3;

redraw=0;
possiblefield={'xscale','freqdim','parent','flim','FRF','freq_dta_points','numb_freq_points','allfreq','plot_TF','plotmodel','plotdata','modelplot','dataplot'};
defaultfield={'lin'    ,'Hz'     ,'figure',[]    ,[]   ,[]               ,100               ,[]       ,[]       ,1          ,1         ,1          ,1};
changedfield=[1         ,1        ,1       ,1     ,1    ,1                ,1                 ,1        ,1       ,1          ,1         ,1          ,1];
% 0- non-changed
if exist('varargin','var')
   for ii=1:length(varargin)
      if ischar(varargin{ii})
         if ii<length(varargin)
            ID=strcmp(varargin{ii},possiblefield);
            if any(ID), eval(sprintf('%s=varargin{ii+1};',possiblefield{ID})); end
         end
         if strcmpi(varargin{ii},'redraw')
            redraw=1;
         end
         if length(varargin{ii})==1
            plotmod=varargin{ii};
         end
      elseif isobject(varargin{ii})&isempty(pdat.data);
         if strcmpi(class(varargin{ii}),'fiddata')
            pdat.data=varargin{ii};
         end
      elseif iscell(varargin{ii})
         plot_TF=varargin{ii};
      end
   end %for vararagin
end %exist('varargin')

if isempty(pdat.num) && ~length(varargin)
    if isempty(pdat.data)
        parent=figure('renderer','zbuffer','position',[5 35 800 600],'toolbar','none','Tag','ELiSM','Userdata','ELiSM');
        if nargout, varargout{1}=parent; end
        return; 
    elseif strcmpi(class(pdat.data),'fidmodel')
        if get(pdat.data,'ChNumber')==0
            parent=figure('renderer','zbuffer','position',[5 35 800 600],'toolbar','none','Tag','ELiSM','Userdata','ELiSM');
            return; 
        end
    end
end

if ~exist('parent','var')
   parent=figure('renderer','zbuffer','position',[5 35 800 600],'toolbar','none','Tag','ELiSM','Userdata','ELiSM');
else
   if ~any(allchild(0)==parent)
      parent=figure('renderer','zbuffer','position',[5 35 800 600],'toolbar','none','Tag','ELiSM','Userdata','ELiSM');
      set(parent,'renderer','zbuffer');
   end
end

domain=pdat.variable;
if isempty(pdat.num), modelpres=0;
else 
   sX=get(pdat,'InputChNumber');
   sY=get(pdat,'OutputChNumber');
   modelpres=1; 
end
datapres=1;
if ~strcmpi(class(pdat.data),'fiddata'), datapres=0; end
if ~get(pdat.data,'ChNumber'), datapres=0; end
if datapres
   sX=get(pdat.data,'InputChNumber');
   sY=get(pdat.data,'OutputChNumber');
end

if isfield(get(parent),'WindowStyle')
   if isempty(findstr(get(parent,'Tag'),'mimo_plotm'))
      ii=0;
      while ~isempty(findobj(get(0,'children'),'Type','figure','Tag',sprintf('mimo_plotm%d',ii)))
         ii=ii+1;
      end
      parenttag=sprintf('mimo_plotm%d',ii);
      set(parent,'tag',parenttag);
      
      txthu=axes('Position',[0.5,0.80,0.5,0.20],'parent',parent,'visible','off','Units','Normalized');
      txthucov=axes('Position',[0.5,0.80,0.5,0.20],'parent',parent,'visible','off','Units','Normalized');
      
      set(txthu,'units','pixels');
      pos=get(txthu,'Position');
      set(txthu,'units','normalized');
      p(4)=20; p(3)=80; p(2)=pos(2)+pos(4)-p(4); p(1)=pos(1)+pos(3)-p(3);
      propG=uicontrol('parent',parent,'position',p,'string','Visualization','Tag',sprintf('Visualization%d',ii),...
         'callback',sprintf('plotm_dialog(fidmodel,%d,%d,''%s'',%d,%d,%d,%d)',sY,sX,parenttag,MaxPlotY,MaxPlotX,modelpres,datapres));
      set(propG,'units','Normalized');
   end
   parenttag=get(parent,'tag');
   
   dataset=fdtool('callback','guidtard',parenttag,'PLOTM_DATA');
   for iv=1:length(possiblefield)
      if ~exist(possiblefield{iv},'var')
         if isfield(dataset,possiblefield{iv})
            eval(sprintf('%s=getfield(dataset,possiblefield{iv});',possiblefield{iv}));
            changedfield(iv)=0;
         else
            eval(sprintf('%s=defaultfield{iv};',possiblefield{iv}));
         end
      end
   end %for possiblefield
   if isempty(pdat.num) && isempty(pdat.data)
       plotm(dataset.pdat,varargin{:}); 
       return; 
   end
else
   plotm_onechannel(pdat,varargin{:});
   return;
end

if isempty(FRF) & datapres
   [FRF.HH,FRF.fr]=frf(pdat.data);
else
%    FRF.HH=cell(sY,sX);
%    FRF.fr=cell(sY,sX);
end

if strcmpi('xscale','log') & ~flim(1), flim=[]; end
if isempty(flim)
   if datapres
      if isempty(allfreq)
         allfreq=[];
         for iy=1:size(FRF.fr,1)
            for ix=1:size(FRF.fr,2)
               allfreq=union(allfreq,FRF.fr{iy,ix});
            end
         end
      end      
      if isempty(flim), flim=[min(allfreq),max(allfreq)]; end
   elseif modelpres
      if strcmpi(domain,'s')
         zervect=[];
         denom=pdat.denom;
         if isnumeric(denom)
            polvect=roots(pdat.denom);
         else
            error('Non-numeric denominator');
         end
         for i0=1:sY
            for i1=1:sX
               zervect=[zervect;roots(pdat.num{i0,i1})];
            end
         end
         pzvect=[polvect;zervect];
         decad=.0001;
         if any(imag(pzvect)>0),
            if strcmpi('xscale','lin'), flim=[0,4*median(abs(imag(pzvect(find(imag(pzvect))))))];
            else flim=4*median(abs(imag(pzvect(find(imag(pzvect))))))*[decad,1]; end
         elseif ~isempty(pzvect)
            if strcmpi('xscale','lin'), flim=[0,4*median(abs(real(pzvect)))];
            else flim=4*median(abs(real(pzvect)))*[decad,1]; end
         else
            if strcmpi('xscale','lin'), flim=[0,1];
            else flim=[decad,1]; end
         end
%          pzvect(find(imag(pzvect)==0))=[];
%          if any(imag(pzvect)>0),
%             if strcmpi('xscale','lin'), flim=[0,4*median(imag(pzvect))];
%             else flim=4*median(imag(pzvect))*[decad,1]; end
%          elseif ~isempty(pzvect)
%             if strcmpi('xscale','lin'), flim=[0,4*median(abs(real(pzvect)))];
%             else flim=4*median(abs(real(pzvect)))*[decad,1]; end
%          else
%             if strcmpi('xscale','lin'), flim=[0,1];
%             else flim=[decad,1]; end
%          end
      else % z domain
         decad=.0001;
         if ~isempty(pdat.fs)
            if strcmpi('xscale','lin'), flim=[0,.5]*pdat.fs;;
            else flim=[decad,.5]*pdat.fs; end
         else
            if strcmpi('xscale','lin'), flim=[0,.5];
            else flim=[decad,.5]; end
         end
      end
   end

end

if isempty(freq_dta_points)
   if strcmpi(xscale,'lin'), freq_dta_points=linspace(flim(1),flim(2),numb_freq_points);
   else freq_dta_points=logspace(log10(flim(1)),log10(flim(2)),numb_freq_points); end
end

if iscell(plot_TF) && all(size(plot_TF)==[1 1]) && all(size(plot_TF{1,1})==[1 2])
   plotm_onechannel(pdat,varargin{:});
   return;
end

if isempty(plot_TF)
   plot_TF=plot_TF_gen(sX,sY,modelpres);
end

delete(findall(allchild(parent),'userdata','mimoaxes'));

[pY,pX]=size(plot_TF);
paY=0.12; paX=0.09;
tY=(1-paY-.1)/pY-paY*0.8; 
tX=(1-paX)/pX-paX*0.8;

if ~modelplot, pdatout=fidmodel; set(pdatout,'data',pdat.data);
elseif ~dataplot, pdatout=pdat; pdatout.data=[];
else, pdatout=pdat; end

for i1=1:pY
   for i2=1:pX
      if all(size(plot_TF{i1,i2})==[1 3])
         switch plot_TF{i1,i2}(3)
            case 1, plotm='e';
            case 2, plotm='p';
            otherwise, plotm='*';
         end
         if (~strcmpi(plotm,'p')) || (strcmpi(plotm,'p') & modelplot & modelpres)
            Hax=axes('position',[paX*i2 paY*(pY-i1+1)+.05 0 0]+...
               [(i2-1)*tX (pY-i1)*tY tX tY],'parent',parent,'visible','on','nextplot','add','userdata','mimoaxes');
            plotm_onechannel(pdatout,{[plot_TF{i1,i2}(1:end)]},plotm,'parent',Hax,'xscale',xscale,'freqdim',freqdim,'flim',flim,...
               'freq_dta_points',freq_dta_points,'FRF',FRF);
            set(Hax,'position',[paX*i2 paY*(pY-i1+1)+.05 0 0]+...
               [(i2-1)*tX (pY-i1)*tY tX tY]);
         end
      end
   end
end

data=struct;
for iv=1:length(possiblefield)
   data=setfield(data,possiblefield{iv},eval(possiblefield{iv}));
end
data.pdat=pdat;

fdtool('callback','guidtawr',parenttag,'PLOTM_DATA','direct',data);

if nargout
   varargout{1}=parent;
end
drawnow;

% end of function

function plot_TF=plot_TF_gen(sX,sY,modelpres)

for ii=1:min([sY,3])                                   % plot_TF generation
   for iii=1:min([sX,3])
      plot_TF{ii,iii}=[ii,iii,0];
   end
end
   if all([sX sY]==[1 4])
      plot_TF{1,1}=[1 1 0];
      plot_TF{1,2}=[2 1 0];
      plot_TF{2,1}=[3 1 0];
      plot_TF{2,2}=[4 1 0];
      plot_TF{3,1}=[1 1 2];
      plot_TF{3,2}=[1 1 1];
   elseif sY==1 && sX>1
      for ii=1:min([3 size(plot_TF,2)])
         plot_TF{2,ii}=[1 ii 1];
      end
   elseif all([sX sY]==[1 1])
      plot_TF{1,1}=[1 1 0];
      plot_TF{2,1}=[1 1 1];
      if modelpres
         plot_TF{1,2}=[1 1 2];
      end
      plot_TF{2,2}=[0 0 0];
   elseif all([sX sY]==[1 2])
      plot_TF{1,1}=[1 1 0];
      plot_TF{2,1}=[1 1 1];
      plot_TF{1,2}=[2 1 0];
      plot_TF{2,2}=[2 1 1];
      if modelpres
         plot_TF{3,1}=[1 1 2];
         plot_TF{3,1}=[2 1 2];
      end
   elseif sY<3
      if modelpres
         plot_TF{3,2}=[1 1 2];
      else
         plot_TF{3,2}=[1 2 1];
      end
      plot_TF{3,1}=[1 1 1];
   end
