%������������ʾJPEG-LS��ѹ���㷨����
%    C B D
%    A X         % X��Ҫ���������

function [Re_image,totaloutput]=losslessJPEG_decoder(totaloutput)
global bayerimage0

%Ϊͼ��image�趨����ռ䣬���ӵ�һ�У���һ�У����һ�С�
Re_image=zeros(40+1,240+2);%image������6��40��,�������趨��������������ݣ���󷵻�ʱɾȥ��һ�е�һ�����һ��~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

%N �����ı����ֵĸ��ʣ�0-364����ģʽ  365-366�γ�  ��ʼ��Ϊ1
%A �ۼ�Ԥ�����,0-364����ģʽ  365-366�γ�    ��ʼ��Ϊtmp
%B ����ƫ��,0-364����ģʽ  ��ʼ��Ϊ0
%C Ԥ������ֵ,0-364����ģʽ  ��ʼ��Ϊ0
%Nn  ��֪����������
tmp=max(2,floor((RANGE+32)/64));
A(1,1:365)=tmp;%����matlab��c���鿪ͷ��Ų�ͬ���Ժ���ܻ�����������⣡����������������������������
N(1,1:365)=1;
B(1,1:365)=0;
C(1,1:365)=0;
Nn(1,1:365)=0;

A(365+1)=tmp;
A(366+1)=tmp;
N(365+1)=1;
N(366+1)=1;
      
RUNindex=1;%�����ʲô���������������ָ����ܵøĳ�1����������������������������������������
RUNindex_prev=1;%�������Լ��ӵġ����ӵĻ��ñ���û�г�ʼֵ����ע����֤~~~~~~~~~~~~~~~~~~~~~~~~~~
Nn(365+1)=0;
Nn(366+1)=0;

J(1,1:32)=[0 0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 4 4 5 5 6 6 7 7 8 9 10 11 12 13 14 15];
totalpixnumber=0;%���ر�ţ��ܹ�������ͼ�������ܸ���
x=2;%�к�
y=1;%�к�

%��ʼ��һ��һ�����ػָ���䵽Re_image��
while x*y<length(Re_image(:,1))*(length(Re_image(1,:))-1)
%     totalpixnumber=totalpixnumber+1;%ȡ�¸�����
%     decode.totalpixnumber(totalpixnumber)=totalpixnumber
%     totalpix  number
%     x=1+ceil(totalpixnumber/(length(Re_image(1,:))-2));%���ص��к�
%     y=1+totalpixnumber-(x-2)*(length(Re_image(1,:))-2);%���ص��к�

    if y>=length(Re_image(1,:))-1%ȡ�¸�����
        x=x+1;
        y=2;
    else
        y=y+1;
    end
    %ȡ��x,a,b,c,d��ֵ  IxΪ����ֵ    Ra,Rb,Rc,RdΪ�ؽ�ֵ������ѹ�����õ�������ֵ
    Ix=Re_image(x,y);
    Ra=Re_image(x,y-1);
    Rb=Re_image(x-1,y);
    Rc=Re_image(x-1,y-1);
    Rd=Re_image(x-1,y+1);
    
    %����ֲ��ݶ�
    D(1) = Rd - Rb;
    D(2) = Rb - Rc;
    D(3) = Rc - Ra;
    
    %�˴�Ӧ���ݲ�ͬ�ݶ�ѡ���γ̱��뷽ʽ���߳��淽ʽ
    if (D(1)==NEAR)& (D(2)==NEAR) & (D(3)==NEAR) %����ݶ�Ϊ0��������γ̱���ģʽ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %��ʼ������
        i=0;
        cnt=0;
        run_flag=0;
        glimit=0;
        
%         decodeoutput1{totalpixnumber}=totaloutput
        %Scanning
        while 1
            run_flag=0;
            R=totaloutput(1);
            totaloutput(1)=[];%��totaloutput�ж�ȡһ��bit
            if R=='1'%ȡ��bitΪ1
                if length(Re_image(1,:))-1-y+1>=2^J(RUNindex)%���ﲻ�Ⱥ�ǰ�����ֵ������1���ҵ���Ҫ����~~~~~~~~~~~~~~~~~~~
                    for i=0:(2^J(RUNindex))-1
                        Re_image(x,y+i)=Ra;
                        %!!!!!!!!!!!!!!!!!!!!���ʱ��2010.6.27 17:12��ͼ����������������������δ��ֵ
                        if (y+i==2)&(x<length(Re_image(:,1)))
                            Re_image(x+1,1)=Ra;
                        end
                        if (y+i==(length(Re_image(1,:))-1))
                            Re_image(x,y+i+1)=Ra;
                        end
                        %!!!!!!!!!!!!!!!!!!!!
                    end
                    y=y+2^J(RUNindex); %��������������
