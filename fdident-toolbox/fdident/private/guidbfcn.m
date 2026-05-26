function [msg, status]=guidbfcn(ID);
% GUIDEBFCN Gui Debug Function
% msg is the returned warning/error message
% status is 0 if OK


msg='';
switch ID
case 'OK' % test only
   status=0;
case 'Warning' % test only
   status=1; msg='Test Warning';
otherwise
   status=1;
   msg=['GUI DEBUG FCN not implemented for ID = ' ID];
   %warning(msg)
end
