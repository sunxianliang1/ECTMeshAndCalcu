local_address=pwd;
mkdir(local_address,'draw');
M=200;  %ÐÐÁÐÊý
L=5 ;   %»æÍ¼°ë¾¶
fid=fopen([local_address '\draw\concentration circle.txt'],'w');
d2=zeros(NumImageElem,1);
d1=[0:701]';
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
        c1=c1.^-0.75;
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
    fprintf(fid,'%d %f\r\n',i,Element(ImageElem(i)).delta);
end
fprintf(fid,'-1 0\r\n');
fclose(fid);

fid=fopen([local_address '\draw\concentration rectangle.txt'],'w');
for i=0:49
    h=i*0.2-4.8;
    k=0;
    
    for j=1:NumImageElem    
        if Element(ImageElem(j)).MidNode.PosX<h &&Element(ImageElem(j)).MidNode.PosX>=h-0.2
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











        