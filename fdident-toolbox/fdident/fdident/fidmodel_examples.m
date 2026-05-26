%FIDMODEL_EXAMPLES

%SISO, one experiment:
ms=fidmodel('s',[1,2],[3,4,5]);
mz=fidmodel('z',[1,2],[3,4,5],0,1e3);

load rarmmods
m.data
m.fitinfo