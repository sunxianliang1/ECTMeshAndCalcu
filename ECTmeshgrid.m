function [p,t,pfixE] = ECTmeshgrid(ir,or,ElecNum,NodePerElec,varargin)
%ir �ھ�,or �⾶��ElecNum �缫��
%      P:         Node positions (Nx2)      ������x,y����
%      T:         Triangle indices (NTx3)      ������һһ�������ε���������

k=5/ir;%���ھ����ŵ�5
ir1=5;%���ھ�
or1=k*or;%���⾶
or2=or1+2;%�������⾶

h0=0.5;%��ʼ�����񳤶�
bbox=[-or2,-or2;or2,or2];%���߽緶Χ
fd=@(p) sqrt(sum(p.^2,2))-or2;%���뺯��
fh=@(p) scalemy(dcircle(p,0,0,0),ir1,or1);%�����С
ElecNodeNum=ElecNum*NodePerElec;
dx=2*pi*or1/ElecNodeNum;
for i=1:ElecNodeNum%�̶��缫
    pfix1(i,1)=or1*cos(2*pi*i/ElecNodeNum);
    pfix1(i,2)=or1*sin(2*pi*i/ElecNodeNum);
    pfix4(i,1)=(or1+dx)*cos(2*pi*i/ElecNodeNum);
    pfix4(i,2)=(or1+dx)*sin(2*pi*i/ElecNodeNum);
    pfix5(i,1)=(or1-dx)*cos(2*pi*i/ElecNodeNum);
    pfix5(i,2)=(or1-dx)*sin(2*pi*i/ElecNodeNum);
end
for i=1:ElecNum*8%���ڱ�
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
