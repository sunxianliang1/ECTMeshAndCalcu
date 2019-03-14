tempA=xlsread('nodeinf.xls','coor');
NumNode=size(tempA,1);
for i=1:NumNode
    X(i)=tempA(i,2);
    Y(i)=tempA(i,3);
end
tempB=xlsread('nodeinf.xls','rela');
TRI=tempB(:,2:4);
TR = triangulation(TRI,X',Y');
% triplot(TR);
V=data.in';
TR2=triangulation(TR.ConnectivityList(1:664,:),X',Y');
%triplot(TR2);
%triplot(TRI,X,Y);%网格划分
%trisurf(TRI,X,Y,V);%灵敏场
for i=1:664
    
    
    
end


