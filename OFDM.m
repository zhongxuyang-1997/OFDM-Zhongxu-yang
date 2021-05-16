clc;
clear;


%% Parameter settings

N_sc=52;             % number of subcarrierA
N_fft=64;            % FFT length
N_cp=16;             % Cyclic prefix
N_symbo=N_fft+N_cp; 
N_c=53;              % number of carriers
M=4;                 %4PSK
SNR=0:1:25;          
N_frm=10;            %frame
Nd=6;                %Number of OFDM symbols in each frame
P_f_inter=6;         %Pilot interval
data_station=[];     %Pilot position
L=7;           
tblen=6*L;          % Viterbi decoder
stage = 3;          % order of m sequence
ptap1 = [1 3];      
regi1 = [1 1 1];   


%% Generation of Baseband data
P_data=randi([0 1],1,N_sc*Nd*N_frm);


%% Channel coding

trellis = poly2trellis(7,[133 171]);       %(2,1,7) convolutional coding
code_data=convenc(P_data,trellis);


%% qpsk modulation
data_temp1= reshape(code_data,log2(M),[])';            
data_temp2= bi2de(data_temp1);                            
modu_data=pskmod(data_temp2,M,pi/M);              
% figure(1);
scatterplot(modu_data),grid;                

%% Spread

code = mseq(stage,ptap1,regi1,N_sc);    
code = code * 2 - 1;        
modu_data=reshape(modu_data,N_sc,length(modu_data)/N_sc);
spread_data = spread(modu_data,code);        % Spread
spread_data=reshape(spread_data,[],1);

%% Insert pilot
P_f=3+3*1i;                       %Pilot frequency
P_f_station=[1:P_f_inter:N_fft];
pilot_num=length(P_f_station);

for img=1:N_fft                       
    if mod(img,P_f_inter)~=1          
        data_station=[data_station,img];
    end
end
data_row=length(data_station);
data_col=ceil(length(spread_data)/data_row);

pilot_seq=ones(pilot_num,data_col)*P_f;
data=zeros(N_fft,data_col);
data(P_f_station(1:end),:)=pilot_seq;

if data_row*data_col>length(spread_data)
    data2=[spread_data;zeros(data_row*data_col-length(spread_data),1)];
end;

%% Serial to Parallel
data_seq=reshape(data2,data_row,data_col);
data(data_station(1:end),:)=data_seq;

%% IFFT
ifft_data=ifft(data); 

%% Insert guard interval, cyclic prefix
Tx_cd=[ifft_data(N_fft-N_cp+1:end,:);ifft_data];

%% Parallel to Serial
Tx_data=reshape(Tx_cd,[],1);

%% channel
 Ber=zeros(1,length(SNR));
 Ber2=zeros(1,length(SNR));
for jj=1:length(SNR)
    rx_channel=awgn(Tx_data,SNR(jj),'measured'); %Add Gaussian white noise
    
%% Serial to Parallel
    Rx_data1=reshape(rx_channel,N_fft+N_cp,[]);
    
%% Remove guard interval and cyclic prefix
    Rx_data2=Rx_data1(N_cp+1:end,:);

%% FFT
    fft_data=fft(Rx_data2);
    
%% Channel estimation and interpolation
    data3=fft_data(1:N_fft,:); 
    Rx_pilot=data3(P_f_station(1:end),:); 
    h=Rx_pilot./pilot_seq; 
    H=interp1( P_f_station(1:end)',h,data_station(1:end)','linear','extrap')
   

%% Channel correction
    data_aftereq=data3(data_station(1:end),:)./H;
%% Parallel to Serial
    data_aftereq=reshape(data_aftereq,[],1);
    data_aftereq=data_aftereq(1:length(spread_data));
    data_aftereq=reshape(data_aftereq,N_sc,length(data_aftereq)/N_sc);
    
%% Despread
    demspread_data = despread(data_aftereq,code);       % 
    
%% QPSK demodulation
    demodulation_data=pskdemod(demspread_data,M,pi/M);    
    De_data1 = reshape(demodulation_data,[],1);
    De_data2 = de2bi(De_data1);
    De_Bit = reshape(De_data2',1,[]);


%% Channel decoding (Viterbi decoding)
    trellis = poly2trellis(7,[133 171]);
    rx_c_de = vitdec(De_Bit,trellis,tblen,'trunc','hard');   

%% Bit error rate
    [err,Ber2(jj)] = biterr(De_Bit(1:length(code_data)),code_data);  % error rate before decoding
    [err, Ber(jj)] = biterr(rx_c_de(1:length(P_data)),P_data);   % error rate after decoding

end
 figure(2);
 semilogy(SNR,Ber2,'b-s');
 hold on;
 semilogy(SNR,Ber,'r-o');
 hold on;
 legend('4PSK modulation before decoding','4PSK modulation after decoding）');
 hold on;
 xlabel('SNR');
 ylabel('BER');
 title('Bit error rate in AWGN channel');

 figure(3)
 subplot(2,1,1);
 x=0:1:30;
 stem(x,P_data(1:31));
 ylabel('amplitude');
 title('send data');
 legend('4PSK modulation');

 subplot(2,1,2);
 x=0:1:30;
 stem(x,rx_c_de(1:31));
 ylabel('amplitude');
 title('Receive data');
 legend('4PSK modulation');
