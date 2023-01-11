% Script for colonisation of plants with strategy 1 (on bare substrate between max and min water levels);
% Determines the cells where settling possibility for the ETS in colonization window.
% Find cells that are dry at the end of ETS and maximum water depth over the whole ETS.
% This assumes that seedlings are distributed with the tides. A window of opportunity is indirectly
% established as the cell is flooded and bed shear stress is reasonable.
% Is that value realistic? Here random colonization alters locations if turned on.
%% Relative hydroperiod, yearly or last ets?
if year == 1 && ets == 1 % Initialize trv_trd
    % Preallocate trv_trd size
    %:: Content of trv_trd:
    % 1N| 2M| 3trachNo| 4Areafractioin| 5trachids| 6rougheq| 7h(m)| 8dens(1/m)| 9Cd| 10Cz| 11vegtype| 12vegnum|
    % 13vegdia(cm)|14IndS| 15SingleW| 16MultW| 17ComS| 18I*C| 19MortMark| 20MatrixNo| 21RootNum| 22StemRootNum
    trv_trd            = [];
    P_col   = P;
    Tau_col = Tau;
elseif year > 1 && ets == 1  % Use an anual average value from the 2nd year
    P_col   = mean(cat(3, d3dparameters.Flood(year-1).PerYear{:,1}),3);
    Tau_col = mean(cat(3, d3dparameters.Tau(year-1).PerYear{:,1}),3);
end

Sum_area_mark   = zeros(Ndim, Mdim);
SeedLoc         = cell(num_veg_types,1);

%% Step 1: Look for cells where plants are going to colonize
for nv = 1: num_veg_types
    % if within colonization window:
    if   ismember(ets,LocEco(1,:,nv))
        % 2019-10-16>> Mangrove can only colonize in the RP (0 0.5) 
        % 2019-12-05>> Mangrove colonize should also below certain bed shear stress
        SeedLoc{nv}= find(P_col > 0 & P_col < 0.5 & Tau_col < TauThres); 
        clear P_col Tau_col
        % delete the mortality cells where plants can not grow
        if Mortality == 1
            for i=1:size(Mort_list,1)
                SeedLoc{nv}(SeedLoc{nv} == Mort_list(i),:) = [];
            end
        end
        
        Area_mark              = zeros(Ndim, Mdim);
        Area_mark(SeedLoc{nv}) = 1;
        Sum_area_mark          = Sum_area_mark+Area_mark;
    end % end statement seed dispersal window checking
end
clear i Area_mark Mort_list 

%% Step2: Evaluate colonization probability and allocate the number of plants
if year == 1 && ets == 1 
    % Initial area fraction by pre-allocation
    rough_eq            = zeros(num_veg_types,1);
    height              = zeros(num_veg_types,1);
    drag_coeff          = zeros(num_veg_types,1);
    chezy_coeff         = zeros(num_veg_types,1);
    vegtype             = zeros(num_veg_types,1);
    % Veg file
    for nv=1:num_veg_types
        % TRD
        rough_eq(nv,1)     = general_veg_char(1, 5, nv);
        height(nv,1)       = Shoot_height0(nv); % shoot height, (m)
        % 13/08/2018 consider roots
        drag_coeff(nv,1)   = 1.5;
        chezy_coeff(nv,1)  = chezy;
        vegtype(nv,1)      = nv;
    end % end loop over plant coordinates
    
    % Construct trv_trd
    M_mark             = find(Sum_area_mark>0); % cells that plants can grow, e.g. 2 = 2 species
    [row_M,col_M]      = ind2sub(size(Sum_area_mark),M_mark); % convert to 2-d coordinate
    for i = 1:size(M_mark,1)
        Growth_temp                      = []; % prescribe matrix size
        f_colonize_null_new
        trv_trd                          = [trv_trd; Growth_temp];
    end
    clear M_mark row_M col_M i SeedLoc Sum_area_mark
elseif year~=1 && sum(sum(Sum_area_mark))~=0 % the 2nd year and cells available, need to consider I*C
    M_mark             = find(Sum_area_mark>0); % cells that plants can grow, e.g. 2 = 2 species
    [row_M,col_M]      = ind2sub(size(Sum_area_mark),M_mark); % convert to 2-d coordinate
    for i = 1:size(M_mark,1)
        tr_mark        = []; % prescribe matrix
        if ~isempty(trv_trd)
            tr_mark        = find(trv_trd(:,1) == row_M(i) & trv_trd(:,2) == col_M(i)); % exist in trv_trd or not?
        end
        if isempty(tr_mark) % vegetation doesn't exist
            Growth_temp                      = []; % prescribe matrix size
            f_colonize_null_new
            trv_trd                          = [trv_trd; Growth_temp];
        elseif sum(trv_trd(tr_mark,12)) < num0 % vegetation exists and cells can still take in new vegetation
            Growth_temp                      = []; % prescribe matrix size
            Growth_temp(1:size(tr_mark,1),:) = trv_trd(tr_mark,:); % the original parameters from trv_trd
            trv_trd(tr_mark,:) = []; % delete the original rows in the trv_trd
            % colonization on the cells which vegetation already exist
            f_colonize_new
            trv_trd            = [trv_trd; Growth_temp];
        end
    end
    trv_trd           = sortrows(trv_trd,1:2); % sortrows
    trv_trd(:,20)     = 1:1:size(trv_trd,1); % update matrix sequence
    clear tr_mark Growth_temp i row_M col_M SeedLoc Sum_area_mark
end