%                     totalpixnumber=totalpixnumber+2^J(RUNindex);%���ر�����ӣ������Լ��ӵģ�����Ҫ��~~~~~~~~~~~~~~~~~~~~~~~~~~
%                     decode.totalpixnumber(totalpixnumber)=totalpixnumber
                    if RUNindex<32%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        RUNindex_prev=RUNindex;
                        RUNindex=RUNindex+1;
                    end
                
                else
                    for i=y:(length(Re_image(1,:))-1)%������94�����һ��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        Re_image(x,i)=Ra;
                        %!!!!!!!!!!!!!!!!!!!!���ʱ��2010.6.27 17:12��ͼ����������������������δ��ֵ
                        if (i==2)&(x<length(Re_image(:,1)))
                            Re_image(x+1,1)=Ra;
                        end
                        if (i==(length(Re_image(1,:))-1))
                            Re_image(x,i+1)=Ra;
                        end
                        %!!!!!!!!!!!!!!!!!!!!
                    end
%                     totalpixnumber=totalpixnumber+length(Re_image(1,:))-1-y;%���ر�����ӣ������Լ��ӵģ�����Ҫ��~~~~~~~~~~~~~~~~~~~~~~~~~~
%                     decode.totalpixnumber(totalpixnumber)=totalpixnumber
                    %��һ��������ġ�����y�����ˣ���ôtotalpixnumberҲ��Ӧ���ӣ�����Ӧ��Ҳһ���ɡ�2010.6.25 21.23%%%%
%                     totalpixnumber=totalpixnumber+length(Re_image(1,:))-1-y;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    y=length(Re_image(1,:))-1;%һ�е����һ������
                    break
                end
            else %ȡ��bitΪ0��˵���γ���ֹ�����н������������ز����
                if J(RUNindex)~=0
                    for i=1:J(RUNindex)
                        temp=totaloutput(1);
                        totaloutput(1)=[];
                        cnt=cnt+(temp-'0')*(2^(J(RUNindex)-i));
                    end
                end
                if cnt>0
                    for i=0:cnt-1
                        Re_image(x,y+i)=Ra;
                        %!!!!!!!!!!!!!!!!!!!!���ʱ��2010.6.27 17:12��ͼ����������������������δ��ֵ
                        if (y+i==2)&(x<length(Re_image(:,1)))
                            Re_image(x+1,1)=Ra;
                        end
                        if (y+i==(length(Re_image(1,:))-1))
                            Re_image(x,y+i+1)=Ra;
                        end
                        %!!!!!!!!!!!!!!!!!!!!
                    end
                end
                y=y+cnt;
%                 totalpixnumber=totalpixnumber+cnt;%���ر�����ӣ������Լ��ӵģ�����Ҫ��~~~~~~~~~~~~~~~~~~~~~~~~~~
%                 decode.totalpixnumber(totalpixnumber)=totalpixnumber
                
                if RUNindex>1%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    RUNindex_prev=RUNindex;
                    RUNindex=RUNindex-1;
                end
                run_flag=1;  %ȡ����bit0,��Ҫ�����γ��ж����ؽ��롣
                break                
            end
            if y>length(Re_image(1,:))-1
                y=length(Re_image(1,:))-1;
                %��һ��������ġ�����y�����ˣ���ôtotalpixnumberҲ��Ӧ���ӣ�����Ӧ��Ҳһ���ɡ�2010.6.25 21.23%%%%
%                 totalpixnumber=totalpixnumber+length(Re_image(1,:))-1-y;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                break
            end
        end
        
%         '------------------------------------------'
%         RUNindex,run_flag,Ra
        
        if run_flag==1
            %Index computation
            y=y-1;
%             totalpixnumber=totalpixnumber-1;
            
            %SetSample()
