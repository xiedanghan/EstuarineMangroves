%% script handling creation of trachytope definition file of vegetation type

%% Mangrove grow under inundation/competition stress
%--------------------To grow, or not to grow, this is a problem----------------------%
%--------------------Grow, based on the previous D, H, and I, C----------------------%
%--------------------So before grow, calculate I C, then D   H ----------------------%

% Plants grow with stress when vegetation exist
if year==1 && ets==1 && Restart == 0 
    disp(['Vegetation at Year' num2str(year) ',ETS ' num2str(ets) ' can only colonize without grow!' ]);
elseif ~isempty(trv_trd) % 09/10/2018 exclude null trv_trd
    % First, calculate I and C which has already been done in mortality process
    % Then, update D and H
    % Notice: update D and H, based on last ets I and C!!
    for nv=1:num_veg_types
        vegtype  = find(trv_trd(:,11)==nv & trv_trd(:,13) < Dmax(nv)); % vegetation type
        % Partial diameter
        D_prev   = trv_trd(vegtype,13); % Pre-ets diameter, D_prev(cm)
        H_prev   = trv_trd(vegtype, 7)*100; % Pre-ets shoot height, H_prev(cm)
        IC_prev  = trv_trd(vegtype,18); % Pre-ets I*C stress
        D_D_T    = G(nv)*D_prev.*(1-D_prev.*H_prev/(Dmax(nv)*Hmax(nv))).*IC_prev./((274+3*b2(nv)*D_prev-4*b3(nv)*D_prev.*D_prev)*t_eco_year); % diameter increasement (cm) per ets
        D_cur    = D_prev + D_D_T;
        H_cur    = 25+b2(nv)*D_cur-b3(nv)*D_cur.^2;
        trv_trd(vegtype,13) = D_cur; % update the new diameter, shoot_diameter(cm)
        trv_trd(vegtype, 7) = H_cur/100; % update the new shoot height, TRD_height (m)
    end
end
clear trv_trd_addIC vegtype D_prev H_prev IC_prev D_D_T D_cur H_cur nv