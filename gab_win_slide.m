function D = gab_win_slide(m, I, win, pre, pst, Fmeeg)
fs      = filesep; 

clear D
for e = 1:length(m.hdr)
Fs  = m.hdr{e}.Fs; 
for i = 1:length(I)
    sz = I(i).st * Fs; 
    st = [-pre:.1*win:pst-win]*Fs + sz;
    for s = 1:length(st)-1
        D(e,i).dat(:,s) = m.dat{e}(1,st(s):(st(s)+win*Fs-1)); 
        D(e,i).psd(:,s) = gab_fft_psd(D(e,i).dat(:,s), Fs); 
        D(e,i).ons      = st / Fs; 
    end
end
end

% Make MEEG object to feed into DCM
%--------------------------------------------------------------------------
i = 0;
for e = 1:size(D,1)
for d = 1:size(D,2)
    i = 0; 
    clear trialname ftdata
    for dd = 1:size(D(e,d).dat,2)
        i = i + 1;
        ftdata.trial{i} = D(e,d).dat(:,dd)';
        ftdata.time{i}  = linspace(0, win, length(ftdata.trial{i})+1);
        ftdata.time{i}  = ftdata.time{i}(1:end-1); 
        trialname{i}    = [m.name '_' num2str(i, '%02.f')]; 
    end
    ftdata.label    = {'LFP'};
    fname           = [Fmeeg fs m.name '_' num2str(e, '%02.f') '_' num2str(d, '%02.f')];
    MG              = spm_eeg_ft2spm(ftdata, fname); 
    MG              = conditions(MG, 1:size(MG,3), trialname);
    save(MG)
    D(e,d).path     = fname; 
end
end

