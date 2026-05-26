%TESTDECOUPLE
H11=10^(11/20)*ones(5,1);
H12=10^(12/20)*ones(5,1); %FRF from I1 to O2
H21=10^(21/20)*ones(5,1);
H22=10^(22/20)*ones(5,1);
v11=1; v12=2; v21=3; v22=4;
vc={v11,v12;v21,v22};
fv=[1:5]';
%Full MIMO
Hobj=[];
H1=fiddata({H11+H21;H12+H22},{ones(5,1);ones(5,1)},fv);
H1.ReferenceData={ones(5,1);ones(5,1)};
Hobj=merge(Hobj,H1);
H1=fiddata({H11-H21;H12-H22},{ones(5,1);-ones(5,1)},fv);
H1.ReferenceData={ones(5,1);-ones(5,1)};
Hobj=merge(Hobj,H1);
for ic=1:2
  if ic==1, Hobj.groups_fullmimo={[1,2]};
  elseif ic==2, Hobj=merge(Hobj,Hobj); 
  end
  Hobjdc=decouple(Hobj);
  if all(issingleref(Hobjdc))&~any(issingleref(Hobj))
  else error('Something wrong in decouple')
  end
end
disp('decouple has been tested and is OK')
%End of testdecouple