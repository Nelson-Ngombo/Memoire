%Help on Fdident GUI: Blocks
% 
%    Blocks are the key action elements. Only blue or green blocks can be 
%    opened, by double-click (or right button click). Blocks are in general 
%    allowed for use if their necessary input data are available. An exception 
%    is the block "Excitation Signal Design" which also needs for use that 
%    "UserLevel" is set to "Interactive" or higher. 
% 
%    At start only the blocks "Read Time Domain Data" and "Read Freq. Domain 
%    Data" can be opened.
% 
%    Blocks return output data after the Close command. In this case their 
%    color becomes green. The Cancel command closes them without affecting 
%    either their output or their previous setting.
% 
%    When a block is already opened, and we click on another one, a warning 
%    comes up. We can then immediately cancel the previous block and go to the 
%    new one.
% 
%    There are three special automatic actions if the menu "UserLevel" is set 
%    to "Automatic". After importing the data into the block "Read Time Domain 
%    Data", it automatically preprocesses them with automatic period length 
%    determination and default settings. Similarly, "Read Frequency Domain 
%    Data" will automatically execute after "Close". 
%    The block "Variances and/or Averaging" also automatically proceeds after 
%    any of the Read blocks or after having opened it (at least if this is 
%    possible), and the block "Estimate Plant Model" automatically closes after 
%    estimation, and the block "Evaluate or Compare Plant Models" opens up.
% 
%    Other topics are also available, use the Topics menu.