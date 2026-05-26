function prepzoom(axh,typestr,models)
%PREPZOOM Prepare wide/tall plot for zoom from standard plot
%       (Make axis limits larger than actually seen plot)
%
%       Input arguments:
%       axh - handle of axes
%       typestr - type of plot(tf' or 'poles/zeros')
%       models - fidmodel object(s) to plot (only first model is used)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-Jun-2001

if nargin<2, typestr=''; end
ax0=[get(axh,'xlim'),get(axh,'ylim')]; ax=ax0;
hc=get(axh,'children');
for ii=1:length(hc)
  if strcmp(get(hc(ii),'type'),'line')&~strcmp(get(hc(ii),'tag'),'axis')&...
      ~strcmp(get(hc(ii),'tag'),'stablimit')
    x=get(hc(ii),'xdata'); y=get(hc(ii),'ydata');
    if ~(strcmp(get(hc(ii),'Marker'),'.')&(length(y)==2))
      ax0(1)=min([ax0(1);x(:)]);
      ax0(2)=max([ax0(2);x(:)]);
      ax0(3)=min([ax0(3);y(:)]);
      ax0(4)=max([ax0(4);y(:)]);
    end
  end
end %for ii
if findstr(lower(typestr),'tf')
  if iscell(models), mod1=models{1};
  else mod1=models(:,:,1);
  end
  v=mod1.variable;
  if findstr(v,'z')
    if strcmp(get(axh,'xscale'),'linear'), ax0(1)=min(ax0(1),0); end
    %ax0(2)=max(ax0(2),mod1.fs/2);
  elseif findstr(v,'s')
    if strcmp(get(axh,'xscale'),'linear'), ax0(1)=min(ax0(1),0); end
  end
elseif any(findstr(lower(typestr),'poles/zeros'))
  %Make sure that the origo is included
  ax0(1)=min(ax0(1),0); ax0(3)=min(ax0(3),0);
  ax0(2)=max(ax0(2),0); ax0(4)=max(ax0(4),0);
end
if ~isequal(ax,ax0)
  if strcmp(get(axh,'xscale'),'linear')
    ax0(1)=ax0(1)-0.05*(ax0(2)-ax0(1));
    ax0(2)=ax0(2)+0.05*(ax0(2)-ax0(1));
  elseif strcmp(get(axh,'xscale'),'log')
    ax0(1)=ax0(1)/(ax0(2)/ax0(1))^0.05;
    ax0(2)=ax0(2)*(ax0(2)/ax0(1))^0.05;
  else
    error('Programming error')
  end
  if strcmp(get(axh,'yscale'),'linear')
    %  ax0(3)=ax0(3)-0.05*(ax0(4)-ax0(3));
    %  ax0(4)=ax0(4)+0.05*(ax0(4)-ax0(3));
  else
    %  %Keep triangles at the bottom
    %  %ax0(3)=ax0(3)/(ax0(4)/ax0(3))^0.05;
    %  ax0(4)=ax0(4)*(ax0(4)/ax0(4))^0.05;
  end
end
set(axh,'xlim',real(ax0(1:2))), set(axh,'ylim',real(ax0(3:4)))
%hf=get(axh,'parent'); zoom(hf,'reset')
%set(axh,'xlim',ax(1:2)), set(axh,'ylim',ax(3:4))
%set unfortunately reset stored limits. Let us remake them.
set(get(axh,'Zlabel'),'UserData',ax0);
%
p=get(axh,'position');
if p(2)==0.11
  %Make place for power of 10 below x axis
  pmod=0.04;
  p(2)=p(2)+pmod; p(4)=p(4)-pmod; set(axh,'position',p)
end
%