%             totalpixnumber=totalpixnumber+1;%ȡ�¸�����
%             x=1+ceil(totalpixnumber/(length(Re_image(1,:))-2));%���ص��к�
%             y=1+totalpixnumber-(x-2)*(length(Re_image(1,:))-2);%���ص��к�
            if y>=length(Re_image(1,:))-1%ȡ�¸�����
                x=x+1;
                y=2;
            else
                y=y+1;
            end
            
            %ȡ��x,a,b,c,d��ֵ  IxΪ����ֵ    Ra,Rb,Rc,RdΪ�ؽ�ֵ������ѹ�����õ�������ֵ
            Ix=Re_image(x,y);
            Ra=Re_image(x,y-1);
            Rb=Re_image(x-1,y);
            Rc=Re_image(x-1,y-1);
            Rd=Re_image(x-1,y+1);
            %����ֲ��ݶ�
            D(1)=Rd-Rb;
            D(2)=Rb-Rc;
            D(3)=Rc-Ra;
            if Ra==Rb
                RItype=1;
            else
                RItype=0;
            end
            
            %Computation of auxiliary variable in Golomb parameter
            if RItype==0
                TEMP=A(365+1);%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            else
                TEMP=A(366+1)+floor(N(366+1)/2);%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            end
            q=RItype+365+1;
            k=ceil(log2(TEMP/N(q)));
            if k<0
                k=0;
            end %�˴����⣬k�Ƿ����Ϊ�����Ƿ���Ҫǿ������ڵ����㣬�볣������д���һ��~~~~~~~~~~~~
            
%             refork.q(totalpixnumber)=q
%             decode.RItype(totalpixnumber)=RItype
%             refork.TEMP(totalpixnumber)=TEMP
%             refork.Nq(totalpixnumber)=N(q)
%             refork.k(totalpixnumber)=k
            
            %����golomb����
            glimit=LIMIT-J(RUNindex_prev)-1;
            
%             decode.k(totalpixnumber)=k
%             decodeoutput2{totalpixnumber}=totaloutput
            
            [EMErrval,totaloutput]=GolombDecoding(totaloutput,k, glimit,qbpp);
            
%             RItype,q,k,EMErrval,glimit
%             
%             decode.EMErrval(totalpixnumber)=EMErrval
%             
%             decodeoutput3{totalpixnumber}=totaloutput
            
            if mod(EMErrval,2)==1
                if RItype==1
                    map=0;
                else
                    map=1;
                end
                Errval=floor((EMErrval+1)/2);
            else
                if RItype==1 
                    Errval=floor((EMErrval+2)/2);
                    map=1;
                else
                    Errval=floor(EMErrval/2);
                    map=0;
                end
            end
%             decode.map{totalpixnumber}=map
%             decode.Errval_begin{totalpixnumber}=Errval
            
            %correct the sign of the map fun. 
            if (k==0)&&(map==0)&&(2*Nn(q)<N(q))
                Errval=-Errval;
            elseif (map==1)&&(2*Nn(q)>=N(q))
                Errval=-Errval;
            elseif (map==1)&&(k~=0)
                Errval=-Errval;
            end
            
            %Error computation for a run interruption sample
            if (RItype==0)&&(Rb<Ra)
                Errval=-Errval;
            end
%             decode.Errval_end{totalpixnumber}=Errval
            
                        
            %Adding prediction error for a run interruption sample
            if RItype==1
                if Errval+Ra>=0%��������жϣ���ȫ����Ϊc��matlab����ģ������һ��~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    Rx=mod((Errval+Ra),RANGE);
                else
                    Rx=-mod((-Errval-Ra),(RANGE*(2*NEAR+1)));
%                     Rx=mod((-Errval-Ra),RANGE);%�˴�����Ҫ�޸�2010.6.14-15��15
                end
            else
                if Errval+Rb>=0%��������жϣ���ȫ����Ϊc��matlab����ģ������һ��~~~~~~~~~~~~~~~~~~~~~~~~
                    Rx=mod((Errval+Rb),RANGE);
                else
                    Rx=-mod((-Errval-Rb),(RANGE*(2*NEAR+1)));
%                     Rx=mod((-Errval-Rb),RANGE);%�˴�����Ҫ�޸�2010.6.14-15��15
                end
            end
            
            if Rx<0
                Rx=Rx+RANGE;
            else
                if Rx>MAXVAL+NEAR
                    Rx=Rx-RANGE;
                end
            end
            
            if Rx<0
                Rx=0;
            else
                if Rx>MAXVAL
                    Rx=MAXVAL;
                end
            end
            
            Re_image(x,y)=Rx;
