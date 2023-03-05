clear all;
clc;
close all;

%%

folder='./SECU8917/';
d=dir(folder);
listSize=size(d,1);

%%

for i = 3:listSize
    values=strsplit(d(i).name,'_');
    filename=strcat(folder,d(i).name);
    keyList(i-2) = extractAfter(values(4),4);
    ptiList(i-2) = extractAfter(values(5),4);
    ctoList(i-2) = extractAfter(values(6),4);    
    tracesList(i-2,:)=csvread(filename);   
end

%%
save('keys.mat','keyList');
save('pti.mat','ptiList');
save('cto.mat','ctoList');
save('traces.mat','tracesList');

