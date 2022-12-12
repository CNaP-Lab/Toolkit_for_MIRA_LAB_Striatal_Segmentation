% NOTE TO USER: 
% Please adjust the lines 5,7,9, & 11 for each run where the input images change (different subjects).  

% Provide the directory below where all intermediate and final outputs of this CNN pipeline will be saved for each subject run.
segmentation_intermediate_directory = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002';
% Provide the path of the T1 weighted MRI image (in NAT space) relating to the subject used for this run. 
t1_acpc_dc_restore_brain = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/T1w_acpc_dc_restore_brain.nii';
% Provide the path of the brain mask relating to the subject used for this run. 
nat_acpc_brainmask = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/brainmask_fs.2.nii';
% Provide the path of the bold functional MRI image relating to the subject used for this run. 
bold_template_image = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/dataset/THL/THL_fMRI_3/THL_fMRI_3_nonlin_norm.nii';

CNNStriatalSegmentation('t1_acpc_dc_restore_brain',t1_acpc_dc_restore_brain,...
    'nat_acpc_brainmask',nat_acpc_brainmask,...
    'segmentation_intermediate_directory',segmentation_intermediate_directory,...
    'bold_template_image',bold_template_image);
