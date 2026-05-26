function errorcatch %catch error when main fig is overwritten

hmain=findall(0,'type','figure','tag','fdtool_main');
if ~isempty(hmain)&strcmp(get(hmain,'visible'),'on')
  hax=findall(hmain,'type','axes');
  if length(hax)>1, error('hax is not unique in main figure'), end
  if ~isempty(hax)
    hp=findall(hax,'type','patch');
    if length(hp)<18
      keyboard; %catch error of patches overwritten
    end
  end
end