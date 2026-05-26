function [cp,cb]=constr2arr(cc,numord,denomord,domain)
%CONSTR2ARR Convert constraints to the form cp*[num,denom]'=cb
%
%       Usage: [cp,cb]=constr2arr(cc,numord,denomord,domain);
%
%       The constraints are given either in array form, or as:
%       {'5*b(Nb)+6.5*a_Na+2*a_(Na-1)+a_1=2';
%         'b_0=2'}

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
if iscell(cc)
  if isempty(cc), warning('constraints are empty')
  elseif isnumeric(cc{1})
    cp=cc{1};
    if length(cc)==2, cb=cc{2}; 
    else error(sprintf('Length of numeric constraint cell is %.0f',length(cc))) 
    end
    if isempty(cb)&~isempty(cp), cb=zeros(size(cp,1),1); end
  elseif isstr(cc{1})
    cp=[]; cb=[];
    for ii=1:length(cc)
      str=cc{ii};
      cp=[cp;zeros(1,numord+denomord+2)]; cb=[cb;0];
      ind=sort([findstr(str,'+'),findstr(str,'-'),findstr(str,'=')]);
      inde=findstr(str,'=');
      if length(inde)~=1
        error('In a constraint just one = mark must be written')
      end
      indpo=findstr(str,'('); indpc=findstr(str,')');
      if length(indpo)~=length(indpc), error('Parenthesis error'), end
      for indi=length(ind):-1:1 %eliminate signs in index or on right side
        if sum(indpo<ind(indi))==sum(indpc<ind(indi))+1
          ind(indi)=[]; 
        elseif inde<ind(indi)
          ind(indi)=[]; 
        end
      end %for indi
      if ind(1)~=1, ind=[1,ind]; end
      ind=[ind,length(str)+1];
      for in=1:length(ind)-1
        term=str(ind(in):ind(in+1)-1);
        term=deblank(term); term=fliplr(deblank(fliplr(term)));
        if (in==1)&~any(term(1)=='+-='), term=['+',term]; end
        while (length(term)>=2)&any(term(2)==[' ',sprintf('\t')]), term(2)=''; end
        if term(1)=='='
          cb(ii,1)=str2num(term(2:end));
          if in<length(ind)-1, error('= sign too early'), end
        else
          if any(term=='='), error('invalid = sign'), end
          indm=find(term=='*');
          if ~isempty(indm)
            ci=term(1:indm-1); ca=term(indm+1:end);
          else
            inda=sort([findstr('a',term),findstr('b',term)]);
            indNa=[findstr('Na',term),findstr('Nb',term)];
            if length(inda)-length(indNa)~=1, error('ambiguous string'), end  
            ci=term(1:inda-1); ca=term(inda:end);
          end
          %ci
          if strcmp(ci,'-'), coeff=-1;
          elseif strcmp(ci,'+'), coeff=1;
          else coeff=str2num(ci);  
          end
          %ca
          if any(ca(1)=='b'), N=numord; Nb=N; clear Na
          elseif any(ca(1)=='a'), N=denomord; Na=N; clear Nb
          else error('invalid term in contraints')
          end
          if length(ca)>=2
            if (ca(2)=='_'), ca(2)=''; end
            if ca(2)=='('
              indp=find(ca==')');
              indstr=ca(3:indp-1);  
            else
              indstr=ca(2:end);
            end
          else
            indstr=ca;
          end
          try
            eval(['index=',indstr,';'])
          catch
            disp(['Evaluating expression ''',term,''' ...'])
            error(['Cannot evaluate index of variable ',ca(1),': ''',indstr,''''])
          end
          if (index<0)|(index>N), error('Index out of range'), end
          if any(findstr(domain,'zq'))
          else index=N-index;
          end
          if ca(1)=='a', index=index+numord+1; end
          index=index+1;
          if cp(ii,index), error('coefficient redefined'), end
          cp(ii,index)=coeff;
        end
      end %for in
    end %for ii
  else
    error(['constraint elements are given as variable of class ''',class(cc),''''])
  end
else 
  error(['constraints are given as variable of class ''',class(cc),''''])
end
if isempty(cb)&~isempty(cp), cb=zeros(size(cp,1),1); end
if size(cp,2)~=numord+denomord+2, error('size 2 of cp is wrong')
elseif size(cb,2)~=1, error('size 2 of cb is not 1')
elseif size(cp,1)~=size(cb,1), error('sizes 1 of cp and cb are not equal')
end
%End of constr2arr