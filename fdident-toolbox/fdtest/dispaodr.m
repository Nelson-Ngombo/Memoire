%DISPAODR
for ic=[1,2]
  if exist(['autodemoresults',num2str(ic),'.mat'])
    tmp=load(['autodemoresults',num2str(ic),'.mat']);
    autodemoresults=tmp.autodemoresults; clear tmp
    if ic==1
      m1=stack(1,autodemoresults{:,2});
      m1loose=stack(1,autodemoresults{:,3});
    elseif ic==2
      m2=stack(1,autodemoresults{:,2});
      m2loose=stack(1,autodemoresults{:,3});
    end
    for ii=1:size(autodemoresults,1)
      if ii==1
        fprintf('          Verified model, loose model')
        if ic==1, disp(': present algorithm'), else disp(': new algorithm'), end
      end
      if ~isempty(autodemoresults{ii,1})
        mi1=autodemoresults{ii,2};
        no1=size(mi1.num,2)-1; do1=size(mi1.denom,2)-1; clear mi1
        mi2=autodemoresults{ii,3};
        no2=size(mi2.num,2)-1; do2=size(mi2.denom,2)-1; clear mi2
        fprintf('%2.0f. ',ii)
        fprintf([autodemoresults{ii,1},'   ','%.0f/%.0f, %.0f/%.0f\n'],no1,do1,no2,do2)
        clear no1 do1 no2 do2
      end
    end
  end
end
clear ic ii autodemoresults
%for ii=1:15, advice(stack(1,m1(:,:,ii),m1loose(:,:,ii))), keyboard, end
