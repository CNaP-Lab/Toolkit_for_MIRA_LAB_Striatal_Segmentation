% NOTE TO USER: 
% Please adjust the lines below as follows: lines 15, 16, & 17 are to be adjusted when setting up this pipeline on your computer
% for the first time. Lines 22, 24, 26, & 28 are adjusted for each run where the input images change (different subjects).  

% Provide the path of the script orig_mod_NNEval.py, included in this github repository. This script uses previously generated trained network weights to predict striatal segmentations for input MRI images. 
segmentation_python_code = '/mnt/jxvs2_02/neil/TIPP_Demo_Copy_for_CNNProject/CodeBase/TIPP1.0/TIPP/@TIPPcustom/orig_mod_NNEval.py';
% Provide the path of reslice_template.nii, included in this github repository. This is a nifti image file provided so that input images can be resliced according to the nii's resolution, which is the resolution expected by the python script.  
cnn_reslice_template = '/mnt/jxvs2_02/neil/TIPP_Demo_Copy_for_CNNProject/CodeBase/TIPP1.0/TIPP/@TIPPcustom/StriatalSegmentation/reslice_template.nii';
% Provide the path of the StriatalSegmentation folder, included in this github repository. This folder includes the above reslice_template.nii file as well as 4 files that are used by the python script for determining CNN network weights. 
segmentation_directory = '/mnt/jxvs2_02/neil/TIPP_Demo_Copy_for_CNNProject/CodeBase/TIPP1.0/TIPP/@TIPPcustom/StriatalSegmentation';

% Provide the directory below where all intermediate and final outputs of this CNN pipeline will be saved for each subject run.
segmentation_intermediate_directory = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002';
% Provide the path of the T1 weighted MRI image (in NAT space) relating to the subject used for this run. 
t1_acpc_dc_restore_brain = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/T1w_acpc_dc_restore_brain.nii';
% Provide the path of the brain mask relating to the subject used for this run. 
nat_acpc_brainmask = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/brainmask_fs.2.nii';
% Provide the path of the bold functional MRI image relating to the subject used for this run. 
bold_template_image = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/dataset/THL/THL_fMRI_3/THL_fMRI_3_nonlin_norm.nii';

CNNStriatalSegmentation('segmentation_python_code',segmentation_python_code,...
    't1_acpc_dc_restore_brain',t1_acpc_dc_restore_brain,...
    'nat_acpc_brainmask',nat_acpc_brainmask,...
    'cnn_reslice_template',cnn_reslice_template,...
    'segmentation_directory',segmentation_directory,...
    'segmentation_intermediate_directory',segmentation_intermediate_directory,...
    'bold_template_image',bold_template_image);
