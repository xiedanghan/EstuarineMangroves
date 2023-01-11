%% New vegetation colonization have 2 different ways
%>> For bare cells, vegetation can have the maximum num
%>> For cells already exist vegetation and I*C >0.5, the following things need to be clarified here
%:: Vegetation type, height, number of plants
%:: Vegetation growth depends on the inundation stress of each species >> small I. small num of new veg
%:: This code serves for those cells originally without vegetation

% Preassign
nv_new  = zeros(Sum_area_mark(M_mark(i)),1);
h_new   = zeros(Sum_area_mark(M_mark(i)),1);
In_s    = zeros(Sum_area_mark(M_mark(i)),1);
num_new = zeros(Sum_area_mark(M_mark(i)),1);

% Idendify vegetation type 2021-01-12Xie
for kk = 1:Sum_area_mark(M_mark(i))
    for nv = 1 : num_veg_types
        if ismember(M_mark(i),SeedLoc{nv})
            nv_new(kk)   = nv; % species no.
            h_new(kk)    = Shoot_height0(nv);
            break
        end
    end
end
clear kk

% Inundation stress calculation
for jj = 1 : length(nv_new)
    In_s(jj)       = a(nv_new(jj))*P(M_mark(i))^2+b(nv_new(jj))*P(M_mark(i))+c(nv_new(jj));
end

% vegetation number allocation
for jj = 1:length(nv_new)
    num_new(jj,1)    = round(num0(row_M(i), col_M(i))*In_s(jj)/sum(In_s)); 
end
clear jj In_s 

Growth_temp        = zeros(Sum_area_mark(M_mark(i)),20); % preallocate new veg size
num_veg            = num_new; % Initialize new vegetation number

% 1N| 2M| 3trachNo| 4Areafractioin| 5trachids| 6rougheq| 7h(m)| 8dens(1/m)| 9Cd| 10Cz| 11vegtype| 12vegnum|
% 13vegdia(cm)|14IndS| 15SingleW| 16MultW| 17ComS| 18I*C| 19MortMark| 20MatrixNo| 21RootNum| 22StemRootNum
Growth_temp(:,1:2)             = repmat([row_M(i), col_M(i)],Sum_area_mark(M_mark(i)),1);
% Growth_temp(:,[3,4,5,7,11,12]) = [nv_new,num_veg/num0,nv_new,h_new,nv_new,num_veg];
% 13/08/2018 consider roots
Growth_temp(:,[3,4,5,7,11,12]) = [nv_new,num_veg/num_all(row_M(i), col_M(i)),nv_new,h_new,nv_new,num_veg];

Growth_temp(:,[6,9,10])        = repmat([rough_eq(1),drag_coeff(1),chezy],Sum_area_mark(M_mark(i)),1);
% Growth_temp(:,8)               = repmat(num0/S_cell*stem_diameter0(1),Sum_area_mark(M_mark(i)),1);
% 13/08/2018 consider roots
Growth_temp(:,8)               = repmat(num_all(row_M(i), col_M(i))/S_cell(row_M(i), col_M(i))*stem_diameter0(1),Sum_area_mark(M_mark(i)),1);

Growth_temp(:,[13,14])         = repmat([stem_diameter0(1)*100,Growth_temp(1,14)],Sum_area_mark(M_mark(i)),1); % the unit of 13th column is cm
%new Matrix
% Growth_temp(size(tr_mark,1)+1:size(tr_mark,1)+Sum_area_mark(M_mark(i)),:)     = Growth_new_temp; % test the new adding vegetation by decreasing the veg num
%add I and C to new matrix
trv_trd_addIC   = Growth_temp;
f_add_I_C
Growth_temp     = trv_trd_addIC;
% num_veg         = num_veg +num_new; % add new vegetation number every run
clear trv_trd_addIC num_veg num_new