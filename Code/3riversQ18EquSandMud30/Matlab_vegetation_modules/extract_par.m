% Extract and calculate delft3D parameters for colonisation, mortality and
% post-processing from second ets on - more description in technical overview (PDF)
%----------------Let's say, ets=1 here stores the results of last run -----------------------%

%% Calculate sedimentation/erosion for mortality
if mor == 1 % if morphology is included
    depth        = vs_get(NFS,'map-sed-series','DPS','quiet'); % bed topography with morphological changes
else % in case of only hydrology
    depth        = vs_get(NFS,'map-const','DPS0','quiet'); % bed topography (without morphology) at zeta points trimmed to fit grid
end

%% Calculate flood/dry times for seed colonization
% Extract water levels
WL               = vs_get(NFS,'map-series','S1','quiet'); % Water level data at zeta points for all time-steps
% dh
waterdepth       = cellfun(@plus,depth,WL,'UniformOutput',false);
%%>>dh 2019-12-04
% Calculate the flooding frequency from waterdepth
flood_temp       = cellfun(@(x) x>0.1, waterdepth,'UniformOutput',false);
flood            = sum(cat(3,flood_temp{:}),3);
flood(isnan(S_cell)) = 0; % find invalid cells 2021-01-12 xie
clear WL depth waterdepth

%% Calculate 90% cumulative bed shear stress for colonization 2019-12-04
Tauksi   = vs_get(NFS,'map-series','TAUKSI','quiet'); % instead of using max. BSS, now use mean BSS
Taueta   = vs_get(NFS,'map-series','TAUETA','quiet'); % because waves excagerate BSS
TAU      = cellfun(@(x,y) sqrt(x.^2+y.^2), Tauksi, Taueta, 'UniformOutput', false);
TAU           = cellfun(@(x,y) x.*y, TAU ,flood_temp,'UniformOutput',false); % exclude invalid bed shear stress
Tau_temp1     = cat(3,TAU{:}); % Transform to 3d matrix
Tau_90        = prctile(Tau_temp1,90,3); % 3rd dimension 90th percentile value> xie.2023-Jan
Tau_90(isnan(S_cell)) = 0; % find invalid cells 2021-01-12 xie
clear Tauksi Taueta TAU flood_temp Tau_temp1 i j NFS

%%
if year == 1 && ets==1 && Restart == 0 % Cold start from pristine
    Relative_flood0                                                = flood./max(max(flood)); % relative value to seek colonization location
    Tau0                                                           = Tau_90; % Bed shear stress to evaluate seed colonization
elseif year == year_ini && ets == 1 && Restart == 1 % Hot start
    d3dparameters.Flood(year-1).PerYear(t_eco_year,1)              = {flood./max(max(flood))}; % relative value to seek colonization location
    d3dparameters.Tau(year-1).PerYear(t_eco_year,1)                = {Tau_90}; % Bed shear stress to evaluate seed colonization
elseif ets==1
    d3dparameters.Flood(year-1).PerYear(t_eco_year,1)              = {flood./max(max(flood))}; % relative value to seek colonization location
    d3dparameters.Tau(year-1).PerYear(t_eco_year,1)                = {Tau_90}; % Bed shear stress to evaluate seed colonization
else
    d3dparameters.Flood(year).PerYear(ets-1,1)                     = {flood./max(max(flood))}; % relative value to seek colonization location
    d3dparameters.Tau(year).PerYear(ets-1,1)                       = {Tau_90}; % Bed shear stress to evaluate seed colonization
end
clear flood NFS Tau_90