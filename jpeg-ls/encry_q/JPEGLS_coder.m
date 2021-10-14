%������������ʾJPEG-LSѹ���㷨����
%    C B D
%    A X         % X��Ҫ���������
function [JPEGLS_coderoutput1,JPEGLS_coderoutput2, code_index]=JPEGLS_coder(image, code_index, ans_code)

JPEGLS_coderoutput1=[];
JPEGLS_coderoutput2=[];

%Pͼ����ֵ�ľ���
P=8;
%NEAR��������
NEAR=0;
%threshold value at which A, B, and N are halved 
RESET=64;
%maximum allowed value of C[1..365]
MAX_C=127;
%minimum allowed value of C[1..365]
MIN_C=-128;
%����T1,T2,T3�ĳ�ֵ
T1=18;
T2=67;
T3=276;
%����Pֵ������������ϵ����ֵMAXVAL=2^P-1.
MAXVAL=2^P-1;
% RANGE=((MAXVAL+2*NEAR)/(2*NEAR+1))+1
RANGE=MAXVAL+1;%ֻ��������ѹ��ʱ��ֵ
%ӳ������ֵ�����λ��
qbpp=ceil(log2(RANGE));
%MAXVAL�����λ������СΪ2
bpp=max(2,ceil(log2(MAXVAL+1)));
%LIMIT��ʾ�ڳ���ģʽ�£�����������ʱ��glimitֵ������Golomb����ʱ����������ĳ���
LIMIT=2*(bpp+max(8,bpp));

%Ϊͼ��image���ӵ�һ�У���һ�У����һ�С�image������6��40��
TEMP=zeros(length(image(:,1))+1,length(image(1,:))+2);
TEMP(2:end,2:(end-1))=image;
TEMP(1,:)=0;%��һ������Ϊ��
TEMP(2:end,1)=TEMP(1:(end-1),2);%��һ�и���Ԫ�ص��ڵڶ�����һ��Ԫ��
TEMP(:,length(image(1,:))+2)=TEMP(:,length(image(1,:))+1);%���һ�е��ڵ����ڶ���
image=TEMP;
clear TEMP

%N �����ı����ֵĸ��ʣ�0-364����ģʽ  365-366�γ�  ��ʼ��Ϊ1
%A �ۼ�Ԥ�����,0-364����ģʽ  365-366�γ�    ��ʼ��Ϊtmp
%B ����ƫ��,0-364����ģʽ  ��ʼ��Ϊ0
%C Ԥ������ֵ,0-364����ģʽ  ��ʼ��Ϊ0
%Nn  ��֪����������
tmp=max(2,floor((RANGE+32)/64));
A(1,1:365)=tmp;
N(1,1:365)=1;
B(1,1:365)=0;
C(1,1:365)=0;
Nn(1,1:365)=0;%���������γ���ֹʱ��������Ÿ�Ԥ�����ֵ����ʼ��Ϊ0

A(365+1)=tmp;
A(366+1)=tmp;
N(365+1)=1;
N(366+1)=1;
      
RUNindex=1;
RUNindex_prev=1;%�������Լ��ӵġ����ӵĻ��ñ���û�г�ʼֵ����ע����֤~~~~~~~~~~~~~~~~~~~~~~~~~~
Nn(365+1)=0;
Nn(366+1)=0;
J(1,1:32)=[0 0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 4 4 5 5 6 6 7 7 8 9 10 11 12 13 14 15];


%��ÿ������ͳ���������Ļ��������б���
totalpixnumber=0;%���ر�ţ��ܹ�������ͼ�������ܸ���
x=0;%�к�
y=0;%�к�

