%TESTC2D

disp('Test of c2d')
if exist('ss.m')
  m=fidmodel('s',1,[1,1]);
  mtf=tf(1,[1,1]); mtf2m=fidmodel(mtf);
  if any(diff(m,mtf2m)), diff(m,mtf2m), error('Models differ'), end
  disp('Created CT models are the same')
  %
  md=c2d(m,1); mdz=md; set(mdz,'variable','z^-1');
  mdtf=c2d(mtf,1); mdtf2m=fidmodel(mdtf);
  if any(diff(md,mdtf2m)), diff(md,mdtf2m), error('Models differ'), end
  disp('Converted DT models are the same')
  %
  mc=d2c(md);
  if abs(mc.num-1)<=eps, mc.num=1; end
  mctf=d2c(mdtf); mctf2m=fidmodel(mctf);
  if abs(mctf2m.num-1)<=eps, mctf2m.num=1; end
  if any(diff(mc,mctf2m)), diff(mc,mctf2m), error('Models differ'), end
  disp('Converted CT models are the same')
end