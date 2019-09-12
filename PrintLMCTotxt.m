local_address=pwd;
mkdir(local_address,'calibration');
fid=fopen([local_address '\calibration\empty.txt'],'w');
fprintf(fid,'%11.6f\t',CL);
fclose(fid);
fid=fopen([local_address '\calibration\efull.txt'],'w');
fprintf(fid,'%11.6f\t',CH);
fclose(fid);

fid=fopen([local_address '\calibration\LMC.txt'],'w');
for i=1:NumImageElem
    fprintf(fid,'%11.6f\t',S(:,i));
    fprintf(fid,"\n");
end
fclose(fid);