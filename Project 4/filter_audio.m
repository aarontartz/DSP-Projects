clear; close all; clc;

[x, fs] = audioread('imperial_march_noisy.wav');
N = length(x);
f = fs*(0:floor(N/2))/N; %setting up frequency axis

X = fft(x);
P = abs(X/N);
P = [P(1); 2*P(2:floor(N/2)); P(floor(N/2)+1)];

figure(1);
subplot(2,1,1);
plot(f, P);
title('Magnitude of Original Signal');
xlabel('Frequency (Hz)');
ylabel('|P(f)|');
grid on;

subplot(2,1,2);
plot(f, 20*log10(P));
title('Magnitude of Original Signal');
xlabel('Frequency (Hz)')
ylabel('20log(|P(f)|) (dB)')
grid on

nyquist = fs/2;

%sinusoidal at 1212 Hz when t>=10s, with side lobes @ ~ 1190Hz & 1250Hz
N_1 = 8192; % order
wc_1 = [1125 1325]; % lower/upper cut‑offs
wn_1 = wc_1 / nyquist; % normalized
h_1 = fir1(N_1, wn_1, 'stop'); % imp. response

%sinusoidal at 56 Hz
N_2 = 8192;
wc_2 = [45 67];
wn_2 = wc_2 / nyquist;
h_2 = fir1(N_2, wn_2, 'stop');

%HPF at 20 hz (stop-band unneeded, figure humans can't hear 
% frequencies below nearly as easy
N_3 = 4096;
wc_3 = 20;
wn_3 = wc_3 / nyquist;
h_3 = fir1(N_3, wn_3, 'high');

%band-stop over colored noise frequency range
N_4 = 256;
wc_4 = [3000 5000]; % ~3khz-5khz
wn_4 = wc_4 / nyquist;
h_4 = fir1(N_4, wn_4, 'stop');

%PLOTTING:

figure(2)

[H_1, w] = freqz(h_1, 1);

subplot(4,2,1);
plot(w*fs / (2*pi), 20*log10(abs(H_1)));
title('Frequency response (Stop band, 1.2khz sinusoidal @ ~ t>=10s)');
xlabel('frequency (hz)');
ylabel('Magnitude response (dB)');
grid on;

subplot(4,2,2);
plot(w*fs / (2*pi), unwrap(angle(H_1)));
xlabel('frequency (hz)');
ylabel('Phase response (rads)');
grid on;

[H_2,w] = freqz(h_2,1);

subplot(4,2,3);
plot(w*fs/(2*pi), 20*log10(abs(H_2)));
title('Frequency response (Stop band, 56hz sinusoidal)');
xlabel('frequency (hz)');
ylabel('Magnitude response (dB)');
grid on;

subplot(4,2,4);
plot(w*fs/(2*pi), unwrap(angle(H_2)));
xlabel('frequency (hz)');
ylabel('Phase response (rads)');
grid on;

[H_3,w] = freqz(h_3,1);

subplot(4,2,5);
plot(w*fs/(2*pi), 20*log10(abs(H_3)));
title('Frequency response (HPF, 20hz sinusoidal)');
xlabel('frequency');
ylabel('Magnitude response (dB)');
grid on;

subplot(4,2,6);
plot(w*fs/(2*pi), unwrap(angle(H_3)));
xlabel('frequency (hz)');
ylabel('Phase response (rads)');
grid on;

[H_4,w] = freqz(h_4,1);

subplot(4,2,7);
plot(w*fs/(2*pi), 20*log10(abs(H_4)));
title('Frequency response (Stop-band, ~3–5kHz range colored noise)');
xlabel('frequency');
ylabel('Magnitude response (dB)');
grid on;

subplot(4,2,8);
plot(w*fs/(2*pi), unwrap(angle(H_4)));
xlabel('frequency (hz)');
ylabel('Phase response (rads)');
grid on;

x_n = round(10 * fs); %1212hz starts around t=10s
y1 = zeros(size(x));
y1(1:x_n) = x(1:x_n);

y1(x_n+1:end) = filter(h_1, 1, x(x_n+1:end)); % removes 1.2khz sinusoidal after 10s
y2 = filter(h_2, 1, y1); %removes 56hz sinusoidal noise
y3 = filter(h_3, 1, y2); %removes ~0.5hz sinusoidal and attenuates anything <5hz
y  = filter(h_4, 1, y3); %removes 3k–5.5khz colored noise

Y = fft(y);

P_2 = abs(Y/N); %normalizes
P_2 = [P_2(1); 2*P_2(2:floor(N/2)); P_2(floor(N/2)+1)];

figure;
%linear scale
subplot(2,1,1);
plot(f, P, f, P_2, 'r');
title('Magnitude');
xlabel('Frequency (Hz)');
ylabel('|P(f)|');
legend('Original', 'Filtered');
grid on;

%dB scale
subplot(2,1,2);
plot(f, 20*log10(P), f, 20*log10(P_2), 'r');
title('Magnitude');
xlabel('Frequency (Hz)');
ylabel('20log(|P(f)|) (dB)');
legend('Original','Filtered');
grid on;

y = y ./ max(abs(y)); % (to keep signal between –1 and 1)
audiowrite('Aaron_Tartz.wav', y, fs);
P = audioplayer(y, fs);
play(P);
