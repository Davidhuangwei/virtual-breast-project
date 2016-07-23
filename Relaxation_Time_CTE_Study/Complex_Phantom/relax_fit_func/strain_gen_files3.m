% read displacement
%
% author: yu wang
% time: 8/31/2015

% revision: David Rosen
% date: 9/2/2015


function strain_gen_files2(Inputfile,Nodefile,Outputfile,stime)


if ~isstr(Inputfile)
    fprintf('Error: input argumenst must be strings')
    return
end

load(Inputfile)
strt=find(tm==stime);
time=tm(strt:end)-tm(strt);

node_id = fopen(Nodefile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read node coordernate and convert to Matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
interval=0.15; % interval for interpolation [mm]
data = textscan(node_id,'%f %f %f %f');
nodes = cell2mat(data);
NUM=nodes(1,1);
temp1=nodes(2:end,2);
temp2=nodes(2:end,3);
temp3=nodes(2:end,4);

X=temp2;
Y=-temp3;
Z=-temp1;

fclose(node_id)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% interpolation (matlab coordernate) step 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% region of interest

% ROI_x=188;
% ROI_y1=83;
% ROI_y2=103;
% ROI_z1=44;
% ROI_z2=55.5;

ROI_x1=83;
ROI_x2=103;
ROI_y1=-55.5;
ROI_y2=-44;
ROI_z=-188;

[Xq Yq Zq]=meshgrid(ROI_x1:interval:ROI_x2, ROI_y1:interval:ROI_y2, ROI_z);
% [Xq Yq Zq]=meshgrid(ROI_x, ROI_y1:interval:ROI_y2, ROI_z1:interval:ROI_z2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% interpolation (matlab coordernate) step 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for flag=1:length(Data4byN)-strt+1
 
  displace = Data4byN{flag+strt-1};
  temp1=displace(1:end,2);
  temp2=displace(1:end,3);
  temp3=displace(1:end,4);

  % coordinate convesion
  VX=temp2;
  VY=-temp3;
  VZ=-temp1;

  disp_y=griddata(X(:),Y(:),Z(:),VY(:), Xq, Yq, Zq);
  
  save_y(:,:,flag)=disp_y;
  flag=flag+1;


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate strain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=1:(flag-1)
  disp_mid=save_y(:,:,k);
  [M N]=size(disp_mid);
  dx=interval; % [mm]

  strain=zeros(M-2,N);
  for i=1:(M-2)
    for j=1:N
      strain(i,j)=abs(abs(disp_mid(i,j))-abs(disp_mid(i+2,j)))/(4*dx);
    end
  end

  strain_y(:,:,k)=abs(strain);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert data format for curve fitting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear data;
for i=1:(flag-1)
  temp=strain_y(:,:,i);
  data(:,i)=temp(:);
end
clear temp;

clear disp_y;
disp_y=save_y;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(Outputfile, 'data', 'time', 'strain_y', 'disp_y');














  