while totalpixnumber<(length(image(:,1))-1)*(length(image(1,:))-2) %�����ܸ���
    totalpixnumber=totalpixnumber+1;%ȡ�¸�����
    x=1+ceil(totalpixnumber/(length(image(1,:))-2));%���ص��к�
    y=1+totalpixnumber-(x-2)*(length(image(1,:))-2);%���ص��к�
    %ȡ��x,a,b,c,d��ֵ  IxΪ����ֵ    Ra,Rb,Rc,RdΪ�ؽ�ֵ������ѹ�����õ�������ֵ
    Ix=image(x,y);
    Ra=image(x,y-1);
    Rb=image(x-1,y);
    Rc=image(x-1,y-1);
    Rd=image(x-1,y+1);
    
    %����ֲ��ݶ�
    D(1) = Rd - Rb;
    D(2) = Rb - Rc;
    D(3) = Rc - Ra;
    
    %�˴�Ӧ���ݲ�ͬ�ݶ�ѡ���γ̱��뷽ʽ���߳��淽ʽ
    if (D(1)==0)& (D(2)==0) & (D(3)==0) %����ݶ�Ϊ0��������γ̱���ģʽ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EOLine=(y==(length(image(1,:))-1)); %EOLine���н�����־��1��ʾ�н���
        RUNval=Ra;
        RUNcnt=0;
        while (abs(Ix-RUNval)<=NEAR)
            RUNcnt=RUNcnt+1;
            Rx=RUNval;
            if EOLine==1
                break;
            else
                totalpixnumber=totalpixnumber+1;%ȡ�¸�����
                x=1+ceil(totalpixnumber/(length(image(1,:))-2));%���ص��к�
                y=1+totalpixnumber-(x-2)*(length(image(1,:))-2);%���ص��к�
                Ix=image(x,y);    
                Ra=image(x,y-1);
                Rb=image(x-1,y);
                Rc=image(x-1,y-1);
                Rd=image(x-1,y+1);
                D(1) = Rd - Rb;
                D(2) = Rb - Rc;
                D(3) = Rc - Ra;
                EOLine=(y==length(image(1,:))-1);
                RUNval=Ra;
            end
        end

        %Encoding of run segments of length rm 
        while RUNcnt>=(2^J(RUNindex))
            JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,'1');%д��1��'1'��������
            RUNcnt=RUNcnt-2^J(RUNindex);
            if RUNindex<32
                RUNindex_prev = RUNindex;
                RUNindex=RUNindex+1;
            end
        end
    
        %Encoding of run segments of length less than rm
        if Ra~=Ix
            JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,'0');%д��1��'0'�������� 
            
            %�������Ƶ�RUNcntд��������У�ռ��J(RUNindex)��bit
            if length(dec2bin(RUNcnt))<J(RUNindex)
                for i=1:J(RUNindex)-length(dec2bin(RUNcnt))
                    JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,'0');%д��J(RUNindex)-length(dec2bin(RUNcnt))��'0'��������
                end
                JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,dec2bin(RUNcnt));%д������Ƶ�RUNcnt��������
            else
                if length(dec2bin(RUNcnt))>=J(RUNindex)%��RUNcnt��ȡ����J(RUNindex)λ�����
                    temp=char();
                    temp=dec2bin(RUNcnt);
                    temp=temp(1+length(dec2bin(RUNcnt))-J(RUNindex):length(dec2bin(RUNcnt)));
                    JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,temp);%д������Ƶ�RUNcnt��������
                    clear temp
                end
            end
            
            if(RUNindex>1)%�����ǰһ��������ͬ����һ�н���
                 RUNindex_prev=RUNindex;
                RUNindex=RUNindex-1;
            end
        else 
            if(RUNcnt>0)
                JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,'1');%д��1��'1'��������
            end
        end
           
        %���������γ��жϺ�����ؽ��б��룬�ͳ�����������Ƶĵط�
        if Ra~=Ix
            %Index computation
            if Ra==Rb
                RItype=1;
            else
                RItype=0;
            end
            %Prediction error for a run interruption sample
            if RItype==1
                Errval=Ix-Ra;
            else
                Errval=Ix-Rb;
            end
            encode.Errval_begin{totalpixnumber}=Errval;
            %Error computation for a run interruption sample
            if (RItype==0) && (Ra>Rb)
                Errval=-Errval;
                SIGN=-1;
            else
                SIGN=1;
            end
            
            Rx = Ix;
                       
            %Modulo reduction of the error
            if(Errval < 0)
                Errval = Errval + RANGE;
            end
            if(Errval >= floor((RANGE+1)/2))
                Errval = Errval - RANGE;
            end

            %Computation of auxiliary variable in Golomb parameter
            %ֻ�õ�365,366��������λ�ã�0-364Ϊ����������λ��
            if RItype==0
                TEMP=A(365+1);
            else
                TEMP=A(366+1)+floor(N(366+1)/2);
            end
            q=RItype+365+1;
            k=ceil(log2(TEMP/N(q)));
            if k<0
                k=0;
            end
            
            %Computation of map for Errval mapping
            if (k==0)&&(Errval>0)&&(2*Nn(q)<N(q))
                map=1;
            else
                if (Errval<0)&&(2*Nn(q)>=N(q))
                    map=1;
                else
                    if (Errval<0)&&(k~=0)
                        map=1;
                    else
                        map=0;
                    end
                end
            end
            
            %Errval mapping for run interuption sample
            EMErrval=2*(abs(Errval))-RItype-map;
            
            %Mapped-error encoding
            %�Ѿ����ƥ���������golomb����
            glimit=LIMIT-J(RUNindex_prev)-1;            
            [JPEGLS_coderoutput1]=GolombCoding(JPEGLS_coderoutput1, EMErrval, k, glimit, qbpp);
            
            %update of parameters for run interruption sample���²���
            if Errval<0
                Nn(q)=Nn(q)+1;
            end
            A(q)=A(q)+floor((EMErrval+1-RItype)/2);
            if(N(q)==RESET)
                A(q)=floor(A(q)/2);
                N(q)=floor(N(q)/2);
                Nn(q)=floor(Nn(q)/2);
            end
            N(q)=N(q)+1;
        end                 
    else %����ݶȲ�Ϊ0������ó������ģʽ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %�ֲ��ݶ�����  ��D�����Q
        for i=1:3
            if D(i)<=-T3
                Q(i)=-4;
                elseif D(i)<=-T2
                    Q(i)=-3;
                elseif D(i)<=-T1
                    Q(i)=-2;
                elseif D(i)<-NEAR
                    Q(i)=-1;
                elseif D(i)<=NEAR
                    Q(i)=0;
                elseif D(i)<T1
                    Q(i)=1;
                elseif D(i)<T2
                    Q(i)=2;
                elseif D(i)<T3
                    Q(i)=3;
                else Q(i)=4;
            end
        end
            
        %�����ݶ��ں�  ��Q�����Q��SIGN
        if Q(1)<0
            Q(1)=-Q(1);
            Q(2)=-Q(2);
            Q(3)=-Q(3);
            SIGN=-1;
            elseif Q(1)==0
                if Q(2)<0
                    Q(2)=-Q(2);
                    Q(3)=-Q(3);
                    SIGN=-1;
                    elseif (Q(2)==0) && (Q(3)<0)
                        Q(3)=-Q(3);
                        SIGN=-1;
                    else SIGN=1;
                end
            else SIGN=1;
        end
        
        %The Maping step to detrmin Q
        q=81*Q(1)+9*Q(2)+Q(3)+1;   
        
