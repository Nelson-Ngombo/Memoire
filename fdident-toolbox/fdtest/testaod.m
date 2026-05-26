function testaod(numbers)
%TESTAOD  Test Autoorder Demos from command line
%
%        Usage: testaod or e.g. testaod(5), testaod([3:5])

clear autoorder_demo %remove function and its persistent variables
fdident preload
if nargin==0, numbers=[]; end
runhist testopenaudemos %open window
hfig=findall(0,'tag','AutoModelSelectionDemoFig');
if length(hfig)~=1, error('Auto demo figure not properly found'), end
hidf=''; %I.D. Beard figure
hpmn=findobj(hfig,'style','popupmenu');
m=get(hpmn,'string');
hst=findobj(hfig,'tag','PushbuttonStart');
hcl=findobj(hfig,'tag','PushbuttonClose');
hrcl= findall(0, 'tag', 'fdtool_recorder_menu_close');
eval(get(hrcl,'callback'))
bypass=[];
bypass=[8,9,11];
if isempty(numbers)
  numbers=[1:length(m)-1];
  for ii=1:length(bypass), ind=find(numbers==bypass(ii)); numbers(ind)=[]; end
else
  ind=find(numbers>length(m)-1);
  if ~isempty(ind), numbers(ind)=[]; end
end
for ii=numbers+1
  set(hpmn,'value',ii)
  pmcb=get(hpmn,'callback');
  ind=findstr(pmcb,'gcbo'); if ~isempty(ind), pmcb(ind+[0:3])='hpmn'; end
  fprintf(['Demonstration %.0f of %.0f, ',m{ii},'\n'],ii-1,length(m)-1)
  eval(pmcb)
  stcb=get(hst,'callback');
  eval(stcb)
  if isempty(hidf)
    hidf=findall(0,'type','figure','tag','idbeard_tells_his_opinion');
  end
  eval(get(findall(hidf,'tag','explain_1_axes'),'buttondownfcn'))
  h=findall(hidf,'tag','explain_2_axes');
  if ~isempty(h)&strcmp(get(h,'visible'),'on'), eval(get(h,'buttondownfcn')), end
  eval(get(findall(hidf,'tag','I.D.Beard image'),'buttondownfcn'))
  eval(get(findall(hidf,'tag','explain_1_axes'),'buttondownfcn'))
  eval(get(findall(hidf,'tag','explain_copy'),'buttondownfcn'))
end
%
%End of TESTAOD