%             Errval,Rx
%             decode.Rx{totalpixnumber}=Rx
            
            %!!!!!!!!!!!!!!!!!!!!���ʱ��2010.6.22 14:54��ÿ��ת�оͽ������������ͼ����������������������δ��ֵ������0
            if (y==2)&(x<length(Re_image(:,1)))
                Re_image(x+1,1)=Rx;
            end
            if (y==(length(Re_image(1,:))-1))
                Re_image(x,y+1)=Rx;
            end
            %!!!!!!!!!!!!!!!!!!!!
            
            %update of parameters for run interruption sample
            if Errval<0
                Nn(q)=Nn(q)+1;
            end
            A(q)=A(q)+floor((EMErrval+1-RItype)/2);
            if N(q)==RESET
                A(q)=floor(A(q)/2);
                N(q)=floor(N(q)/2);
                Nn(q)=floor(Nn(q)/2);
            end
            N(q)=N(q)+1;            
        end     
%      A(q),N(q),Nn(q)
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
        q=81*Q(1)+9*Q(2)+Q(3)+1;    %������ǰ��+1�ģ�����matlab�����һ����Ų���Ϊ0
        
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

        %����Kֵ
        if A(q)/N(q)==0
            k=0;
        else
            k=floor(log2(A(q)/N(q)));
        end
        if k<0 
            k=0;
        end%~~~~~~~~~~~~~~~~~~~~~~~~~~~ż������k<0���֣�,���Ӹ�if
        
        
        %�������glomb����
        [MErrval,totaloutput]=GolombDecoding(totaloutput,k, LIMIT,qbpp);

        %ͨ��MErrval,����Errval���ͱ��������෴
        if (NEAR==0)&&(k==0)&&(2*B(q)<=-N(q)) 
            if mod(MErrval,2)~=0               %~~~~~~~~~~~~~~~~~~~~~~ԭ���ļ�����MErrval&1��������
                Errval=floor((MErrval-1)/2);
            else
                Errval=-(floor(MErrval/2))-1;
            end
        else
            if mod(MErrval,2)==0            %~~~~~~~~~~~~~~~~~~~~~~~~~ԭ���ļ�����MErrval&1��������
                Errval=floor(MErrval/2);
            else
                Errval=-floor((MErrval+1)/2);
            end
        end
        
        %����A,B,N����
        B(q)=B(q)+Errval*(2*NEAR+1);
        A(q)=A(q)+abs(Errval);
        if N(q)==RESET
            A(q)=floor(A(q)/2);
            B(q)=floor(B(q)/2);
            N(q)=floor(N(q)/2);
        end
        N(q)=N(q)+1;
        
        %�����Errval����һЩ����
        if NEAR>0
            Errval=Errval*(2*NEAR+1);
        end
        if SIGN==-1
            Errval=-Errval;
        end
   
        %������ؽ�ֵ
        Rx=(Errval+Px);%(RANGE*(2*NEAR+1));
        
        %RX����
        if Rx<-NEAR
            Rx=Rx+RANGE*(2*NEAR+1);
        else
            if Rx>(MAXVAL+NEAR)
                Rx=Rx-RANGE*(2*NEAR+1);
            end
        end
        
        %RX����
        if Rx<0
            Rx=0;
        else 
            if Rx>MAXVAL
                Rx=MAXVAL;
            end
        end
        
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
        
        %д��������棬�Ժ�ļ�����Ҫ�õ���ֵ
        Re_image(x,y)=Rx;
        if (y==2)&(x<length(Re_image(:,1)))
                Re_image(x+1,1)=Rx;
            end
            if (y==(length(Re_image(1,:))-1))
                Re_image(x,y+1)=Rx;
            end
        %ͬʱ���ָ�ͼ���м�������������������ı߽������е�����Ҳ��Ҫ���
        %����ʱ��ֱ�Ӱ�ǰ�����ж������ˣ�����ڱ߽�����ʱ��a,b,c,dֱ�Ӹ�������ȡֵ�ͺ��ˡ�
        %����ʱ��û�������������ݣ�����ڱ߽�����ʱ��abcdȡֵʱҪ�����
        if (x<length(Re_image(:,1)))&(y==2)
            Re_image(x+1,1)=Rx;%��һ�����ݵ���ǰһ�еڶ�������
        end
        if y==(length(Re_image(1,:))-1)
            Re_image(x,y+1)=Rx;%��42�����ݵ��ڵ�41������
        end
        

    end
end

tmp=Re_image(2:end,2:end-1);
Re_image=tmp;%�������õ���ʱ������ĵ�һ�е�һ�����һ��ɾ��
