function [fsd frq] = gab_fft_psd(dat, Fs)

nsamp           = length(dat);
tft             = real(fft(dat)); 
tft             = tft(1:nsamp/2 + 1);
fsd             = (1/(Fs*nsamp)) * abs(tft).^2; 
fsd(2:end-1)    = 2 * fsd(2:end-1);
frq             = 0:Fs/nsamp:Fs/2;