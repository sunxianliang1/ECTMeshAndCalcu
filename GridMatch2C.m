clear all
ir=50;
or=60;
ElecNum=8;
NodePerElec=24;
[p,t,pfixE]= ECTmeshgrid(ir,or,ElecNum,NodePerElec);
k=5/ir;%将内径缩放到5
ir1=5;%新内径
or1=k*or;%新外径
or2=or1+2;%屏蔽罩外径

delete nodeinf.xlsx
pnum=1:size(p);
xlswrite("nodeinf.xlsx",[pnum' p],'coor');
tnum=1:size(t);
xlswrite("nodeinf.xlsx",[tnum' t],'rela');
%%
ke=findpoint(pfixE(:,1:2),p);%电极点
ko=findpoint(pfixE(:,3:4),p);%电极外
ki=findpoint(pfixE(:,5:6),p);%电极内
xlswrite("nodeinf.xlsx",[ki ke ko],'electrode');
%%
eimage=[];
eglass=[];
for i=1:size(t)
    trix(i)=(p(t(i,1),1)+p(t(i,2),1)+p(t(i,3),1))/3;
    triy(i)=(p(t(i,1),2)+p(t(i,2),2)+p(t(i,3),2))/3;
    r(i)=trix(i)*trix(i)+triy(i)*triy(i);
    if r(i)<ir1^2
        eimage=[eimage;i];
    else if r(i)<or1^2
           eglass=[eglass;i]; 
        end
    end
end
xlswrite("nodeinf.xlsx",eimage,'eimage');
xlswrite("nodeinf.xlsx",eglass,'eglass');
%%
bound=[];
for i=1:size(p)
    r=p(i,1)^2+p(i,2)^2;
    if r>or2^2-0.1
       bound=[bound;i]; 
    end       
end
xlswrite("nodeinf.xlsx",bound,'bound');



%%
function k=findpoint(trodes,p)
s=size(trodes,1);
k=zeros(s,1);
    for i=1:s
    m1=find(p(:,1)==trodes(i,1));
    n1=find(p(:,2)==trodes(i,2));
    if (size(m1)==1)
        k(i)=m1;continue;
    end
    if(size(n1)==1)
        k(i)=n1;continue;
    end
    c=ismember(m1,n1);
    k(i)=m1(c);
    end
end






