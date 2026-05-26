function fdobjwin(mode)
%FDOBJWIN  Open window which helps to generate fdident objects.
%
%       mode: time or frequency, the type of object and window

if nargin<1, mode=''; end
if isempty(mode), mode='time'; end
%
if any(mode=='f')|any(mode=='F'), init='init2';
else init='init1'; %time
end
fdtool('callback','compinp',init);
%
%End of fdobjwin
