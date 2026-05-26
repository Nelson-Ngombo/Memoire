function htestfidm
%HTESTFIDM Test fidmodel plots

disp('File htestfidm: test plots of fidmodel objects')

optall='+-=&#nsm*craSNd@12';
%optall='d';
disp('Prepare models...')
load rarmmods
m2=m; m2.covariance=[];
m3=m2; m3.data=[];
m4=m; set(m4,'data',[]);
m5=m; m5.data.SiSoVariance=[];
m6=m5; data.covariance=[];
mm=stack(1,m,m2,m3,m4,m5,m6,fidmodel);
%mm=fidmodel;
%set(gcf,'NumberTitle','off')
clf, figure(gcf), drawnow
disp('Begin cycles...')
for ii=1:length(mm)
  fprintf('Plots of model #%.0f of %.0f\n',ii,length(mm))
  mmii=mm(:,:,ii);
  if ~isempty(mmii.num), mmi=mm(:,:,ii); else mmi=robotarm_3models; end
  if length(mmi)>1, modtype='Model array';
  else modtype='Model';
  end
  mmi1=mmi(:,:,1);
  if isempty(mmi1.data), modtype=[modtype,' with no Fourier data'];
  else modtype=[modtype,' with Fourier data'];
      mmi1=mmi(:,:,1);
      if isempty(mmi1.data.SiSoVariance), modtype=[modtype,', no variance'];
    else modtype=[modtype,' + variance'];
    end
  end
  mmi1=mmi(:,:,1);
  if isempty(mmi1.covariance), modtype=[modtype,', no covariance'];
  else modtype=[modtype,', covariance given'];
  end
  disp(modtype)
  for opt=optall
      mmi1=mmi(:,:,1);
    if ~(isempty(mmi1.data)&any(opt=='&#')) %otherwise cannot plot
      plot(mmi,opt)
      title([modtype,', opt=''',opt,''''])
      drawnow
      fprintf(['opt = ''',opt,''', press a key to continue...']), pause, disp(' ')
    end
  end %for opt
end %for ii
cloud(m)
%
%MIMO
MatlV=version;
if str2num(MatlV(1:3))>=6.5
  fprintf('\nNow try a few MIMO plots...\n')
  mm1=fidmodel('s',{[1,2],3;[3,4,5],[4,14,144]},{[6,7,8]});
  mm2=fidmodel('s',{[1,2],3;[3,4,5],4},{[6,7,8],[5,6];[9,10,11],[5,6,7,8]});
  pmtest=0;
  for mm={mm1} %,mm2}
    warning('does not work for TFs')
    pmtest=pmtest+1;
    mm=mm{1};
    for msc='+-=m*craSNd@'
      plot(mm,'ch',{'1/2','','2/2'},msc), drawnow
      fprintf(['msc = ''',msc,''', press a key to continue...']), pause, disp(' ')
      plot(mm,'ch',{'1/2','2/2'},msc), drawnow
      fprintf(['msc = ''',msc,''', press a key to continue...']), pause, disp(' ')
      plot(mm,msc), drawnow
      fprintf(['msc = ''',msc,''', press a key to continue...']), pause, disp(' ')
    end
  end
end

close

%End of htestfidm