%% process speech
clear all


% fs=16000;           %ȡ��Ƶ��
% duration=2;         %¼��ʱ��
% fprintf('Press any key to start %g seconds of recording...\n',duration);
% pause;
% fprintf('Recording...\n');
% x=wavrecord(duration*fs,fs);         %duration*fs ���ܵĲ�������
% fprintf('Finished recording.\n');
% fprintf('Press any key to play the recording...\n');
% pause;
% %wavplay(x,fs);
% wavwrite(x,fs,'test.wav'); 

[x fs]  	= wavread('SA1.wav');
x       	= x(:);
%y           = genSSN(x, -5); % add some speech-shaped noise
y           = awgn(x, 30); 
n           = y-x;
[xn si so]  = sii_opt(x, n, fs);

soundsc(x,fs);
soundsc(x+n, fs);   % play before processing
soundsc(xn+n, fs);  % play after processing

disp([si so]); % SII before and after processing (last one should be higher)