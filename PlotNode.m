tempA=xlsread('nodeinf.xlsx','coor');
NumNode=size(tempA,1);
for i=1:NumNode
    X(i)=tempA(i,2);
    Y(i)=tempA(i,3);
end
tempB=xlsread('nodeinf.xlsx','rela');
TRI=tempB(:,2:4);
innode=xlsread('nodeinf.xlsx','eimage');


TR = triangulation(TRI,X',Y');
%  triplot(TR);
%  V=data.in';
TR2=triangulation(TR.ConnectivityList(innode,:),X',Y');
triplot(TR2);
%triplot(TRI,X,Y);%网格划分
%trisurf(TRI,X,Y,V);%灵敏场
figure (2)
GridSet(tempA(:,2:3),tempB(:,2:4),0,1);

% IC = incenter(TR,innode);
% cx=linspace(min(IC(:,1)),max(IC(:,1)));
% cy=linspace(min(IC(:,2)),max(IC(:,2)));
% cz=griddata(IC(:,1),IC(:,2),V,cx,cy','cubic');
% surf(cx,cy,cz);

