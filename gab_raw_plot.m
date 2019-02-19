function gab_raw_plot(m, I)
pre = 10;
pst = 30; 
for e = 1:length(m.dat)
figure(e)
for i = 1:length(I)
    subplot(2,1,1)
    srt     = (I(i).st - pre) * m.hdr{e}.Fs; 
    stp     = (I(i).st + pst) * m.hdr{e}.Fs;
    tim     = linspace(-pre, pst, length(srt:stp-1));
    plot(tim, m.dat{e}(srt:stp-1) + i * 700); hold on
    xlim([-Inf Inf])
    
    if i == 3
    subplot(2,1,2)
    pspectrum(m.dat{e}(srt:stp-1), m.hdr{e}.Fs, 'spectrogram')
    end
end

end