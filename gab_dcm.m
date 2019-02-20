% function ACM = gab_dcm(Fmeeg, Fdcm)
Dfiles      = cellstr(spm_select('FPList', Fmeeg, '^.*\.mat$')); 

for d = 1:length(Dfiles)
    disp('---------------------------------------------------------------'); 
    disp(['Working on datafile ' num2str(d) ' of ' num2str(length(Dfiles))]); 
    disp('---------------------------------------------------------------'); 
    DCM.xY.Dfile    = Dfiles{d}; 
    LFP             = spm_eeg_load(DCM.xY.Dfile); 
    Fs              = fsample(LFP); 
    smpls           = size(LFP,2); 
    timax           = time(LFP); 
    LFP_conds       = condlist(LFP); 

    for c = 1:length(LFP_conds)
    disp(['Currently at ' num2str(c) ' of ' num2str(length(LFP_conds)) ' windows']); 

    % Set up DCM details
    %--------------------------------------------------------------------------
    DCM.options.analysis    = 'CSD';        % cross-spectral density modelling
    DCM.options.model       = 'CMM';        %
    DCM.options.spatial     = 'LFP';        % i.e. local field potential recording
    DCM.options.Tdcm        = [timax(1) timax(end)] * 1000;     % time in ms

    DCM.options.Fdcm    = [2 60];     	% frequency range  
    DCM.options.D       = 1;         	% frequency bin, 1 = no downsampling
    DCM.options.Nmodes  = 4;          	% cosine reduction components used 
    DCM.options.han     = 0;         	% no hanning 
    DCM.options.trials  = c;            % index of ERPs within file
    DCM.Sname           = chanlabels(LFP);

    % Set up model connectivity
    %--------------------------------------------------------------------------
    A = ones(length(DCM.Sname)); 
    A = A.*~eye(size(A)); 
    B = ones(length(DCM.Sname)); 

    DCM.A{1}    = A;
    DCM.A{2}    = A;
    DCM.A{3}    = zeros(length(A)); 

    DCM.B{1}    = [];
    DCM.C       = sparse(length(A), 0); 

    % Reorganise model parameters 
    %--------------------------------------------------------------------------
    DCM.M.dipfit.Nm     = DCM.options.Nmodes;
    DCM.M.dipfit.model  = DCM.options.model; 
    DCM.M.dipfit.type   = DCM.options.spatial;
    DCM.M.dipfit.Nc     = length(DCM.Sname); 
    DCM.M.dipfit.Ns     = length(DCM.Sname); 

    % Optional updating of the priors
    %--------------------------------------------------------------------------
    [pE, pC]    = spm_dcm_neural_priors(DCM.A, DCM.B, DCM.C, DCM.options.model); 
    [pE, pC]    = spm_L_priors(DCM.M.dipfit, pE, pC); 
    [pE, pC]    = spm_ssr_priors(pE, pC); 
    oE          = pE;
    oC          = pC; 

    oE.L        = 4;    oC.L    = oC.L / 32; 
    oE.T        = -.5; 
    oE.S        - .2; 

    DCM.M.pE    = oE; 
    DCM.M.pC    = oC; 

    % Define save name and run
    %--------------------------------------------------------------------------
    fs          = filesep; 
    DCM.name    = [Fdcm fs 'DCM_' num2str(d, '%02.f') '_' LFP_conds{c}];
    DCM         = gab_spm_dcm_csd(DCM); 
    ACM(d,c)    = DCM; 
    end
    
end