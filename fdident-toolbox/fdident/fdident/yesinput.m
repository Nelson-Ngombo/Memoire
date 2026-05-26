function answer=yesinput(question,default,possib)
%YESINPUT 'intelligent' input with default and possible answers.
%
%       answer=YESINPUT(question,default,possib)
%
%       YESINPUT prompts for input from the keyboard, displaying the string
%       'question' and the default value of the answer.
%       If the answer is <Enter> or <Return>, the 'default' value is assigned.
%       The answer is checked for correctness.
%
%       Input arguments:
%       question = string to be displayed as a question
%       default = default value of the variable to be read in; the function
%           checks if this is a string or not, to decide the type of the
%           variable to be read in. If default is empty, this may not help,
%           in this case the type of possib will decide, otherwise string
%           answer is returned. The default answer will be automatically
%           accepted (that is, no key has to be pressed) if a global variable
%           is defined with the name  yesinpacceptdef  and the value 'yes'
%       possib = (optional) possibilities for the answer:
%           if the type of the desired answer is string, 'possib' may be either
%           a string array, where the rows contain the acceptable answers, or
%           a string containing the acceptable answers, separated by | ('or')
%           characters.
%           If a number is desired, 'possib' may be an 1x2 vector, containing
%           the lower and higher limits for the input:
%           possib(1)<=answer<=possib(2)
%           For incorrect answers, the question is repeated.
%
%       Output argument:
%       answer = accepted answer
%
%       Usage: answer=yesinput(question,default,possib);
%       Examples:
%          order=yesinput('Order of the filter',10,[0,12]);
%          color=yesinput('Color used on the plot','red','red|blue|green');
%
%       See also: INPUT.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 20-Sep-1997

yes=1; no=0;
global yesinpacceptdef
if exist('yesinpacceptdef')~=1, yesinpacceptdef=''; end
if nargin<2, error('Less than 2 input arguments'), end
if ~isstr(question), error('question is not a string'), end
if nargin==2, possib=''; end
%
if isempty(default)
  %In the current Matlab-implementations the empty string has
  %no string attribute, thus isstr cannot be used
  if (length(possib)>0)&~isstr(possib)
    stringinput=no; defstr=''; %number is requested
  else
    stringinput=yes; defstr=''; %string is requested
  end
else
  if isstr(default)
    %string is to be assigned
    stringinput=yes; defstr=default;
  else %number is to be read
    stringinput=no;
    if (rem(default,1)==0) & (abs(default)<1e5)
      defstr=sprintf('%.0f',default);
    elseif ~isfinite(default) %inf or NaN
      if ~isnan(default), defstr='inf'; else defstr='NaN'; end
    else
      defstr=sprintf('%.5g',default);
    end
  end
end
%defstr contains the string to be displayed as default value
%
accepted=0;
while accepted==0
  if strcmp(yesinpacceptdef,'yes') %do not stop at questions
    answerstr=defstr;
    fprintf(['\n ',question,' (',defstr,'): accepted\n'])
  else %normal mode
    vers=version; if vers(1)+0>='5'+0, fprintf('\n'), end %fix for change
    answerstr=input([question,' (',defstr,'): '],'s');
  end
  if isempty(answerstr), answerstr=defstr; end
  if stringinput==yes %string input
    if isempty(possib), %possibilities not given
      answer=answerstr; accepted=1;
      break
    else %possibilities given
      if isempty(answerstr), error('The answer is empty'), end
      orind=[0,find(possib=='|'),length(possib)+1];
      for i=1:length(orind)-1
        if strcmp(answerstr,possib(orind(i)+1:orind(i+1)-1))
          answer=answerstr; accepted=1;
        end
      end
    end
  else %number
    eval(['answer=[',answerstr,']; errorfree=1;'],'errorfree=0;')
    if errorfree==1 %only if successfully evaluated
      if isempty(possib)
        accepted=1;
      else
        if isempty(answer), error('The answer is empty'), end
        if length(possib)~=2, error('Possib is not an 1x2 vector'), end
        if ( all(possib(1)<=answer) | isnan(answer) | ~isfinite(possib(1)) )&...
                ( all(answer<=possib(2)) | ~isfinite(possib(2)) )
          accepted=1;
        end
      end %possib
    end %errorfree
  end
end %while
%%%%%%%%%%%%%%%%%%%%%%%% end of yesinput %%%%%%%%%%%%%%%%%%%%%%%%
