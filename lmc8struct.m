
e0=8.855e-12;  %介电常数
Efull=4.0;  %煤粉介电常数
Eempty=1;   %空气介电常数
Eglass=4.0;   %石英玻璃管道介电常数
Eout=2.5;   %屏蔽层介电常数
BigNum=1e20;


% Class Node
%     PosX  
%     PosY

% Class Element
%     Node1,Node2,Node3,MidNode 三点及中点
%     a1,a2,a3
%     b1,b2,b3
%     c1,c2,c3
%     delta
%     e       介电常数

tempA=xlsread(nodeinf,'coor');
tempB=size(tempA);
NumNode=tempB(1,1);
for i=1:NumNode
    Node(i).PosX=tempA(i,2);
    Node(i).PosY=tempA(i,3); 
end

tempA= xlsread(nodeinf,'rela');
tempB=size(tempA);
NumElement=tempB(1,1);
for i=1:NumElement
    Element(i).Node(1)=Node(tempA(i,2));
    Element(i).Node(2)=Node(tempA(i,3));
    Element(i).Node(3)=Node(tempA(i,4));
    Element(i).NodeNum(1)=tempA(i,2);
    Element(i).NodeNum(2)=tempA(i,3);
    Element(i).NodeNum(3)=tempA(i,4);
    Element(i).MidNode.PosX=(Element(i).Node(1).PosX+Element(i).Node(2).PosX+Element(i).Node(3).PosX)/3;
    Element(i).MidNode.PosY=(Element(i).Node(1).PosY+Element(i).Node(2).PosY+Element(i).Node(3).PosY)/3;
    Element(i).a(1)=Element(i).Node(2).PosX*Element(i).Node(3).PosY-Element(i).Node(3).PosX*Element(i).Node(2).PosY;
    Element(i).a(2)=Element(i).Node(3).PosX*Element(i).Node(1).PosY-Element(i).Node(1).PosX*Element(i).Node(3).PosY;
    Element(i).a(3)=Element(i).Node(1).PosX*Element(i).Node(2).PosY-Element(i).Node(2).PosX*Element(i).Node(1).PosY;
    Element(i).b(1)=Element(i).Node(2).PosY-Element(i).Node(3).PosY;
    Element(i).b(2)=Element(i).Node(3).PosY-Element(i).Node(1).PosY;
    Element(i).b(3)=Element(i).Node(1).PosY-Element(i).Node(2).PosY;
    Element(i).c(1)=Element(i).Node(2).PosX-Element(i).Node(3).PosX;
    Element(i).c(2)=Element(i).Node(3).PosX-Element(i).Node(1).PosX;
    Element(i).c(3)=Element(i).Node(1).PosX-Element(i).Node(2).PosX;
    Element(i).delta=(Element(i).b(1)*Element(i).c(2)-Element(i).b(2)*Element(i).c(1))/2;    
    Element(i).e=Eout;
end

BoundNode=xlsread(nodeinf,'bound');%边界节点
tempB=size(BoundNode);
NumBoundNode=tempB(1,1);

ElecNode=xlsread(nodeinf,'electrode');%电极节点及左右
tempC=size(ElecNode);
NumElecNode=tempC(1,1);
NumOneElecNode=NumElecNode/8;
EleNodeGap=1;

GlassElem=xlsread(nodeinf,'eglass');%玻璃管道单元
tempD=size(GlassElem);
NumGlassElem=tempD(1,1);

for i=1:NumGlassElem
    Element(GlassElem(i)).e=Eglass;
end

ImageElem=xlsread(nodeinf,'eimage');%成像单元
tempE=size(ImageElem);
NumImageElem=tempE(1,1);
for i=1:NumImageElem
    NNN1(i,1)=Element(ImageElem(i)).MidNode.PosX;
    NNN2(i,1)=Element(ImageElem(i)).MidNode.PosY;
end
% xlswrite('.\xy.xls',NNN1,'x');
% xlswrite('.\xy.xls',NNN2,'y');
% 


