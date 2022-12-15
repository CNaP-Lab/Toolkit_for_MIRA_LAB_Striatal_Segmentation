Toolkit_for_MIRA_LAB_Striatal_Segmentation - README file

Table of Contents:

I. SUMMARY

II. RUNNING INSTRUCTIONS

III. PIPELINE STEPS

IV. REQUIRED DEPENDENCIES, PYTHON VERSION, AND OTHER FILES
	
----------------------------------------------------------------------------------------------

I. SUMMARY

This readme.txt covers a pipeline that produces CNN-based segmentations of the striatal regions of the brain for given structural and functional MRI images the user provides. The striatal regions segmented are the: ventral striatum, pre-commissural putamen, post-commissural putamen, pre-commissural caudate, post-commissural caudate. The user provides a T1-weighted structural MRI image in ACPC orientation, a NAT brain mask in ACPC orientation, and a bold functional MRI image, in order to produce 2 final products: a NIFTI file containing segmentations that can be overlaid on the T1 image and a NIFTI file containing segmentations that can be overlaid on the fMRI image.

This readme.txt will detail how this pipeline works (in a step-by-step fashion), running instructions, the dependencies required, and the parameters the user must adjust. This pipeline is based in MATLAB and python; much of the editable components are written in MATLAB. 

The main operating script of the pipeline is main_CNNStriatalSegmentation.m. This script is called by CNNStriatalSegmentation_wrapper_script.m, which has a set of parameters that the user is instructed to adjust therein. Full running operations are discussed in the second section, RUNNING INSTRUCTIONS. 

INPUTS:
1. T1-weighted structural MRI image in ACPC orientation
2. NAT brain mask in ACPC orientation
3. Bold functional MRI image

OUTPUTS*:
1. BOLDRes_NATspace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii
2. anatRes_NATspace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii

*These are the final outputs of the pipeline, provided with exact file names. Several intermediates are also generated and discussed in PIPELINE STEPS. 


II. RUNNING INSTRUCTIONS:
1. Prior to downloading this GitHub repository on your system, ensure that you have the right versions of Python and required dependencies on your system. Refer to REQUIRED DEPENDENCIES, PYTHON VERSION, AND OTHER FILES, to ensure you have the proper versions of Python and required libraries. Please also ensure you have SPM12 on your system, which may be downloaded here: https://www.fil.ion.ucl.ac.uk/spm/software/spm12/.

2. Download this GitHub repository onto your system. 

3. Within the checkpoint file, please replace “/mnt/jxvs2_02/neil/StriatalSegmentation/“ to where your subfolder StriatalSegmentation is located.

4. Adjust the necessary parameters in CNNStriatalSegmentation_wrapper_script.m; supply the paths for the files and subfolders as instructed therein and as described below.

	For each run of the pipeline involving different subjects, the following are required and the paths must be adjusted:   segmentation_intermediate_directory,T1_acpc_dc_restore_brain,nat_acpc_brainmask, and BOLD_template_image. 
		
		Segmentation_intermediate_directory refers to the directory where all intermediate and final outputs of this CNN pipeline will be saved for each subject run. 

		T1_acpc_dc_restore_brain refers to the path of the T1 weighted MRI image (in NAT space) relating to the subject used for this run.

		Nat_acpc_brainmask refers to the path of the brain mask relating to the subject used for this run.

		Bold_template_image refers to the path of the bold functional MRI image relating to the subject used for this run.
	
5. Ensure SPM12 and tippVol are on your path in MATLAB and run the script CNNStriatalSegmentation_wrapper_script.m. 

6. You may now inspect your final striatal segmentations for both your structural and functional images, found in the segmentation_intermediate_directory (whose path you edited in CNNStriatalSegmentation_wrapper_script.m from step 5), in an image viewer of your choice. Our team used MRIcron, a free tool readily available at: https://www.nitrc.org/projects/mricron. The directory also contains intermediates generated in the pipeline, which may be viewed. 

The final anatomical segmentation mask is named: anatRes_NATspace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii.

The final BOLD segmentation mask is named:
BOLDRes_NATspace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii.

III. PIPELINE STEPS

