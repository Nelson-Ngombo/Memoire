function advice(m)
%Give advice concerning model

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-May-2005

fdtool
ho=gcbo; lm=size(m,4);
subs={':'  ':'  [1:min(lm,2)]}; strucref.type='()'; strucref.subs=subs;
m1=subsref(m,strucref);
dbs=dbstack;
if (length(dbs)>=2)&any(findstr(dbs(2).name,'caem'))
elseif isempty(gcbo)|~strcmp(get(gcbo,'tag'),'ui_advice-menu_item')
elseif 0
  hsel=findall(0,'type','figure','tag','select_main');
  try
    if isempty(hsel), fdtool('callback','sme'), end
    fdtool('callback','guidtawr','select_main', 'DATA_INPUT','direct',m(:,:,1).data)
  catch
    fdtool('load_an_arrow', 7, m(:,:,1).data)
    if isempty(hsel), fdtool('callback','sme'), end
  end
  fdtool('callback','guidtawr','select_main', 'DATA_INPUT','direct',get(m1,'data'))
  fdtool('callback','guidtawr','select_main', 'FINAL_DATA','direct',{m1})
  fdtool('callback','sme','update_plot','select_main')
  fdtool('callback','sme','setbutton','enable_done')
end
%fdtool('callback','helpmgr','ui_help_autoorder_demo','sme', 'select_menu_help_autoorder_demo')
fdtool('callback','order_advice',m1);
figure(findall(0,'type','figure','tag','idbeard_tells_his_opinion'))
