local_address=pwd;
mkdir(local_address,'celebration');
fid=fopen([local_address '\celebration\empty.txt'],'w');
fprintf(fid,'%11.6f\t',CL);
fclose(fid);
fid=fopen([local_address '\celebration\efull.txt'],'w');
fprintf(fid,'%11.6f\t',CH);
fclose(fid);

fid=fopen([local_address '\celebration\LMC.txt'],'w');
for i=1:NumImageElem
    fprintf(fid,'%11.6f\t',S(:,i));
    fprintf(fid,"\n");
end
fclose(fid);