1. The main script (main_CNNStriatalSegmentation.m) reads arguments given by the user in CNNStriatalSegmentation_wrapper_script.m for the paths of two categories of objects: the inputs to the pipeline and internal files/working directories for the pipeline.
2. The structural MRI image (T1) is rotated 90 degree (with the getRotatedCNN_image subfunction). An intermediate is generated: striatalCNNrotated_T1w_acpc_dc_restore_brain.nii.
3. The brain mask is rotated 90 degrees (with the getRotatedCNN_image subfunction). An intermediate is generated: striatalCNNrotated_brainmask_fs.2.nii.
4. The rotated T1 image is resliced according to the resolution of the CNN reslice template, using 7th degree spline interpolation in SPM (with the getReslicedCNN_image subfunction). In this reslicing run as well as in all future runs, wrapping is turned on in the x, y, and z directions. An intermediate is generated: striatalCNNres_striatalCNNrotated_T1w_acpc_dc_restore_brain.nii.
5. The brain mask is resliced according to the resolution of the CNN reslice template, using nearest neighbor interpolation in SPM (with the getReslicedCNN_image subfunction). An intermediate is generated: striatalCNNres_striatalCNNrotated_brainmask_fs.2.nii.
6. The brain mask is padded. The padding is governed by a 3-D cubic structuring element whose width is set at 3 pixels. The line, structuringElement = strel('cube',3), may be edited if the user seeks a bigger width of the structuring element or desires to use a different geometric shape. These changes may have an effect on the amount of segmentations observed. Excessive padding can erode the segmentations while no padding can introduce background signals that can blend with striatal segmentations. 
7. Through the function pythonCNNstriatalSegmentation, the main script executes a python script (orig_mod_NNEval.py) that uses previously trained network weights to generate segmentations for the input T1 image. The T1 image is padded and 2 dimensions on each side of the image are added to achieve a 5 dimensional object [1x256x256x192x1]. The output of this python script is a .mat file, which contains 2 variables, out, which contains the raw segmentations, and mri, which contains the original image. After the python script returns the outputs, the out variable is squeezed. The .mat file generated from the the python script is: CNN_striatal_python_output_intermediate.mat.
8. This .mat file is processed with the segmentation_postprocessing subfunction. Out has a size of 256x256x192x6, where 6 represents the segmentation layers, including 1 for background. In the first step, the padded elements are removed and out’s size changes to 234x234x156x6. Next, the cnn network produced probability distributions ranging from 0-1 are converted into discrete values (0 or 1). Then, instead of each voxel being assigned to a probability estimate based on the likelihood of being in each striatal layer, each voxel is only assigned to 1 striatal region using the max function. This avoids overlapping segmentations and ensures each striatal region is specific and based on voxels that exist in that region. The intermediate generated at the end of this step is: raw_StriatalCNNparcels.nii. 
9. The image containing the striatal segmentations is rotated 90 degrees in the direction opposite of that from step 2. The generated intermediate is: striatalCNN_unrotated_raw_StriatalCNNparcels.nii.
10. The segmentations are resliced according to the resolution of the original T1 weighted MRI image input using 7th degree spline interpolation in SPM. The first final output, anatRes_NATspace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii, is generated. 
11. An additional output image is generated so that the segmentations following step 9 are resliced according to the resolution of the BOLD images the user provided, using 7th degree spline interpolation. This second final output, intended for use with BOLD data, is BOLDRes_NATspace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii. 


Below is a detailed sequential run-down of outputs generated during the pipeline, starting with the inputs:

INPUTS:

T1w_acpc_dc_restore_brain.nii

brainmask_fs.2.nii

fMRI.nii 

OUTPUTS:

striatalCNNrotated_brainmask_fs.2.nii

striatalCNNrotated_T1w_acpc_dc_restore_brain.nii

striatalCNNres_striatalCNNrotated_T1w_acpc_dc_restore_brain.nii

striatalCNNres_striatalCNNrotated_brainmask_fs.2.nii

CNN_striatal_python_output_intermediate.mat

raw_StriatalCNNparcels.nii

striatalCNN_unrotated_raw_StriatalCNNparcels.nii

anatRes_NATspace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii

BOLDRes_NATspace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii



IV. REQUIRED DEPENDENCIES, PYTHON VERSION, AND OTHER FILES

This pipeline was tested using the following versions of Python and libraries:

Python: 2.7.5

Tensorflow: 2.10.0

Numpy: 1.23.2

Nibabel: 4.0.2

Scipy: 1.9.

SPM12 must be installed and on the MATLAB path prior to running the pipeline. 

Additionally, in order to run this pipeline, a T1-weighted structural MRI image in ACPC orientation, a NAT brain mask in ACPC orientation, and a bold functional MRI image are required, as described in step 4 in RUNNING INSTRUCTIONS. 
