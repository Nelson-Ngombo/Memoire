function sys = horzcat(varargin)
%HORZCAT  Horizontal concatenation of fidmodel objects.
%
%   SYS = HORZCAT(SYS1,SYS2,...) performs the concatenation 
%   operation
%         SYS = [SYS1 , SYS2 , ...]
% 
%   This operation amounts to appending the inputs and 
%   adding the outputs of the models SYS1, SYS2,...
% 
%   See also VERTCAT, STACK, HELP(FIDMODEL).

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Sep-2002

% Effect on other properties
% UserData and Notes are deleted

disp('Not yet ready')
error(sprintf(['Horizontal (or vertical) concatenation by input (or output) channels\n  - are you sure ',...
  'you want to do this? Use stack instead, e.g. stack(1,m1,m2) .']))
