function [p,t,pfixE] = ECTmeshgrid(ir,or,ElecNum,NodePerElec,varargin)
%ir 内径,or 外径，ElecNum 电极数
%      P:         Node positions (Nx2)      网格点的x,y坐标
%      T:         Triangle indices (NTx3)      网格任一一个三角形的三个顶点

k=5/ir;%将内径缩放到5
ir1=5;%新内径
or1=k*or;%新外径
or2=or1+2;%屏蔽罩外径

h0=0.5;%初始化网格长度
bbox=[-or2,-or2;or2,or2];%最大边界范围
fd=@(p) sqrt(sum(p.^2,2))-or2;%距离函数
fh=@(p) scalemy(dcircle(p,0,0,0),ir1,or1);%网格大小
ElecNodeNum=ElecNum*NodePerElec;
dx=2*pi*or1/ElecNodeNum;
for i=1:ElecNodeNum%固定电极
    pfix1(i,1)=or1*cos(2*pi*i/ElecNodeNum);
    pfix1(i,2)=or1*sin(2*pi*i/ElecNodeNum);
    pfix4(i,1)=(or1+dx)*cos(2*pi*i/ElecNodeNum);
    pfix4(i,2)=(or1+dx)*sin(2*pi*i/ElecNodeNum);
    pfix5(i,1)=(or1-dx)*cos(2*pi*i/ElecNodeNum);
    pfix5(i,2)=(or1-dx)*sin(2*pi*i/ElecNodeNum);
end
for i=1:ElecNum*8%管内壁
    pfix3(i,1)=ir1*cos(2*pi*i/(ElecNum*8));
    pfix3(i,2)=ir1*sin(2*pi*i/(ElecNum*8));
end
j=1;
pfix2(j,1)=0;
pfix2(j,2)=0;
k=0.5;
for i=1:10
    j=j+1;
    pfix2(j,1)=k*i;
    pfix2(j,2)=0;
    j=j+1;
    pfix2(j,1)=0;
    pfix2(j,2)=k*i;
    j=j+1;
    pfix2(j,1)=-k*i;
    pfix2(j,2)=0;
    j=j+1;
    pfix2(j,1)=0;
    pfix2(j,2)=-k*i;
end
pfixE=[pfix1 pfix4 pfix5];
%pfix=[pfix1;pfix2;pfix3;pfix4;pfix5];
pfix=[pfix1;pfix3;pfix4;pfix5];
[p,t]=distmesh2d(fd,fh,h0,bbox,pfix);   
end

function scale = scalemy(r,ir,or)
n=max(size(r));
for i=1:n
    if r(i)<ir  scale(i)=8;
%     elseif r(i)<ir  scale(i)=0.1+(ir-r(i))/10;
    elseif r(i)<or     scale(i)=8;10-(r(i)-ir)*2;
    else     scale(i)=8;+(r(i)-or)*1.5;
    end       
end
scale=scale';
end
