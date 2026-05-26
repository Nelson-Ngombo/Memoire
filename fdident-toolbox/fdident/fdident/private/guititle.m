function guititle(titlehand)
% function guititle(titlehand)
% adjust text width according to extent

for i=1:length(titlehand)
   h=titlehand(i);
   ext=get(h, 'extent');
   oldpos=get(h, 'position');
   newpos=oldpos;
   newpos(3)=ext(3)+6;
   newpos(1)=oldpos(1)+oldpos(3)/2-newpos(3)/2;
   set(h, 'position', newpos)
end