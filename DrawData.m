%创建上位机绘图所用数据
%注意：：：：上位机用的单元号是1：m，而不是网格划分时用的有间隔的。
%%%%%

local_address=pwd;
mkdir(local_address,'draw');
M=200;  %行列数
L=5 ;   %绘图半径

fid=fopen([local_address '\draw\point in tri.txt'],'w');
%判断点在哪个三角形内
for i=1:M
    for j=1:M
        x=2*L / (2.0 * M)*(2 * i - 1)-L;
        y=2*L / (2.0 * M)*(2 * j - 1)-L;
        P=[x y];
        for k=1:NumImageElem
            A=[Element(ImageElem(k)).Node(1).PosX Element(ImageElem(k)).Node(1).PosY];
            B=[Element(ImageElem(k)).Node(2).PosX Element(ImageElem(k)).Node(2).PosY];
            C=[Element(ImageElem(k)).Node(3).PosX Element(ImageElem(k)).Node(3).PosY];
            PA=P-A;
            PB=P-B;
            PC=P-C ;
            t1=PA(1)*PB(2)-PA(2)*PB(1);
            t2=PB(1)*PC(2)-PB(2)*PC(1);
            t3=PC(1)*PA(2)-PC(2)*PA(1);
            if t1*t2>=0&&t2*t3>=0 
                break;
            end
        end
        fprintf(fid,'%d %d %d\r\n',i,j,k);
    end
end
fprintf(fid,'-1 -1\r\n');
fclose(fid);


fid=fopen([local_address '\draw\concentration circle.txt'],'w');
d2=zeros(NumImageElem,1);
d1=[1:NumImageElem]';
d=[d2 d1];
for i=1:M
    for j=1:M
        x=2*L / (2.0 * M)*(2 * i - 1)-L;
        y=2*L / (2.0 * M)*(2 * j - 1)-L;
        for k=1:NumImageElem
            d(k,1)=(Element(ImageElem(k)).MidNode.PosX-x)^2+(Element(ImageElem(k)).MidNode.PosY-y)^2;
        end
        c=sortrows(d);
        c1=c(1:6,1);
        c1=c1.^-1;
        c1=c1/sum(c1);
        fprintf(fid,'%d %d\r\n',i,j);
        for m=1:6
            fprintf(fid,'%d %6f\t',c(m,2),c1(m));
        end
        fprintf(fid,'\r\n');
    end
end
fprintf(fid,'-1 -1\r\n');
fclose(fid);

        

fid=fopen([local_address '\draw\concentration line.txt'],'w');
for i=1:NumImageElem    
    fprintf(fid,'%d %f\r\n',i-1,-Element(ImageElem(i)).delta);
end
fprintf(fid,'-1 0\r\n');
fclose(fid);

fid=fopen([local_address '\draw\concentration rectangle.txt'],'w');
f=20;
dh=10/f;
for i=0:f-1
    h=i*dh-5;
    k=0;
    
    for j=1:NumImageElem    
        if Element(ImageElem(j)).MidNode.PosY>h &&Element(ImageElem(j)).MidNode.PosY<=h+dh
            k=k+1;
            s(k)=j;
        end
    end
    fprintf(fid,'%d %d\r\n',i,k);
    for m=1:k
        fprintf(fid,'%d\t',s(m));
    end
    fprintf(fid,'\r\n');
end
fprintf(fid,'-1 -1\r\n');
fclose(fid);











        