%         ���ܵ�2 ��q����
        if mod(q, 2) == 0 || mod(q, 3) == 0 || mod(q, 5) == 0
            q = mod(bitshift(q, ans_code(code_index)), 365) + 1;
        end
        
        code_index = code_index + 1;
        
        
        %���ջ�������Ԥ��Px
        if Rc>=max(Ra,Rb)
            Px=min(Ra,Rb);
        else 
            if Rc<=min(Ra,Rb)
                Px=max(Ra,Rb);
            else
                Px=Ra+Rb-Rc;
            end
        end
              
        %Ԥ��ֵPx����
        if SIGN==1
            Px=Px+C(q);
        else
            Px=Px-C(q);
        end
        if Px>MAXVAL
            Px=MAXVAL;
        else
            if Px<0
                Px=0;
            end
        end
        
        %Ԥ��������
        Errval=Ix-Px;
        if SIGN==-1
            Errval=-Errval;
        end
        
        %����ѹ�����ؽ�ֵ=����ֵ
        Rx=Ix;
        
        %Ԥ��������Ʒ�Χ
        if Errval<0
            Errval=Errval+RANGE;
        end
        if Errval>=(RANGE+1)/2
            Errval=Errval-RANGE;
        end
        
        %�����Ԥ�������б���
        %����Kֵ
        if A(q)/N(q)==0
            k=0;
        else
            k=floor(log2(A(q)/N(q)));
        end
        if k<0 
            k=0;
        end
        % ���ܵ�1 ��k����
%         k = bitxor(k, 1);
        %��Ԥ�����ӳ��Ϊ�Ǹ�����
        if (NEAR==0) && (k==0) && (2*B(q)<=N(q))
            if Errval>=0
                MErrval=2*Errval+1;
            else
                MErrval=-2*(Errval+1);
            end
        else
            if Errval>=0
                MErrval=2*Errval;
            else
                MErrval=-2*Errval-1;
            end
        end

        
        %��ʼgolomb���룬���ɵĶ��������ݴ����JPEGLS_coderoutput1�У�JPEGLS_coderoutput2Ϊ��
        [JPEGLS_coderoutput1]=GolombCoding(JPEGLS_coderoutput1, MErrval, k, LIMIT, qbpp);


        %����A,B,N����
        B(q)=B(q)+Errval*(2*NEAR+1);
        A(q)=A(q)+abs(Errval);
        if N(q)==RESET
            A(q)=floor(A(q)/2);
            B(q)=floor(B(q)/2);
            N(q)=floor(N(q)/2);
        end
        N(q)=N(q)+1;
        
        %����B,C����
        if B(q)<=-N(q) 
            B(q)=B(q)+N(q);
            if C(q)>MIN_C
                C(q)=C(q)-1;
            end
            if B(q)<=-N(q)
                B(q)=-N(q)+1;
            end
        elseif B(q)>0
            B(q)=B(q)-N(q);
            if C(q)<MAX_C
                C(q)=C(q)+1;
            end
            if B(q)>0
                B(q)=0;
            end
        end
    end  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

        
end



