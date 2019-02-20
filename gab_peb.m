cols = flip(cbrewer('div', 'Spectral', size(DCM,2))); 
for s = 1:size(DCM,1)
for d = 1:size(DCM,2)
    subplot(2,2,s)
    plot(log(real(DCM(s,d).xY.y{1})), 'color', cols(d,:)); hold on
end
end


%% Generic variables
%--------------------------------------------------------------------------
nstp = size(DCM,2);
nsub = size(DCM,1); 

%% Step 1: find transition point
%--------------------------------------------------------------------------


disp('=============================================================')
disp('Timing of the transition');
disp('=============================================================')
for s = 1:nsub
    disp('--------------------------------------------------------------')
    disp(['Working on subject ' num2str(s) ' of ' num2str(nsub)]);
    disp('-------------------------------------------------------------')
    
    clear P
    for d = 1:nstp
        P{d,1} = DCM(s,d); 
    end
    
    M.X(:,1) = ones(nstp,1);
    for x = 1:nstp-1
        M.X(:,2) = zeros(nstp,1);
        M.X(x+1:end,2) = 1;
        peb = spm_dcm_peb(P, M, spm_find_pC(P{1})); 
        F(s,x) = peb.F; 
    end
end

clear stp1
for f = 1:size(F,1)
    [val id] = max(F(f,:)); 
    stp1(f)   = id+1; 
end

%% Step 2: Adjust acuteness of transition
%--------------------------------------------------------------------------
angles = [.01 .05, .1, .17, .3, .6 1];
for s = 1:nsub
for d = 1:nstp, P{d,1} = DCM(s,d); end
for a = 1:length(angles)
    M.X(:,1) = ones(nstp,1); 
    M.X(:,2) = sigmf(1:nstp, [angles(a), stp1(s)]);
    peb      = spm_dcm_peb(P, M, spm_find_pC(P{1})); 
    F(s,a)   = peb.F; 
end
end

clear stp2
for f = 1:size(F,1)
    [val, id]  = max(F(f,:)); 
    stp2(f)    = id; 
end

%% Step 3: Group level PEB
%--------------------------------------------------------------------------
c = 0;
M.X     = [];
for s = 1:nsub
for d = 1:nstp
    c       = c + 1;
    P{c}    = DCM(s,d);
end
X(:,1) = ones(nstp,1);
X(:,2) = sigmf(1:nstp, [angles(stp2(s)), stp1(s)]);
M.X    = [M.X; X];
end

[PEB RCM] = spm_dcm_peb(P,M,spm_find_pC(P{1})); 

%%
s   = 4;
Ep  = RCM{(s-1)*nstp+1}.Ep;

mx = 10;
for w = 1:mx
    rge = linspace(0,1,mx); 
    r   = rge(w); 
    
    Np          = Ep;
    Np.S(1)     = Ep.S(1)   + r*PEB.Ep(1,1) + PEB.Ep(1,2); 
    Np.T(1)     = Ep.T(1)   + r*PEB.Ep(2,1) + PEB.Ep(2,2); 
    Np.CV(1)    = Ep.CV(1)  + r*PEB.Ep(3,1) + PEB.Ep(3,2);
    Np.CV(2)    = Ep.CV(2)  + r*PEB.Ep(4,1) + PEB.Ep(4,2);
    Np.CV(3)    = Ep.CV(3)  + r*PEB.Ep(5,1) + PEB.Ep(5,2);
    Np.CV(4)    = Ep.CV(4)  + r*PEB.Ep(6,1) + PEB.Ep(6,2);
    Np.E(1)     = Ep.E(1)   + r*PEB.Ep(7,1) + PEB.Ep(7,2);
    Np.H(1,1)   = Ep.H(1,1) + r*PEB.Ep(8,1) + PEB.Ep(8,2);
    Np.H(2,1)   = Ep.H(2,1) + r*PEB.Ep(9,1) + PEB.Ep(9,2);
    Np.H(3,1)   = Ep.H(3,1) + r*PEB.Ep(10,1) + PEB.Ep(10,2);
    Np.H(1,2)   = Ep.H(1,2) + r*PEB.Ep(11,1) + PEB.Ep(11,2);
    Np.H(2,2)   = Ep.H(2,2) + r*PEB.Ep(12,1) + PEB.Ep(12,2);
    Np.H(4,2)   = Ep.H(4,2) + r*PEB.Ep(13,1) + PEB.Ep(13,2);
    Np.H(1,3)   = Ep.H(1,3) + r*PEB.Ep(14,1) + PEB.Ep(14,2);
    Np.H(3,3)   = Ep.H(3,3) + r*PEB.Ep(15,1) + PEB.Ep(15,2);
    Np.H(4,3)   = Ep.H(4,3) + r*PEB.Ep(16,1) + PEB.Ep(16,2);
    Np.H(3,4)   = Ep.H(3,4) + r*PEB.Ep(17,1) + PEB.Ep(17,2);
    Np.H(4,4)   = Ep.H(4,4) + r*PEB.Ep(18,1) + PEB.Ep(18,2); 

    mod     = rmfield(RCM{1}.M, 'U');
    mod.dipfit.type     = 'LFP';
    xU.X    = sparse(zeros(1,0)); 
    y       = spm_csd_mtf(Np,mod,xU);
    plot(log(real(y{1}))); hold on 
    drawnow
    
end

%% 

for s = 1:size(DCM,1)
for d = 1:size(DCM,2)
    psd{s}(d,:) = real(log(DCM(s,d).xY.y{1})); 
    esd{s}(d,:) = real(log(DCM(s,d).Hc{1})); 
end
end

s = 2;
subplot(2,1,1)
imagesc(psd{s}')
set(gca, 'Ydir', 'normal')

subplot(2,1,2)
imagesc(esd{s}')
set(gca, 'Ydir', 'normal')