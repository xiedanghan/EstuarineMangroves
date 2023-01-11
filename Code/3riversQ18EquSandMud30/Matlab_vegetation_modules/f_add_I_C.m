%% On the basis of {1N| 2M| 3trachNo| 4Areafractioin| 5trachids| 6rougheq| 7h(m)| 8dens(1/m)| 9Cd| 10Cz| 11vegtype| 12vegnum| 13vegdia(cm)}
% and the relative hydroperiod, P (could be every ets OR yearly)
% we can calculate the values in the 14th-20th col: 14IndS| 15SingleW| 16MultW| 17ComS| 18I*C| 19MortMark| 20MatrixNo

%%
for nv = 1:num_veg_types
    if ismember(nv,trv_trd_addIC(:,11))
        % Inundation stress
        nv_tr_Loc       = find(trv_trd_addIC(:,11)==nv); % vegetation type location
        nv_P_Loc        = sub2ind(size(P),trv_trd_addIC(nv_tr_Loc,1),trv_trd_addIC(nv_tr_Loc,2)); % convert to 1d coordinate
        trv_trd_addIC(nv_tr_Loc,14) = a(nv)*P(nv_P_Loc).^2+b(nv)*P(nv_P_Loc)+c(nv); % add inundation stress in the 14th col based on last ets results
        out_node        = nv_tr_Loc(P(nv_P_Loc)<xL(nv) | P(nv_P_Loc)>xR(nv)); % find the relative hydroperiod value out of the vegetation scale
        trv_trd_addIC(out_node,14)  = 0; % when relative inundation exceeds the scale, set to 0
        
        % Biomass weight in Competition stress
        W_tree_a        = bio_a(nv)*trv_trd_addIC(nv_tr_Loc,13).^ind_a(nv); % aboveground tree weight, Unit-diamater is cm
        W_tree_b        = bio_b(nv)*trv_trd_addIC(nv_tr_Loc,13).^ind_b(nv); % belowground tree weight, Unit-weight(kg/tree)
        trv_trd_addIC(nv_tr_Loc,15) = (W_tree_a + W_tree_b); % Single tree weight, Unit-weight(kg/tree)
        trv_trd_addIC(nv_tr_Loc,16) = trv_trd_addIC(nv_tr_Loc,15).*trv_trd_addIC(nv_tr_Loc,12); % add plant weight in the 16th col
    end
end
clear nv_tr_Loc nv_P_Loc out_node W_tree_a W_tree_b

IC_rc_temp   = unique(trv_trd_addIC(:,[1,2]),'rows'); % Extract rows and columns and appear only once
for iii = 1:size(IC_rc_temp,1) % Loop over vegetation cells
    kkk                   = find(trv_trd_addIC(:,1)==IC_rc_temp(iii,1) & trv_trd_addIC(:,2)==IC_rc_temp(iii,2));
    Bio_total             = sum(trv_trd_addIC(kkk,16));
    Competition_stress    = 1./(1+exp(d(nv)*(B_half(IC_rc_temp(iii,1), IC_rc_temp(iii,2), nv)-Bio_total))); % B_half here is a mean value
    trv_trd_addIC(kkk,17) = Competition_stress;
    clear kkk Bio_total Competition_stress
end

trv_trd_addIC(:,18) = trv_trd_addIC(:,14).*trv_trd_addIC(:,17); % last I* present C for particular plant at particular cell, mortality will further use this value
trv_trd_addIC(trv_trd_addIC(:,12)==0,:) = [];% remove the rows where their num. of veg = 0
trv_trd_addIC(:,20) = 1:1:size(trv_trd_addIC,1); % set sequence for each row

clear Bio_total iii  IC_rc_temp 

