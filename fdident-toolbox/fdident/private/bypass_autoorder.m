function bypass_autoorder
%BYPASS_AUTOORDER Make secret setting to bypass lengthy autoorder (for development)
global use_autoorder_results
global use_autoorder_results_q
load('rarmmods','robotarm_6models');
use_autoorder_results={robotarm_6models(:,:,3),robotarm_6models(:,:,1),robotarm_6models(:,:,2)};
load('autoorder_data','z_domain3_orthopol');
use_autoorder_results_q={z_domain3_orthopol(:,:,3),z_domain3_orthopol(:,:,1),z_domain3_orthopol(:,:,2)};
