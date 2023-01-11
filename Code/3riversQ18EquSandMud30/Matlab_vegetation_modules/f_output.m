%% To create trv and trd file
%>> When trv_trd is finally set up at the end of each ets
%>> Every column will be checked again here
%:: and then
%:: trv and trd will be further created for the vegetation simulation


% 09/10/2018 exclude null trv_trd
if isempty(trv_trd)
    display(['None Vegetation appears at the Year ' num2str(year) ' ETS ' num2str(ets) ]);
else
    trv_trd      = sortrows(trv_trd,1:2); % sortrows
    %% construct root information based on the trv_trd with only stems
    if Root == 1 % Include mangrove roots in the model 23/10/2018
        % duplicate root matrix from trv_trd
        trv_trd_root = trv_trd;
        % Find mangrove species and calculate the roots number
        for nv = 1:num_veg_types
            Loc_sp    = find(trv_trd(:,11)==nv); %
            % 12/09/2018 new roots number increase method-exponential increase
            trv_trd_root(Loc_sp,12) = max_root(nv)*(1./(1+exp(f*(Dmax(nv)/2-trv_trd_root(Loc_sp,13))))).*trv_trd(Loc_sp,12);
            clear Loc_sp
        end
        % 29/08/2018 Sum the different roots at different rows in particular cell into one row
        root_rc   = unique(trv_trd_root(:,[1,2]),'rows'); % cells with root
        root_temp = zeros(size(root_rc,1),size(trv_trd_root,2)); % build a temporary matrix
        for i = 1:size(root_rc,1)
            Loc             = find(trv_trd_root(:,1)==root_rc(i,1) & trv_trd_root(:,2)==root_rc(i,2)); % Target the cell number
            root_temp(i,:)  = trv_trd_root(Loc(1),:); % Attribute the first row to root matrix
            root_temp(i,11) = 900; % represent the root number has already been accumulated
            root_temp(i,12) = sum(trv_trd_root(Loc,12)); % Sum the number of roots
        end
        clear trv_trd_root root_rc i Loc
        trv_trd_root = root_temp;
        clear root_temp
        % Refresh the area fraction 4th, height 7th, density 8th, diameter 13th
        trv_trd_root(:,7)  = 0.15; % root height is a constant value: 15 cm
        trv_trd_root(:,13) = 1; % root diameter is a constant value, 1 cm
        % 11/10/2018  Drag coefficient of roots
        for nv = 1:num_veg_types
            trv_trd_root(trv_trd(:,11)==nv,9)  = Cd_root(nv);
        end
        % Combine stems with roots
        trv_trd                      = [trv_trd; trv_trd_root];
        clear trv_trd_root 
    end
    trv_trd(trv_trd(:,12)==0,:)  = []; % delete the invalid rows
    
    % 13/08/2018 consider roots
    for i = 1:size(trv_trd(:,1),1)
        trv_trd(i,4)      = trv_trd(i,12)/num_all(trv_trd(i,1),trv_trd(i,2)); % update the Area Fraction after mortality and colonization
        trv_trd(i,8)      = num_all(trv_trd(i,1),trv_trd(i,2))/S_cell(trv_trd(i,1),trv_trd(i,2))*trv_trd(i,13)/100; % update the density (1/m)
    end
    clear i
    % Sortrows
    trv_trd           = sortrows(trv_trd,1:2); % sortrows
    trv_trd(:,20)     = 1:1:size(trv_trd,1); % update matrix sequence
    
    %% Output and format file
    % Re-number the col-'TrachytopeNr' both in trd and trv
    % remove the same value in TRD
    trv_trd(:,7)      = round(trv_trd(:,7),2); % height, reserve a decimal fraction
    trv_trd(:,8)      = round(trv_trd(:,8),4); % density, reserve 4 decimal fraction2
    trv_txt           = trv_trd(:,1:4);
    trd_txt_temp      = trv_trd(:,5:10);
    trd_txt_temp(:,7) = 1:1:size(trd_txt_temp,1); % Sequence mark
    TrNo_mark         = 1;
    while ~isempty(trd_txt_temp)
        a_temp                    = trd_txt_temp(1,3:5); % store h,n,cd to a new matrix
        TrNo_Loc                  = find(trd_txt_temp(:,3)==a_temp(1) & trd_txt_temp(:,4)==a_temp(2) & trd_txt_temp(:,5)==a_temp(3)); % find the same trd parameters
        trd_txt(TrNo_mark,1:6)    = trd_txt_temp(TrNo_Loc(1),1:6); % choose one as a representative of TRD
        trd_txt(TrNo_mark,1)      = TrNo_mark; % modify the TrNo in TRD
        trv_txt(trd_txt_temp(TrNo_Loc,7),3) = TrNo_mark; % change the TrNo in TRV as well
        TrNo_mark                 = TrNo_mark+1;
        trd_txt_temp(TrNo_Loc,:)  = [];
    end
    clear a_temp TrNo_Loc TrNo_mark trd_txt_temp
    % Write TRD
    dlmwrite(strcat(directory, 'work/veg','.trd'), trd_txt, '\t'); % write trd file to folder
    % Write TRV
    try % if there is no vegetation (error is created) just copy file otherwise sort data
        % sort the vegetation in trv-file
        trv = sortrows(trv_txt,1:2);
        % update fraction areas of all vegetation types based on changed trv file
        dlmwrite(strcat(directory, 'work/veg','.trv'),trv, '\t');
    catch
        disp('veg.trv is empty');
    end
    clear trd_txt trv trv_txt
    
end