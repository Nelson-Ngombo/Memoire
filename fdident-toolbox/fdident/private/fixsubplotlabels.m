function fixsubplotlabels(h)
%FIXSUBPLOTLABELS Fix vertical size of subplots in window with handle h

if nargin<1, h=[]; end
if isempty(h)
  hf=findobj('type','figure');
  if ~isempty(hf), h=gcf;
  else return
  end
end
%
if ~ishandle(h), error('h is not a handle'), end
if ~strcmp(get(h,'type'),'figure'), error('h is not a figure handle'), end
uf=get(h,'units');
if ~strcmp(get(h,'units'),'pixels')
  warning('figure units are not in pixels')
  return
end
pf=get(h,'position'); 
if (pf(4)>420)|(pf(4)<=0), return, end
%
ha=findobj(allchild(h),'flat','type','axes');
hl=[]; hu=[];
for hi=ha(:)'
  u=get(hi,'units');
  if strcmp(u,'normalized')
    pa=get(hi,'position');
    if all(abs(pa - [0.1300    0.1100    0.7750    0.3439]) < 0.0001)
      %this is a lower window
      hl=hi; pl=pa;
    elseif all(abs(pa - [0.1300    0.5811    0.7750    0.3439]) < 0.0001)
      %this is an upper window
      hu=hi; pu=pa;
    end
  else
    %nothing to do
  end
end %for hi
if ~isempty(hu)&~isempty(hl)
  r=(420/pf(4))^0.15;
  pum=pu(2)*r; m=pum-pu(2); pu(4)=pu(4)-m; pu(2)=pum;
  set(hu,'position',pu)
  pl(4)=pl(4)-m; set(hl,'position',pl)
end
%
%End of file