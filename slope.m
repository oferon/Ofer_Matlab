found25=zeros(3,3);
found75=zeros(3,3);
found25x=zeros(3,3);
found75x=zeros(3,3);
mx=zeros(3,3);
for(m=1:3)
    for(n=1:3)
        x=(bigrams_daily(m,n,1:end));
        ndays=length(x);
        x=squeeze(x);
        mx(m,n)=max(x);
        mx75=mx(m,n)*0.75;
        mx25=mx(m,n)*0.25;
        % for new bigrams
        % go backwards until hit 25% of max
        for(i=1:ndays)
            if(found25(m,n)==false && x(ndays-i)<mx25)
                found25(m,n)=ndays-i;
            end; 
        end;
        % go forward from 25% until hit 75%
        for(i=found25(m,n):ndays)
            if(found75(m,n)==false && x(i)>mx75)
                found75(m,n)=i;
            end; 
        end; 
        % for extiction, 
        % go backwords until hit 75% of max
        for(i=1:ndays)
            if(found75x(m,n)==false && x(ndays-i)>mx75)
                found75x(m,n)=ndays-i;
            end; 
        end;
        % go forward from 75% until hit 25%
        for(i=found75x(m,n):ndays)
            if(found25x(m,n)==false && x(i)<mx25)
                found25x(m,n)=i;
            end; 
        end; 
    end;
end;