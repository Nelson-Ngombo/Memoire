function fixlgtck(h,axv)
%FIXLGTCK Fix tickmarks in logarithmic plot
%
%       h = handle of the axes
%       axv = axis vector to be set
%
if nargin<1, h=[]; end
if isempty(h)
  ha=findobj(0,'type','axes');
  if isempty(ha), return
  else h=gca;
  end
end
hall=h;
for h=hall(:)'
  if ~ishandle(h)|~strcmp(get(h,'type'),'axes')
    error('h is not an axes handle')
  end
  if nargin<2, axv=[]; end
  %
  if strcmp(get(h,'xscale'),'log')
    set(h,'xtickmode','auto')
    if isempty(axv), axv=get(h,'xlim'); end
    if ~any(isnan(axv(1:2)))
      if axv(1)<=0 %nonpositive lower limit
        xmin=inf;
        hl=findobj(h,'type','line');
        for hli=hl(:)'
          xmin=min(xmin,min(get(hli,'xdata')));
        end
        axv(1)=max(axv(1),xmin);
      end
      xtick=10.^[ceil(log10(abs(axv(1))*(1-100*eps))):floor(log10(axv(2)*(1+100*eps)))];
      if length(xtick)==1
        axv(1)=xtick/10; axv(2)=xtick*10;
        for ii=1:length(h)
          set(h(ii),'xlim',axv(1:2))
        end
        xtick=[axv(1),xtick,axv(2)];   
      elseif length(xtick)>4
        xl=length(xtick); ind=1:floor(xl/5)+1:xl; xtick=xtick(ind);
      end
      if length(get(h(1),'xtick'))<length(xtick)
        for ii=1:length(h)
          set(h(ii),'xtick',xtick)
        end
      end
    end
  end
  %
  if strcmp(get(h,'yscale'),'log')
    if isempty(axv), axv=[get(h,'xlim'),get(h,'ylim')];
    elseif length(axv)==2, axv=[axv,get(h,'ylim')];
    end
    if length(axv)==4
      ytick=10.^[ceil(log10(axv(3)*(1-100*eps))):floor(log10(axv(4)*(1+100*eps)))];
      if length(ytick)==1
        axv(3)=ytick/10; axv(4)=ytick*10;
        for ii=1:length(h)
          set(h(ii),'ylim',axv(3:4))
        end
        ytick=[axv(3),ytick,axv(4)];   
      elseif length(ytick)>4
        yl=length(ytick); ind=1:floor(yl/5)+1:yl; ytick=ytick(ind);
      end
      if length(get(h(1),'ytick'))<length(ytick)
        for ii=1:length(h)
          set(h(ii),'ytick',ytick)
        end
      end
    end
  end
end %for h
%
%End of file