Cm=zeros(28,NumImageElem);
for NS=1:NumImageElem+2
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%设置介质介电常数
    for i=1:NumImageElem
        Element(ImageElem(i)).e=Eempty;
    end
    if NS==NumImageElem+2
        for i=1:NumImageElem
            Element(ImageElem(i)).e=Efull;
        end    
    else
        if NS<=NumImageElem
            Element(ImageElem(NS)).e=Efull;%将当前的NS单元设为高介电数
        end
    end
    
    K=zeros(NumNode,NumNode);%刚度矩阵
    V=zeros(NumNode,1);%电势矩阵
    B=zeros(NumNode,1);%边界矩阵
    
    for N=1:NumElement%计算刚度矩阵
        for i=1:3
            for j=1:3
                Element(N).Kin(i,j)=Element(N).e*(Element(N).b(i)*Element(N).b(j)+Element(N).c(i)*Element(N).c(j))/(4*Element(N).delta);
                K(Element(N).NodeNum(i),Element(N).NodeNum(j))=K(Element(N).NodeNum(i),Element(N).NodeNum(j))+Element(N).Kin(i,j);
            end
        end
    end
    %    %%##%%%%%%%%##%%
 
    ProElecNode=[1 24];%保护电极 Protective electrode
    EleElecNode=[6:19];%带电电极
    AllElecNode=[ProElecNode EleElecNode];
    for i=1:8   %%设置电极结点边界条件
        NumBN=(i-1)*NumOneElecNode;
        for j=AllElecNode%设置电极
            K(ElecNode(NumBN+j,2),ElecNode(NumBN+j,2))=BigNum;
        end
    end
    for i=1:NumBoundNode%屏蔽电极边界
        K(BoundNode(i),BoundNode(i))=BigNum;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%主循环
    
    NumTwoEle=0;%电极对序号
    for ExcElec=1:7%激励电极  exciting electrode
        NumBN=(ExcElec-1)*NumOneElecNode;
        B=zeros(NumNode,1);%边界矩阵
        for j=EleElecNode%设置激励电极电压
            B(ElecNode(NumBN+j,2))=10*BigNum;
        end
        KK=sparse(K);%改为稀疏矩阵，增加速度
        warning off
        V=KK\B;%计算结点电电势
        warning on
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算电极电荷Q
%         for i=1:1647
%             X(i)=Node(i).PosX;
%             Y(i)=Node(i).PosY;
%         end
%         TRI = delaunay(X,Y);
%         % triplot(TRI,X,Y);
%         trisurf(TRI,X,Y,V);   
        for ResElec=ExcElec+1:8  %响应电极Response electrode
            NumBN=(ResElec-1)*NumOneElecNode;
            NumTwoEle=NumTwoEle+1;
            Q(NumTwoEle)=0;
            for i=[EleElecNode(1) EleElecNode+1]
                %上节点
                DLX(i,3,ResElec)=Node(ElecNode(NumBN+i,3)).PosX-Node(ElecNode(NumBN+i-1,3)).PosX;
                DLY(i,3,ResElec)=Node(ElecNode(NumBN+i,3)).PosY-Node(ElecNode(NumBN+i-1,3)).PosY; 
                %下节点 反向
                DLX(i,1,ResElec)=Node(ElecNode(NumBN+i-1,1)).PosX-Node(ElecNode(NumBN+i,1)).PosX;
                DLY(i,1,ResElec)=Node(ElecNode(NumBN+i-1,1)).PosY-Node(ElecNode(NumBN+i,1)).PosY;           
            end
            for i=EleElecNode
                %上节点
                DEX(i,3,ResElec)=Node(ElecNode(NumBN+i,3)).PosX-Node(ElecNode(NumBN+i,2)).PosX;
                DEY(i,3,ResElec)=Node(ElecNode(NumBN+i,3)).PosY-Node(ElecNode(NumBN+i,2)).PosY;
                DES2(i,3,ResElec)=DEX(i,3,ResElec)*DEX(i,3,ResElec)+DEY(i,3,ResElec)*DEY(i,3,ResElec);
                %下节点
                DEX(i,1,ResElec)=Node(ElecNode(NumBN+i,1)).PosX-Node(ElecNode(NumBN+i,2)).PosX;
                DEY(i,1,ResElec)=Node(ElecNode(NumBN+i,1)).PosY-Node(ElecNode(NumBN+i,2)).PosY;
                DES2(i,1,ResElec)=DEX(i,1,ResElec)*DEX(i,1,ResElec)+DEY(i,1,ResElec)*DEY(i,1,ResElec);
            end
           
            %左上角
            i=EleElecNode(1);
            DLX(i-1,3,ResElec)=Node(ElecNode(NumBN+i-1,3)).PosX-Node(ElecNode(NumBN+i-1,2)).PosX;
            DLY(i-1,3,ResElec)=Node(ElecNode(NumBN+i-1,3)).PosY-Node(ElecNode(NumBN+i-1,2)).PosY;
            DEX(i-1,3,ResElec)=Node(ElecNode(NumBN+i-1,3)).PosX-Node(ElecNode(NumBN+i,2)).PosX;
            DEY(i-1,3,ResElec)=Node(ElecNode(NumBN+i-1,3)).PosY-Node(ElecNode(NumBN+i,2)).PosY;
            DES2(i-1,3,ResElec)=DEX(i-1,3,ResElec)*DEX(i-1,3,ResElec)+DEY(i-1,3,ResElec)*DEY(i-1,3,ResElec);         
            %左下角
            DLX(i-1,1,ResElec)=Node(ElecNode(NumBN+i-1,2)).PosX-Node(ElecNode(NumBN+i-1,1)).PosX;
            DLY(i-1,1,ResElec)=Node(ElecNode(NumBN+i-1,2)).PosY-Node(ElecNode(NumBN+i-1,1)).PosY;
            DEX(i-1,1,ResElec)=Node(ElecNode(NumBN+i-1,1)).PosX-Node(ElecNode(NumBN+i,2)).PosX;
            DEY(i-1,1,ResElec)=Node(ElecNode(NumBN+i-1,1)).PosY-Node(ElecNode(NumBN+i,2)).PosY;
            DES2(i-1,1,ResElec)=DEX(i-1,1,ResElec)*DEX(i-1,1,ResElec)+DEY(i-1,1,ResElec)*DEY(i-1,1,ResElec);
            %右上角
            i=EleElecNode(length(EleElecNode));
            DLX(i+2,3,ResElec)=Node(ElecNode(NumBN+i+1,2)).PosX-Node(ElecNode(NumBN+i+1,3)).PosX;
            DLY(i+2,3,ResElec)=Node(ElecNode(NumBN+i+1,2)).PosY-Node(ElecNode(NumBN+i+1,3)).PosY;
            DEX(i+1,3,ResElec)=Node(ElecNode(NumBN+i+1,3)).PosX-Node(ElecNode(NumBN+i,2)).PosX;
            DEY(i+1,3,ResElec)=Node(ElecNode(NumBN+i+1,3)).PosY-Node(ElecNode(NumBN+i,2)).PosY;
            DES2(i+1,3,ResElec)=DEX(i+1,3,ResElec)*DEX(i+1,3,ResElec)+DEY(i+1,3,ResElec)*DEY(i+1,3,ResElec);
            %右下角
            DLX(i+2,1,ResElec)=Node(ElecNode(NumBN+i+1,1)).PosX-Node(ElecNode(NumBN+i+1,2)).PosX;
            DLY(i+2,1,ResElec)=Node(ElecNode(NumBN+i+1,1)).PosY-Node(ElecNode(NumBN+i+1,2)).PosY;
            DEX(i+1,1,ResElec)=Node(ElecNode(NumBN+i+1,1)).PosX-Node(ElecNode(NumBN+i,2)).PosX;
            DEY(i+1,1,ResElec)=Node(ElecNode(NumBN+i+1,1)).PosY-Node(ElecNode(NumBN+i,2)).PosY;
            DES2(i+1,1,ResElec)=DEX(i+1,1,ResElec)*DEX(i+1,1,ResElec)+DEY(i+1,1,ResElec)*DEY(i+1,1,ResElec);           
            
            for i=[EleElecNode(1)-1 EleElecNode(1) EleElecNode+1]
                Q(NumTwoEle)=Q(NumTwoEle)+(DEY(i,3,ResElec)*DLX(i,3,ResElec)-DEX(i,3,ResElec)*DLY(i,3,ResElec))*V(ElecNode(NumBN+i,3))*Eout/(2*DES2(i,3,ResElec));
                Q(NumTwoEle)=Q(NumTwoEle)+(DEY(i,3,ResElec)*DLX(i+1,3,ResElec)-DEX(i,3,ResElec)*DLY(i+1,3,ResElec))*V(ElecNode(NumBN+i,3))*Eout/(2*DES2(i,3,ResElec));
                
                Q(NumTwoEle)=Q(NumTwoEle)+(DEY(i,1,ResElec)*DLX(i,1,ResElec)-DEX(i,1,ResElec)*DLY(i,1,ResElec))*V(ElecNode(NumBN+i,1))*Eglass/(2*DES2(i,1,ResElec));
                Q(NumTwoEle)=Q(NumTwoEle)+(DEY(i,1,ResElec)*DLX(i+1,1,ResElec)-DEX(i,1,ResElec)*DLY(i+1,1,ResElec))*V(ElecNode(NumBN+i,1))*Eglass/(2*DES2(i,1,ResElec));
            end
            %左边
            i=EleElecNode(1)-1;
            DEX(i,2,ResElec)=Node(ElecNode(NumBN+i,2)).PosX-Node(ElecNode(NumBN+i+1,2)).PosX;
            DEY(i,2,ResElec)=Node(ElecNode(NumBN+i,2)).PosY-Node(ElecNode(NumBN+i+1,2)).PosY;
            DES2(i,2,ResElec)=DEX(i,2,ResElec)*DEX(i,2,ResElec)+DEY(i,2,ResElec)*DEY(i,2,ResElec);
            Q(NumTwoEle)=Q(NumTwoEle)+(DEY(i,2,ResElec)*DLX(i,3,ResElec)-DEX(i,2,ResElec)*DLY(i,3,ResElec))*V(ElecNode(NumBN+i,2))*(Eout+Eglass)*0.5/(2*DES2(i,2,ResElec));
            Q(NumTwoEle)=Q(NumTwoEle)+(DEY(i,2,ResElec)*DLX(i,1,ResElec)-DEX(i,2,ResElec)*DLY(i,1,ResElec))*V(ElecNode(NumBN+i,2))*(Eout+Eglass)*0.5/(2*DES2(i,2,ResElec));

            %右边
            i=EleElecNode(length(EleElecNode));
            DEX(i+1,2,ResElec)=Node(ElecNode(NumBN+i+1,2)).PosX-Node(ElecNode(NumBN+i,2)).PosX;
            DEY(i+1,2,ResElec)=Node(ElecNode(NumBN+i+1,2)).PosY-Node(ElecNode(NumBN+i,2)).PosY;
            DES2(i+1,2,ResElec)=DEX(i+1,2,ResElec)*DEX(i+1,2,ResElec)+DEY(i+1,2,ResElec)*DEY(i+1,2,ResElec);
            Q(NumTwoEle)=Q(NumTwoEle)+(DEY(i+1,2,ResElec)*DLX(i+2,3,ResElec)-DEX(i+1,2,ResElec)*DLY(i+2,3,ResElec))*V(ElecNode(NumBN+i+1,2))*(Eout+Eglass)*0.5/(2*DES2(i+1,2,ResElec));
            Q(NumTwoEle)=Q(NumTwoEle)+(DEY(i+1,2,ResElec)*DLX(i+2,1,ResElec)-DEX(i+1,2,ResElec)*DLY(i+2,1,ResElec))*V(ElecNode(NumBN+i+1,2))*(Eout+Eglass)*0.5/(2*DES2(i+1,2,ResElec));   
            Cap(NumTwoEle)=-Q(NumTwoEle)*0.885/10;
            Cm(NumTwoEle,NS)=Cap(NumTwoEle);
        end           
    end
    NS    
end

    
Area=0;    
for i=1:NumImageElem
    Area=Area+Element(ImageElem(i)).delta;
end
CH(:)=Cm(:,NumImageElem+2);
CL(:)=Cm(:,NumImageElem+1);
for ij=1:28
    for k=1:NumImageElem
        S(ij,k)=((Cm(ij,k)-CL(ij))/(CH(ij)-CL(ij)))*Area/(Element(ImageElem(k)).delta)/(Efull-Eempty);
    end
end

plot(CH)
hold on
plot(CL)
hold on
plot(CH-CL)






















