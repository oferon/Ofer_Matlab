% count clustered syllables  
count=0;
 max=0;
 ind=0;
for i=1:1000000
    if(cluster(1000000+i)>0)
        count=count+1;
        if(count>max)
            max=count;
            ind=i;
        end;
    else count=0;
    end;
end;


% calculate a day index vector
daynum=zeros(2211087,1);
current=0; 
ind=0
for i=1:2211087
    if(current~=day(i))
        ind=ind+1;
        current=day(i);
    end;
    daynum(i)=ind;
end;
     


cluster=mysql('select cluster from syll_r2461');
duration=mysql('select duration from syll_r2461');
start=mysql('select start_on from syll_r2461');
day=mysql('select day from syll_r2461');
month=mysql('select month from syll_r2461');


% one gram calculations
bigrams=zeros(42,4);
for i=1:42
    x=cluster(daynum==i);
    n=hist(x,0:1:4);
    bigrams(i,1)=n(1);
    bigrams(i,2)=n(2);
    bigrams(i,3)=n(3);
    bigrams(i,4)=n(4);
end;

% bigram calculations (C->B)
bigrams=zeros(42,4);
for i=1:42
    x=cluster(daynum==i);
    for j=1:length(x)-1
        if(x(j)==3 && x(j+1)==2)
            bigrams(i,1)=bigrams(i,1)+1;
        end;
    end;
end;
    
%find stop durations:
stops=start(2:length(start))-start(1:length(start)-1)-duration(1:length(start)-1);


% for each day compute mean length of bouts and density of clustered data
% in the bout
type=0; type1=0; type2=0; type3=0;
nontype=0;
boutdur=zeros(42,1);
typedensity=zeros(42,1);
typedensity1=zeros(42,1);
typedensity2=zeros(42,1);
typedensity3=zeros(42,1);
numbouts=zeros(42,1);
for i=1:42
    clust=cluster(daynum==i);
    gaps=stops(daynum==i);
    for j=1:length(clust)
        if(gaps(j)>0 && gaps(j)<150)
            if(clust(j)==0)
                nontype=nontype+1;
            else
                type=type+1;
                if(clust(j)==1)type1=type1+1;end;
                if(clust(j)==2)type2=type2+1;end;    
                if(clust(j)==3)type3=type3+1;end;
            end;
        else if(type>0) % end of bout, must include at least one clustered syllable. Now computer measures
                boutdur(i)=boutdur(i)+type+nontype; % overall number of syllables
                typedensity(i)=typedensity(i)+type/(type+nontype);
                typedensity1(i)=typedensity1(i)+type1/(max(type1+nontype,1));
                typedensity2(i)=typedensity2(i)+type2/(max(type2+nontype,1));
                typedensity3(i)=typedensity3(i)+type3/(max(type3+nontype,1));
                numbouts(i)=numbouts(i)+1;
                type=0; type1=0; type2=0; type3=0;
                nontype=0;
            else % reset vars
                nontype=0;
                type=0; type1=0; type2=0; type3=0;
            end;
        end;
    end; 
    nontype=0;
    type=0;
end; 
bout_duration=boutdur./numbouts;
proportion_clustered=typedensity./numbouts;
proportion_A=typedensity1./numbouts;
proportion_B=typedensity2./numbouts;
proportion_C=typedensity3./numbouts;
    
        
            
    
    
    


