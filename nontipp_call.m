% NOTE TO USER: 
% For each run where the input images change, change arguments on
% lines 2, 3, & 7 above.
% For first time set-up of this pipeline, change arguments on 
% lines 1, 4, 5, & 6 above, as detailed below.
% For line 1, supply the path where orig_mod_NNEval.py is located.
% For line 4, supply the path where reslice_template.nii is located. 
% For line 5, supply the path where directory, StriatalSegmentation, is located.
% For line 6, supply the path where you would like intermediate and final outputs from this pipeline to be saved.


segmentation_python_code = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/T1w_acpc_dc_restore_brain.nii';
t1_acpc_dc_restore_brain = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/brainmask_fs.2.nii';
nat_acpc_brainmask = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/brainmask_fs.2.nii';
cnn_reslice_template = '/mnt/jxvs2_02/neil/TIPP_Demo_Copy_for_CNNProject/CodeBase/TIPP1.0/TIPP/@TIPPcustom/StriatalSegmentation/reslice_template.nii';
segmentation_directory = '/mnt/jxvs2_02/neil/TIPP_Demo_Copy_for_CNNProject/CodeBase/TIPP1.0/TIPP/@TIPPcustom/StriatalSegmentation';
segmentation_intermediate_directory = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002';
bold_template_image = '/mnt/jxvs2_02/neil/SBKanalysis_fromhelix/50002/dataset/THL/THL_fMRI_3/THL_fMRI_3_nonlin_norm.nii';

nontippversion_CNNstriatalSegmentation('segmentation_python_code',segmentation_python_code,...
    't1_acpc_dc_restore_brain',t1_acpc_dc_restore_brain,...
    'nat_acpc_brainmask',nat_acpc_brainmask,...
    'cnn_reslice_template',cnn_reslice_template,...
    'segmentation_directory',segmentation_directory,...
    'segmentation_intermediate_directory',segmentation_intermediate_directory,...
    'bold_template_image',bold_template_image);