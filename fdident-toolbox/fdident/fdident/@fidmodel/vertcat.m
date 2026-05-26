function sys = vertcat(varargin)
%VERTCAT  Vertical concatenation of fidmodel objects.
%
%   SYS = VERTCAT(SYS1,SYS2,...) performs the concatenation 
%   operation
%         SYS = [SYS1 ; SYS2 ; ...]
% 
%   This amounts to appending the outputs of the models 
%   SYS1, SYS2,... and feeding all these models with the 
%   same input vector.
% 
%   See also HORZCAT, STACK, HELP(FIDMODEL)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Dec-1999

% Effect on other properties
% UserData and Notes are deleted

disp('Not yet ready')
error('Vertical concatenation by output channels - are you sure you want to do this?')
