function htestgroups(objtype)
%HTESTGROUPS

echo on htestgroups
disp('HTESTGROUPS')
if nargin==0, objtype=''; end
disp(['HTESTGROUPS ',objtype])
if isempty(objtype)|strcmp(objtype,'fiddata')|strcmp(objtype,'tiddata')
else error(['objtype is not allowed as ''',objtype,''''])
end
if ~isempty('objtype'), objtypevect={objtype}; else objtypevect={'fiddata','tiddata'}; end
for objtype=objtypevect
  objtype=objtype{1};
  disp(['Test for object ''',objtype,''''])
  %
  if strcmp(objtype,'fiddata')
  %examples
  obj=fiddata({1,2,3,4,5},{6,7,8,9,10},1e3);
  obj.groups_Synchronized={[1:3]}
  obj.groups_Synchronized={{[1:2],'e(3)'}}
  grp=getexpnos(obj,'s(1)')
  obj.groups_Synchronized={'e(1:3)'} %(experiments)
  obj.groups_Synchronized={[1,3,5],'group1'}
  obj.groups_Delayed={{'group1','e(4)'},'delaygroup'}
  obj.groups
  addgroup(obj,'Groups_SamePower',{'d(1)','e(2)'},'Spgroup'), obj
  rmgroup(obj,'delaygroup'), obj
  rmgroup(obj,'p(1)'), obj
  obj.groups_Delayed={{'s(1)','e(4)'},'delaygroup'}
  obj.groups_Synchronized={[1,3],'group1';'e(4:5)','group2'}
  grp1=getexpnos(obj,'group1'), grp2=getexpnos(obj,'group2') %check experiment numbers
  obj.groups={}
  obj.synchronization='on'
  obj.synchronization='delayed'
  obj.synchronization='fullmimo'
  obj.synchronization='samepower'
  obj.synchronization='off'
  obj.synchronization=''
  end
  %
  obj=feval(objtype,{1,2,3,4,5},{6,7,8,9,10},1e3);
  obj.synchronization='on'
  obj.groups
  obj.synchronization='off'
  obj.groups
  obj.groups_delayed={[1,2],[3,4]}
  obj.groups
  %obj.groups_delayed={'d(1)','d{2}'}
  obj.groups_delayed={'e(1)','e(2)'}
  obj.groups
  obj.synchronization='on'
  obj.groups
  obj=feval(objtype,{1,2,3,4,5},{6,7,8,9,10},1e3);
  %
  if strcmp(objtype,'tiddata')
    load robotarm
    t=robotarm_5segm;
    addgroup(t,'groups_synchronized',[1,2]), t
    addgroup(t,'groups_synchronized',[3,4],'a'), t
    addgroup(t,'groups_fullmimo',{'s(1)',5},'fm'), t
    rmgroup(t,'a'), t
    addgroup(t,'groups_synchronized',[3,4],'a'), t
    rmgroup(t,'s(1)'), t
    get(t,'groups_synchronized')
    getexpnos(t,'s(1)')
    addgroup(t,'groups_synchronized',[1,2]), t
    grp=get(t,'groups_synchronized');
    if size(grp,1)~=2, error('Size of grp is not OK'), end
    addgroup(t,'groups_fullmimo','s(1)','fm2'), t
    rmgroup(t,'s(1)'), t
  end
  if strcmp(objtype,'fiddata')
    load robotarm
    f=robotarm_freqdata;
    addgroup(f,'groups_synchr',[1:4])
    addgroup(f,'groups_del',[5:10])
    f
    fv=varanal(f);
    if ~isequal(get(fv,'M'),[4,6])|~isequal(get(fv,'expnumber'),2)
      error('Varanal group test error')
    end
    get(fv)
  end
end %for objtype
