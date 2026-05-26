function Answer=fdinpdlg(Prompt, Title, NumLines, DefAns, Possib)
%FDINPDLG Input dialog box. INPUTDLG, extended by checking against Possib
%  Answer = inputdlg(Prompt) creates a modal dialog box that returns
%  user input for multiple prompts in the cell array Answer.  Prompt
%  is a cell array containing the Prompt strings.
%
%  Answer = inputdlg(Prompt,Title) specifies the Title for the dialog.
%
%  Answer = inputdlg(Prompt,Title,LineNo) specifies the number of lines
%  for each answer in LineNo.  LineNo may be a constant value or a
%  vector having one element per Prompt.
%
%  Answer = inputdlg(Prompt,Title,LineNo,DefAns,Possib) specifies the default
%  answer to display for each Prompt.  DefAns must contain the same
%  number of elements as Prompt and must be a cell array.
%  Possib is a related cell array: {'answera' 'answerb'} with possibilities,
%  or [min,max] for limits.
%
%  Example:
%  prompt={'Enter the matrix size:','Enter the colormap name:'};
%  def={'20','hsv'};
%  title='Input for Peaks function';
%  lineNo=1;
%  answer=fdinpdlg(prompt,title,lineNo,def,{[1,5],''});
%
%  See also INPUTDLG, TEXTWRAP.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Oct-1997

if nargin<5, Possib=''; end
accept=-inf;
while accept<=0;
  Answer=inputdlg(Prompt, Title, NumLines, DefAns);
  if finite(accept) %erroneous answer
    %cannot incfluence q/a window
  end
  if isempty(Answer), error('Answer is empty from inputdlg'), end
  accept=1;
  for ii=1:length(Possib)
    evalsucc=1;
    Poss=Possib{ii}; Ans=Answer{ii};
    if iscell(Poss) %acceptable are strings only
      acc=0;
      for iii=1:length(Poss)
        acc=acc+strcmp(Ans,Poss(iii));
      end %for iii
      if acc==0, accept=accept-1; else DefAns{ii}=Ans; end
    else %Numerical value(s)
      eval('Ansn=str2num(Ans); evalsucc=1;','evalsucc=0;')
      if ~isempty(Ansn)&evalsucc&all(Poss(1)<=Ansn)&all(Poss(2)>=Ansn) %OK
        DefAns{ii}=Ans;
      else %not accepted
        accept=accept-1;
      end
    end
    if evalsucc, DefAns{ii}=Ans; end
    %Replace all defaults by typed answers
  end %for ii
end %while
%
for ii=1:length(Possib)
  evalsucc=1;
  Poss=Possib{ii}; Ans=Answer{ii};
  if ~iscell(Poss) %Numerical value(s)
    eval('Ansn=str2num(Ans); evalsucc=1;','evalsucc=0;')
    if ~isempty(Ansn)&evalsucc&all(Poss(1)<=Ansn)&all(Poss(2)>=Ansn) %OK
      Answer{ii}=Ansn;
    end
  end
end %ii
%
%End fdinpdlg
