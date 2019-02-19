function M = gab_edf_load(Fdata) 
fs      = filesep;
conds   = dir(Fdata);
clear isfold
for c = 1:length(conds),    isfold(c) = conds(c).name(1) ~= '.';     end
conds   = {conds(isfold).name};


m = 0;
clear M
for c = 1:length(conds)
    cpath   = [Fdata fs conds{c}];
    edfs    = cellstr(spm_select('FPList', cpath, '^C.*\.edf'));
    if ~isempty(edfs{1})
        disp(['Found EDF files in condition ' conds{c}]);
        m = m + 1;
        M(m).name   = conds{c};
        for e = 1:length(edfs)
            M(m).path{e}  = edfs{e}; 
            M(m).dat{e}   = ft_read_data(M(m).path{e}); 
            M(m).hdr{e}   = ft_read_header(M(m).path{e}); 
        end
    end
end
