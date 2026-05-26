%SHFSCRUN Run showfscales for different data

showfscales('robotarm(f)')
fprintf('Press a key to continue'), pause, disp(' ')
showfscales('bandpass(bandpass)')
fprintf('Press a key to continue'), pause, disp(' ')
showfscales('lowpass(lowpass_exp1)')
fprintf('Press a key to continue'), pause, disp(' ')
showfscales('lowpass(lowpass_wideband)')
fprintf('Press a key to continue'), pause, disp(' ')
showfscales('emachine(emachine)',3,2,[],[],logspace(0,3,100))
fprintf('Press a key to continue'), pause, disp(' ')
