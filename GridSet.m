function [tt1,tt2]=GridSet(p,t,nodenumplot,trinumplot)
simpplot(p,t);
NodeNum=1:size(p,1);
NodeNumTxt=int2str(NodeNum');
x=p(:,1);
y=p(:,2);
tt1=text(x,y,NodeNumTxt,'HorizontalAlignment','center','Color','blue');
l1=size(tt1,1);
for i=1:l1
    if nodenumplot==1
        tt1(i).Visible='on';
    else
        tt1(i).Visible='off';
    end
end
for i=1:size(t)
    trix(i)=(p(t(i,1),1)+p(t(i,2),1)+p(t(i,3),1))/3;
    triy(i)=(p(t(i,1),2)+p(t(i,2),2)+p(t(i,3),2))/3;
    r(i)=trix(i)*trix(i)+triy(i)*triy(i);
end
NodeNum=1:size(t,1);
NodeNumTxt=int2str(NodeNum');
tt2=text(trix,triy,NodeNumTxt,'HorizontalAlignment','center','Color','red');
l2=size(tt2,1);
for i=1:l2
    if trinumplot==1
        tt2(i).Visible='on';
    else
        tt2(i).Visible='off';
    end
end


