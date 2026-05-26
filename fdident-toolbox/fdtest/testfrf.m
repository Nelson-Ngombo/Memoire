%TESTFRF Test frf calls to objects

H11=10^(11/20)*ones(5,1);
H12=10^(12/20)*ones(5,1); %FRF from I1 to O2
H21=10^(21/20)*ones(5,1);
H22=10^(22/20)*ones(5,1);
v11=1; v12=2; v21=3; v22=4;
vc={v11,v12;v21,v22};
fv=[1:5]';
%First type (frf definition)
H1=fiddata('frf',{H11,H12;H21,H22},fv,vc)
plot(H1{[1,3],1},'&'), xlabel(sprintf('O%.0f-I%.0f',1,1)); shg
plot(H1{[2,3],1},'&'), xlabel(sprintf('O%.0f-I%.0f',2,1)); shg
plot(H1{[1,4],2},'&'), xlabel(sprintf('O%.0f-I%.0f',1,2)); shg
plot(H1{[2,4],2},'&'), xlabel(sprintf('O%.0f-I%.0f',2,2)); shg
%return
%
[H,freq,var]=frf(H1)
%Frequencies may differ:
H1=fiddata('frf',{H11,H12;[H21;1.1*H21(1)],[H22;1.1*H22(1)]},{fv,fv;[1:5,5.1]',[1:6]'})
plot(H1{[1,3],1},'&'), xlabel(sprintf('O%.0f-I%.0f',1,1)); shg
plot(H1{[2,3],1},'&'), xlabel(sprintf('O%.0f-I%.0f',2,1)); shg
plot(H1{[1,4],2},'&'), xlabel(sprintf('O%.0f-I%.0f',1,2)); shg
%plot(H1{[2,4],2},'&'), xlabel(sprintf('O%.0f-I%.0f',2,2)); shg
%save matlab H1
[H,freq,var]=frf(H1)
%
%Second type (with merge)
Hobj=[];
for ii=1:2
  for oi=1:2
    H1=fiddata(eval(sprintf('H%.0f%.0f',ii,oi)),ones(5,1),fv,...
      eval(sprintf('v%.0f%.0f',oi,ii)),[],[],...
      sprintf('o%.0f',oi),sprintf('i%.0f',ii));
    Hobj=merge(Hobj,H1);
  end
end
Hobj
[H2,freq2,var2]=frf(Hobj)
%
%Full MIMO
Hobj=[];
H1=fiddata({H11+H21;H12+H22},{ones(5,1);ones(5,1)},fv);
H1.ReferenceData={ones(5,1);ones(5,1)};
Hobj=merge(Hobj,H1);
H1=fiddata({H11-H21;H12-H22},{ones(5,1);-ones(5,1)},fv);
H1.ReferenceData={ones(5,1);-ones(5,1)};
Hobj=merge(Hobj,H1);
Hobj.groups_fullmimo={[1,2]};
[H2m,freq2m,var2m]=frf(Hobj)
[[H11,H21;H12,H22],zeros(10,1),[H2m{1,1},H2m{1,2};H2m{2,1},H2m{2,2}]]
if any(any(abs([H11,H21;H12,H22]-[H2m{1,1},H2m{1,2};H2m{2,1},H2m{2,2}])>1e-15))
  error('frf is not OK')
end
%
%Call MIMO tests from fdtestm
if exist('test_mimo_frf'), test_mimo_frf; end
%
disp('frf has been tested and is OK')
%End of testfrf