function D = gab_win_slide(m, I, win, pre, pst)

clear D
for e = 1:length(m.hdr)
Fs  = m.hdr{e}.Fs; 
for i = 1:length(I)
    sz = I(i).st * Fs; 
    st = [-pre:1/Fs:pst-win]*Fs + sz;
    for s = 1:length(st)-1
        D(e,i).dat(:,s) = m.dat{e}(1,st(s):(st(s)+win*Fs-1)); 
        D(e,i).psd(:,s) = gab_fft_psd(D(e,i).dat(:,s), Fs); 
    end
end
end