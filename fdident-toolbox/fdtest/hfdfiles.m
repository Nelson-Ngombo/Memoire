function fdident_files = hfdfiles(mode)
% HFDFILES Cell array of all FDIDENT files.
% Helper function for TFDFILES etc
% If mode = 'current', it lists all M-files in the current fdident directory.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Jun-1999, IK

if nargin<1, mode=''; end
if strcmp(mode,'current')
  fdident_loc=fwhich('fdident','dir','all');
  if size(fdident_loc,1)>1
    fdident_loc
    error('fdident toolbox multiple times on the path')
  end
  fdident_files=dir(fdident_loc);
else
  if exist('corrtest.m')
    fdident_files = {...
      'coh2var';
      'corrtest';
      'dfcalc';
      'dibs';
      'dits';
      'dibsimpr';
      'digitnum';
      'elis';
      'eliscost';
      'elisml';
      'elis2tha';
      'elisqa';
      'elistper';
      'elrpf2v';
      'elrpv2f';
      'expcov';
      'expfou';
      'exppar';
      'exptim';
      'expvar';
      'expvect';
      'fdcovpzp';
      'fdiddemo';
      'fidprops';
      'fnamanal';
      'gmean';
      'fidmprops';
      'impcov';
      'impfou';
      'imppar';
      'imptim';
      'impvar';
      'iterctrl';
      'lin2qlog';
      'loadasc';
      'loadvar';
      'log2qlog';
      'mlbs';
      'modifyfv';
      'msinclip';
      'msinprep';
      'optexcit';
      ['private',filesep,'orthopol'];
      ['private',filesep,'ortroots'];
      ['private',filesep,'orthpval'];
      ['private',filesep,'orthr2p'];
      ['private',filesep,'orthz'];
      'pairs';
      'plotelpz';
      'ploteltf';
      'rdueelis';
      'savevar';
      'simfou';
      'simtime';
      'stdpz';
      'stdtf';
      'stdtfm';
      'tfcalc';
      'tha2elis';
      'tidprops';
      'tim2fou';
      'usage';
      'varanal';
      'yesinput';
      'ywalk';
      ['private',filesep,'fixlgtck'];
      ['private',filesep,'getobjf'];
      ['private',filesep,'elisrmt'];
      ['private',filesep,'elisdrmt'];
      ['private',filesep,'elisfiti'];
      ['private',filesep,'optfscale']};
  else
    fdident_files = {...
      'coh2var';
      'dibs';
      'dibsimpr';
      'digitnum';
      'elis';
      'eliscost';
      'elisml';
      'elis2tha';
      'elisqa';
      'elistper';
      'elrpf2v';
      'elrpv2f';
      'expcov';
      'expfou';
      'exppar';
      'exptim';
      'expvar';
      'expvect';
      'fdcovpzp';
      'fdiddemo';
      'fnamanal';
      'gmean';
      'impcov';
      'impfou';
      'imppar';
      'imptim';
      'impvar';
      'iterctrl';
      'lin2qlog';
      'loadasc';
      'loadvar';
      'log2qlog';
      'mlbs';
      'modifyfv';
      'msinclip';
      'msinprep';
      'optexcit';
      'pairs';
      'plotelpz';
      'ploteltf';
      'rdueelis';
      'savevar';
      'simfou';
      'simtime';
      'stdpz';
      'stdtf';
      'stdtfm';
      'tfcalc';
      'tha2elis';
      'tim2fou';
      'varanal';
      'yesinput';
      'ywalk'};
  end
end
%End of hfdfiles
