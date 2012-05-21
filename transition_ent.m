figure(2);set(gcf,'Color','white');
plot(days,permute(bigrams_daily(1,3,:),[3,1,2]),'Color',[0,1,0],'LineWidth',2,'Marker','*');hold on;
plot(days,permute(bigrams_daily(3,2,:),[3,1,2]),'Color',[1,.5,0],'LineWidth',2,'Marker','x');hold on;
plot(days,permute(bigrams_daily(2,1,:),[3,1,2]),'Color',[.5,.5,.5],'LineWidth',2,'LineStyle','--','Marker','.');hold on;
[legend_h,object_h,plot_h,text_strings]=legend('AC','CB','BA');
legend([plot_h(1),plot_h(2),plot_h(3)],{'AC','CB','BA'},'FontSize',14,'FontWeight','Bold','EdgeColor','white')
xlabel('Age (days)', 'FontName', 'Arial','FontSize',14);
ylabel('Observed Frequency', 'FontName', 'Arial','FontSize',14)
%hold on;

%calculate transition entropy

x=0;
transition_ent=zeros(length(days),1);
for(z=1:length(days))
    for(i=1:3)
        for(j=1:3)x=(x+0.00001)-bigrams_daily(i,j,z)*log(bigrams_daily(i,j,z)+0.00001);
    end;
end;
transition_ent(z)=x;
x=0;
end;
figure(4);
plot(transition_ent);
