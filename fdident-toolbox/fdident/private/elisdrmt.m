Possible fields and their values of the elis run modifier structure devrunmod
=============================================================================
The 6th input run argument of elis is a structure of run modifier properties 
for very advanced users (researchers).
These properties are not for regular use. They are meant for research only.
Their use is for your own responsibility.
  
newbasis - way of basis update in orthopol: 'off' to calculate new basis
   before initial setting (using previous results if initp contains parameters),
   'on' to use basis given in initmodel. Default: 'off'
linesearch - for line search in calculated direction ('on')
displaymessages - 'on', 'off', 'short' or 'burst' (maybe 'collect' for collection only)
calculatezeros - 'on' to calculate zeros, 'off' for don't calculate (default: 'on')
calculatepoles - 'on' to calculate zeros, 'off' for don't calculate (default: 'on')
followroots - number of consecutive zero/pole sets shown at the same time, default: 1
checkiterctrl - check iterctrl: 'on' or 'off' 
calldrawnow - call drawnow to be able to check iterctrl, 'on' or 'off'
calculateCR - calculate (and store in object) covariance matrix, 'on' or 'off' 
compensate - compensate initial value setting in the following cases 
   (depending on what is present in the string as substring):
     freqscale: frequency scaling
     fixing: fixing certain parameters
     representation: polynomial/orthopol change
     all: all the above
----------------------
Second output argument (for development purposes):
Information on the internal numerics is also available, by requesting a second
output argument. This is a structure, with the following fields:
cfv = vector of the cost function values in the iteration steps; for
   the LM algorithm, the second column contains the lambda values.
J = Jacobian
w = weight (linear, denominator) vector: weights of the squared error terms
    in the last cycle

See also: elis runmod, elis fitinfo