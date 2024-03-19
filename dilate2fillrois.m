function [Y_pre_final, Y_post_final, Y_VST_final] = dilate2fillrois(Y_pre, Y_post, Y_VST, Y_mask, mode)
    % Author: Yash Patel, MS
    % CNAP-LAB, PI: Jared Van Snellenberg, PhD
    % Stony Brook University
    % Function is intended to be used for both Caudate and Putamen separately
    % Inputs for Caudate ROIs: Y_preCA, Y_postCA, Y_VST, Y_maskCA
    % Inputs for Putamen ROIs: Y_prePU, Y_postPU, Y_VST, Y_maskPU
    
        Y_mask = logical(Y_mask);
        Y_pre = logical(Y_pre);
        Y_post = logical(Y_post);
        Y_VST = logical(Y_VST);
        % Y_VST_outside_mask = zeros(size(Y_VST));
        Y_VST_outside_mask = Y_VST & ~Y_mask;
        % voxelIndex = [121, 199, 102];
        % Y_pre_orig = Y_pre;
        % Y_post_orig = Y_post;
        % Y_VST_orig = Y_VST;
    
        for i = 1:3
            % if strcmp(mode, 'CA')
            %     disp(['CA Iteration ', num2str(i), ':']);
            % elseif strcmp(mode, 'PU')
            %     disp(['PU Iteration ', num2str(i), ':']);
            % end
    
            %Mask
            Y_pre = Y_pre & Y_mask;
            Y_post = Y_post & Y_mask;
            Y_VST = Y_VST & Y_mask;
    
            %Dilate
            Y_pre_dilated = dilate3d(Y_pre);
            Y_post_dilated = dilate3d(Y_post);
            Y_VST_dilated = dilate3d(Y_VST);

            % disp(['After dilation:']);
            % disp(['Y_pre(', num2str(voxelIndex), ') = ', num2str(Y_pre_dilated(voxelIndex(1), voxelIndex(2), voxelIndex(3)))]);
            % disp(['Y_post(', num2str(voxelIndex), ') = ', num2str(Y_post_dilated(voxelIndex(1), voxelIndex(2), voxelIndex(3)))]);
            % disp(['Y_VST(', num2str(voxelIndex), ') = ', num2str(Y_VST_dilated(voxelIndex(1), voxelIndex(2), voxelIndex(3)))]);
        
            %Mask again
            Y_pre_dilated = Y_pre_dilated & Y_mask & ~Y_post & ~Y_VST; %& ~Y_VST_dilated;
            Y_post_dilated = Y_post_dilated & Y_mask & ~Y_pre & ~Y_VST;
            Y_VST_dilated = Y_VST_dilated & Y_mask & ~Y_pre & ~Y_post;

            %added this to keep the outside region part of the adjacency logic and not dilate that
            %reason for not dilating is so it does not keep going in all direction unbounded
            Y_VST_dilated = Y_VST_dilated | Y_VST_outside_mask;
    
            % disp(['After masking again:']);
            % disp(['Y_pre(', num2str(voxelIndex), ') = ', num2str(Y_pre_dilated(voxelIndex(1), voxelIndex(2), voxelIndex(3)))]);
            % disp(['Y_post(', num2str(voxelIndex), ') = ', num2str(Y_post_dilated(voxelIndex(1), voxelIndex(2), voxelIndex(3)))]);
            % disp(['Y_VST(', num2str(voxelIndex), ') = ', num2str(Y_VST_dilated(voxelIndex(1), voxelIndex(2), voxelIndex(3)))]);
        
            
            %adjacency competitiom
    
            kernel = ones(3, 3, 3);
            kernel(2, 2, 2) = 0;
            adjacentCount_pre = convn(Y_pre_dilated, kernel, 'same');
            adjacentCount_post = convn(Y_post_dilated, kernel, 'same');
            adjacentCount_VST = convn(Y_VST_dilated, kernel, 'same');
    
            orig_ROIs = Y_pre & Y_post & Y_VST;
            maskOfInterest_prepost = Y_mask & ~orig_ROIs & Y_pre_dilated & Y_post_dilated;
            maskOfInterest_preVST = Y_mask & ~orig_ROIs & Y_pre_dilated & Y_VST_dilated;
            maskOfInterest_postVST = Y_mask & ~orig_ROIs & Y_VST_dilated & Y_post_dilated;
            maskOfInterest = maskOfInterest_prepost | maskOfInterest_postVST | maskOfInterest_preVST;
            fresh_canvas = zeros(size(Y_pre)); %size(Y_mask))
    
            % Tie cases - could integrate into non-tie with >= but this is more clear and editable
            tie_preCA_postCA = adjacentCount_pre == adjacentCount_post & maskOfInterest;
            tie_preCA_VST = adjacentCount_pre == adjacentCount_VST & maskOfInterest;
            tie_postCA_VST = adjacentCount_post == adjacentCount_VST & maskOfInterest;
            tie_threeWay = tie_preCA_postCA & tie_preCA_VST & tie_postCA_VST; %Technically you only need 2 of these
    
            fresh_canvas(tie_preCA_postCA) = 3; % Post wins ties, assigning '3' to post voxels
            fresh_canvas(tie_preCA_VST) = 4; % VST wins ties, assigning '4' to VST voxels
            fresh_canvas(tie_postCA_VST) = 4; % VST wins ties, assigning '4' to VST voxels
            fresh_canvas(tie_threeWay) = 4; % VST wins ties, assigning '4' to VST voxels
    
            %non-tie stuff
            preCAwins = (adjacentCount_pre > adjacentCount_post) & (adjacentCount_pre > adjacentCount_VST) & maskOfInterest;
            postCAwins = (adjacentCount_post > adjacentCount_pre) & (adjacentCount_post > adjacentCount_VST) & maskOfInterest;
            VSTwins = (adjacentCount_VST > adjacentCount_pre) & (adjacentCount_VST > adjacentCount_post) & maskOfInterest;
            fresh_canvas(preCAwins) = 2; % Pre wins over Post and VST, assigning '2' to pre voxels
            fresh_canvas(postCAwins) = 3; % Post wins over Pre and VST, assigning '3' to post voxels
            fresh_canvas(VSTwins) = 4; % VST wins over Pre and Post, assigning '4' to VST voxels
    
            Y_pre_dilated(fresh_canvas == 3 | fresh_canvas == 4) = 0; % Remove voxels assigned to Post or VST
            Y_post_dilated(fresh_canvas == 2 | fresh_canvas == 4) = 0; % Remove voxels assigned to Pre or VST
            Y_VST_dilated(fresh_canvas == 2 | fresh_canvas == 3) = 0; % Remove voxels assigned to Pre or Post
            
            % %Check for diffrence with previous iteration
            % if isequal(Y_pre, Y_pre_dilated) && isequal(Y_post, Y_post_dilated)
            %     disp(['Stopping dilation at iteration ' num2str(i) ' - no difference found from iteration ' num2str(i-1) '.']);
            %     break;
            % end
    
            % Prepare for next itreation
            Y_pre = Y_pre_dilated;
            Y_post = Y_post_dilated;
            Y_VST = Y_VST_dilated;

            % disp(['After competition and applying stability:']);
            % disp(['Y_pre_perm(', num2str(voxelIndex), ') = ', num2str(Y_pre(voxelIndex(1), voxelIndex(2), voxelIndex(3)))]);
            % disp(['Y_post_perm(', num2str(voxelIndex), ') = ', num2str(Y_post(voxelIndex(1), voxelIndex(2), voxelIndex(3)))]);
            % disp(['Y_VST_perm(', num2str(voxelIndex), ') = ', num2str(Y_VST(voxelIndex(1), voxelIndex(2), voxelIndex(3)))]);
       
        end
        Y_pre_final = Y_pre;
        Y_post_final = Y_post;
        Y_VST_final = Y_VST;
    
    end