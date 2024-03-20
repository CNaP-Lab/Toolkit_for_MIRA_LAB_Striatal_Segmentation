% NOTE TO USER: 
% Please adjust the following:

% Provide the directory below where all intermediate and final outputs of this CNN pipeline will be saved for each subject run.
segmentation_outputs_directory = '/mnt/folder/testdir';
% Provide the path of the T1 weighted MRI image (in NAT space) relating to the subject used for this run. 
T1_acpc_template_brain = '/mnt/sourceFolder/subjectID/MNINonLinear/T1w_restore_brain.nii';
% Provide the path of the brain mask relating to the subject used for this run. 
template_acpc_brainmask = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/brainmask_fs.2.nii';
% Provide the Caudate mask for setting anatomical boundaries
caudateMask = '/mnt/sourceFolder/subjectID/dbs_all_segments_T1w_acpc_dc_restore_-_NATt1_logical_CA.nii';
% Provide the Putamen mask for setting anatomical boundaries
putamenMask = '/mnt/sourceFolder/subjectID/dbs_all_segments_T1w_acpc_dc_restore_-_NATt1_logical_PU.nii';

% OPTIONAL: 
BOLD_template_image = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/dataset/THL/THL_fMRI_3/THL_fMRI_3_nonlin_norm.nii'; % Provide the path of the bold functional MRI image relating to the subject used for this run.
warpPathFileName = '/mnt/sourceFolder/subjectID/MNINonLinear/xfms/acpc_dc2standard.nii.gz'; % Provide the warp from acpc_dc space to MNI space; the warp is from AC-PC aligned, distortion corrected, bias field corrected, native subject space to MNI space
fnirtPathFileName = '/mnt/sourceFolder/subjectID/T1w/T2w_acpc_dc_restore.nii.gz'; %Provide the template T1 image used by FNIRT during preprocessing to generate the warp; Here the acpc aligned, distortion corrected, bias field corrected T1w image, T1w_acpc_dc_restore.nii.gz

main_CNNStriatalSegmentation('T1_acpc_template_brain',T1_acpc_template_brain,...
        'template_acpc_brainmask',template_acpc_brainmask,...
        'BOLD_template_image',BOLD_template_image,...
        'segmentation_outputs_directory',segmentation_outputs_directory,...
        'caudateMask', caudateMask,...
        'putamenMask', putamenMask,...
        'warpPathFileName', warpPathFileName,...
        'fnirtPathFileName', fnirtPathFileName);