% NOTE TO USER: 
% Please adjust the following:

% Provide the directory below where all intermediate and final outputs of this CNN pipeline will be saved for each subject run.
segmentation_outputs_directory = '/mnt/folder/testdir';
% Provide the path of the T1 weighted MRI image (in NAT space) relating to the subject used for this run. 
T1_acpc_template_brain = '/mnt/sourceFolder/subjectID/MNINonLinear/T1w_restore_brain.nii';
% Provide the path of the brain mask relating to the subject used for this run. 
template_acpc_brainmask = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/brainmask_fs.2.nii';
% OPTIONAL: Provide the path of the bold functional MRI image relating to the subject used for this run. 
BOLD_template_image = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/dataset/THL/THL_fMRI_3/THL_fMRI_3_nonlin_norm.nii'; % Optional input

main_CNNStriatalSegmentation('T1_acpc_template_brain',T1_acpc_template_brain, ...
    'template_acpc_brainmask',template_acpc_brainmask, ...
    'segmentation_outputs_directory',segmentation_outputs_directory, ...
    'BOLD_template_image',BOLD_template_image);
