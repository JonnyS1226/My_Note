function [JPEGLS_coderoutput1]=GolombCoding(JPEGLS_coderoutput1, MErrval, k, LIMIT,qbpp)

val1 = floor(MErrval/(2^k)); %Merrval/2^K����
        val2 = val1*(2^k);
        val3 = LIMIT-qbpp-1; 
        if val1<val3
            temp=char();
            for i=1:val1 
                temp(i)='0';
            end
            JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,temp);%д��val1��0
            JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,'1');%д��1��1
%             clear temp
            val4=MErrval-val2;%MErravl/2^K������
            if length(dec2bin(val4))<k
                count=k-length(dec2bin(val4));
                temp=char();
                for i=1:count
                    temp(i)='0';
                end
                JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,temp);%����λ�ϲ�0
                JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,dec2bin(val4));%д�볤��ΪK������
%                 clear temp
            else
                if k~=0
                    JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,dec2bin(val4));%ֱ��д�볤��ΪK������,���kΪ0����ʲô����д
                end
            end
        else
            temp=char();
            for i=1:val3 
                temp(i)='0';
            end
            JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,temp);%д��val3��0
            JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,'1');%д��1��1
%             clear temp
            if length(dec2bin(MErrval-1))<qbpp
                count=qbpp-length(dec2bin(MErrval-1));
                temp=char();
                for i=1:count
                    temp(i)='0';
                end
                JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,temp);%����λ�ϲ�0
                JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,dec2bin(MErrval-1));%д�볤��Ϊqbpp������
            else
                JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,dec2bin(MErrval-1));%ֱ��д�볤��Ϊqbpp������
            end
        end
        