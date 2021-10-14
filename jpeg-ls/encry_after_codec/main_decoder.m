%����6x40�Ĵ�С���ζ�ȡͼ��ĸ�������
%ͼ���СΪx*y,����ȡ48��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global bayerimage0 
% load codebook_step1%�����뱾
% step=1;%ѹ������Ϊ2
x=240;%ͼ�������
y=240;%ͼ�������
xx=40;%����Ԫ������
yy=240;%����Ԫ������
z=0;%ROI��ʼ����
w=0;%ROI��ʼ����
q=0;%ROI��������
p=0;%ROI��������


t0=cputime;%��ʼ��ʱ


%%
%%% 2.����Logistic��������
% u=3.990000000000001; %��Կ�����Բ���  10^-15
%u=3.99;%��Կ��Logistic������
% x0=0.7067000000000001; %��Կ�����Բ���  10^-16
% x0=0.5475; %��Կ��Logistic��ֵx0
SUM = x * y;
% x0 = 0.5;
x0 = 0.5475

p=zeros(1,SUM+1000);
p(1)=x0;
for i=1 : 999 + length(totaloutput)                 %����SUM+999��ѭ�������õ�SUM+1000�㣨������ֵ��
    p(i+1)=u*p(i)*(1-p(i));
end
p=p(1001:length(p));

p = mod(round(p*10^4),2);
% R = reshape(p,N,M)';  %ת��M��N�е��������R

curOutput = zeros(0, length(totaloutput));
for i = 1 : length(totaloutput)
    if (totaloutput(i) == '0') 
        curOutput(i) = 0;
    else 
        curOutput(i) = 1;
    end
end

res = bitxor(p, curOutput);
for i = 1 : length(totaloutput)
    if (res(i) == 0) 
        totaloutput(i) = '0';
    else
        totaloutput(i) = '1';
    end
end

%%
for k=1:6
    k
    [Re_A,totaloutput]=JPEGLS_decoder(totaloutput);
    for i=xx:-1:2%�Բ�ɫ����ͼ���д�ֱ���˲�
        Re_A(i,:)=2*Re_A(i,:)-Re_A(i-1,:);
    end
        
    for i=yy:-1:2%�Բ�ɫ����ͼ����ˮƽ���˲�
        Re_A(:,i)=2*Re_A(:,i)-Re_A(:,i-1);
    end
    
    Re_A0(1+40*(k-1):40*k,:)=Re_A;%ͼ��Ľ���
end

time=cputime-t0%��ʱ����

clear  t0 time

        




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����к��bayerͼ�ظ���������BAYER��ʽͼ��
%Ԥ�����а�bayerͼ���и�������������
%���������
temp1=zeros(1,y/2);
temp2=zeros(1,y/2);
for i=1:x%��ÿһ���ڵ�������������һ�£���ɫ����ߣ�������ɫ�ߵ�˳�����ұߡ������������
    if mod(i,2)==1%�����������
        temp1=Re_A0(i,1:y/2);%��ɫG1
        temp2=Re_A0(i,(y/2)+1:end);%��ɫB
        Re_A0(i,1:2:y-1)=temp2(end:-1:1);%��B�ߵ�˳������������
        Re_A0(i,2:2:y)=temp1;%��G1����ż����
    else
        temp1=Re_A0(i,1:y/2);%��ɫG2
        temp2=Re_A0(i,(y/2)+1:end);%��ɫR
        Re_A0(i,1:2:y-1)=temp1;%��G2���з���������
        Re_A0(i,2:2:y)=temp2(end:-1:1);%��R����ż����
    end
end
clear temp1 temp2

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����ͨbayer��Ƭת��������ɫ���׼RGB��ʽ
tempRe_A0=zeros(x,y,3);
for i=1:x
    for j=1:y%����
        if (mod(i,2)==1) & (mod(j,2)==1)
            tempRe_A0(i,j,3)=Re_A0(i,j);%B�����ŵ���3��
        else
            if (mod(i,2)==0) & (mod(j,2)==0)
                tempRe_A0(i,j,1)=Re_A0(i,j);%R�����ŵ���1��
            else
                tempRe_A0(i,j,2)=Re_A0(i,j);%G�����ŵ���2��
            end
        end
    end
end
Re_A0=tempRe_A0;
clear tempRe_A0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Re_A0=Re_A0*2;%��Ӧ��NEAR=1~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Re_A0=Re_A0*4;%��Ӧ��NEAR=2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
subplot(2,2,3),subimage(uint8(Re_A0)),title('�ָ�BAYERͼ��Re_A0')
bayerimage1=Re_A0;%����PSNR�õĲ�����ʵ��ʹ��ʱ��ɾ��



%��BAYER��ʽ��Ƭ���в�ֵ���ָ���ΪRGB��ɫ��Ƭ
for i=2:2:x-2
    Re_A0(i,:,3)=(Re_A0(i-1,:,3)+Re_A0(i+1,:,3))/2;
end
Re_A0(x,:,3)=Re_A0(x-1,:,3);

for i=2:2:y-2
    Re_A0(:,i,3)=(Re_A0(:,i-1,3)+Re_A0(:,i+1,3))/2;
end
Re_A0(:,y,3)=Re_A0(:,y-1,3);       %��Re_A0��Ƭ��B������ֵ�ָ�


for i=3:2:x-1
    Re_A0(i,:,1)=(Re_A0(i-1,:,1)+Re_A0(i+1,:,1))/2;
end
Re_A0(1,:,1)=Re_A0(2,:,1);

for i=3:2:y-1
    Re_A0(:,i,1)=(Re_A0(:,i-1,1)+Re_A0(:,i+1,1))/2;
end
Re_A0(:,1,1)=Re_A0(:,2,1);           %��Re_A0��Ƭ��R������ֵ�ָ�

Re_A0(1,1,2)=(Re_A0(2,1,2)+Re_A0(1,2,2))/2;
Re_A0(x,y,2)=(Re_A0(x,y-1,2)+Re_A0(x-1,y,2))/2;
for i=2:x-1
    if Re_A0(i,1,2)==0
        Re_A0(i,1,2)=(Re_A0(i+1,1,2)+Re_A0(i,2,2))/2;
    end
    if Re_A0(i,y,2)==0
        Re_A0(i,y,2)=(Re_A0(i-1,y,2)+Re_A0(i,y-1,2))/2;
    end
end
for j=2:y-1
    if Re_A0(1,j,2)==0
        Re_A0(1,j,2)=(Re_A0(2,j,2)+Re_A0(1,j+1,2))/2;
    end
    if Re_A0(x,j,2)==0
        Re_A0(x,j,2)=(Re_A0(x-1,j,2)+Re_A0(x,j-1,2))/2;
    end
end
for i=2:x-1
    for j=2:y-1
        if Re_A0(i,j,2)==0
            Re_A0(i,j,2)=(Re_A0(i+1,j,2)+Re_A0(i,j+1,2)+Re_A0(i-1,j,2)+Re_A0(i,j-1,2))/4;
        end
    end
end %��Re_A0��Ƭ��G������ֵ�ָ�


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ͼ������PSNR
A0=imread('lena.png');%����ͼ�񣬱�׼ͼ���СΪx*y~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
subplot(2,2,2),subimage(A0),title('ԭʼRGBͼ��A0')
Re_A0=uint8(Re_A0);%��������н�ͼ������Ԫ�ظĳ�double���ȣ������������Ҫת����uint8ģʽ
subplot(2,2,4),subimage(Re_A0),title('�ָ�RGBͼ��Re_A0')

A0_1D=zeros(1,x*y*3);%ͼ��A0��һά���
count=1;
for k=1:3
    for i=1:x %i��ʾͼ����ĳ���ص�����
        for j=1:y %j��ʾͼ����ĳ���ص�����
            A0_1D(count)=bayerimage0(i,j,k);%��Errorquant������Ԫ��ת�Ƶ���Errorquant_1D��
            count=count+1;                %Errorquant_1D��һά����
        end
    end
end

Re_A0_1D=zeros(1,x*y*3);%�ָ�ͼ��Re_A0��һά���
count=1;
for k=1:3
    for i=1:x %i��ʾͼ����ĳ���ص�����
        for j=1:y %j��ʾͼ����ĳ���ص�����
            Re_A0_1D(count)=bayerimage1(i,j,k);%��Errorquant������Ԫ��ת�Ƶ���Errorquant_1D��
            count=count+1;                %Errorquant_1D��һά����
        end
    end
end
MSE=sum((A0_1D-Re_A0_1D).^2)/length(A0_1D);
PSNR=10*log10((2^8-1)^2/MSE)%��ֵ�����
subplot(2,2,1),subimage(uint8(bayerimage0)),title('ԭʼBAYERͼ��A0')
% clear A0_1D Re_A0_1D count i j k MSE Re_A n totaloutput A0 Re_A0 A0_color Re_A0_color filter m;