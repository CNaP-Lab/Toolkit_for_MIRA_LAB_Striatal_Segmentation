Toolkit_for_MIRA_LAB_Striatal_Segmentation (https://github.com/MMTI/Toolkit_for_MIRA_LAB_Striatal_Segmentation)

Authors: 
John C. Williams, MS, Srineil Nizambad, BS, Mario Serrano-Sosa, PhD, Karl Spuhler, PhD, Jared X. Van Snellenberg, PhD, and Chuan Huang, PhD.

Authors/developers of original CNN Striatal Segmentation Python code (https://github.com/MIRA-Lab-stack/Striatal_Segmentation): 
Mario Serrano-Sosa, PhD, Karl Spuhler, PhD, and Chuan Huang, PhD.

Table of Contents:

I. SUMMARY

II. RUNNING INSTRUCTIONS

III. PIPELINE STEPS

IV. REQUIRED DEPENDENCIES
	
----------------------------------------------------------------------------------------------

I. SUMMARY

This is a pipeline that produces CNN-based segmentations of the striatal regions of the brain based on a structural T1w image, using the algorithm described in:

Serrano-Sosa M, Van Snellenberg JX, Meng J, Luceno JR, Spuhler K, Weinstein JJ, Abi-Dargham A, Slifstein M, Huang C. Multitask Learning Based Three-Dimensional Striatal Segmentation of MRI: fMRI and PET Objective Assessments. J Magn Reson Imaging. 2021 Nov;54(5):1623-1635. doi: 10.1002/jmri.27682. Epub 2021 May 10. PMID: 33970510; PMCID: PMC9204799.

The original Python code (https://github.com/MIRA-Lab-stack/Striatal_Segmentation), which was slightly modified for usability on other systems (e.g., removing hard-coded paths), was developed by Mario Serrano-Sosa, PhD and the Medical Image Research and Analysis (MIRA) Labratory, directed by Chuan Huang PhD, Associate Professor of Radiology at Emory University (previously at  Stony Brook University School of Medicine).

This software allows a user to utilize this CNN striatal segmentation framework, handling user inputs and performing all required image manipulations.  The user provides a native or MNI-space structual image, a brain mask in the same space, and, optionally, a BOLD fMRI template image to reslice the output into.  Outputs are returned in the input anatomical space and both anatomical and BOLD resolutions (latter optional).

This toolkit was developed by John C. Williams, Srineil Nizambad, and Jared X. Van Snellenberg, at the Cognitive Neuroscience and Psychosis Lab at Stony Brook University School of Medicine.

The striatal regions segmented are the: ventral striatum, pre-commissural putamen, post-commissural putamen, pre-commissural caudate, post-commissural caudate.

The user provides a T1-weighted structural MRI image in ACPC orientation, a corresponding brain mask in ACPC orientation, and, optionally, a BOLD functional MRI template image for use in reslicing the outputs to BOLD resolution.

The following outputs are produced: a NIfTI image containing segmentations that can be overlaid on the T1 image and, if the optional BOLD fMRI template image was specified, an additional NIfTI image containing segmentations that can be overlaid on the fMRI image.

The main operating script of the pipeline is main_CNNStriatalSegmentation.m. This script is called by CNNStriatalSegmentation_wrapper_script.m, which has a set of parameters that the user is instructed to adjust therein. Full running operations are discussed in the second section, RUNNING INSTRUCTIONS. 

SPM12 must be on your MATLAB path for this to work.  You can download it from https://www.fil.ion.ucl.ac.uk/spm/software/download/ .

INPUTS:
1. T1-weighted structural MRI image in ACPC orientation (normalized to MNI space or otherwise), e.g., MNINonLinear/T1w_restore_brain.nii
2. Template brain mask in ACPC orientation, in the same space as the T1w template, e.g., MNINonLinear/brainmask_fs.nii
3. Output directory
4. OPTIONAL: BOLD functional MRI image, in the same space and orientation as the T1w template image, but in any desired resolution, e.g., MNINonLinear/Results/RSFC_fMRI_1/RSFC_fMRI_1.nii.  This image will be used to reslice the outputs, generated from high-resolution anatomical T1w images, to the resolution of the desired BOLD image.  

OUTPUTS*:
1. anatRes_templateSpace_striatalCNNparcels.nii
2. OPTIONAL: BOLDRes_templateSpace_striatalCNNparcels.nii

Several intermediates are also generated and discussed in PIPELINE STEPS. 

EXAMPLE:
main_CNNStriatalSegmentation('T1_acpc_template_brain',T1_acpc_template_brain, ...
    'template_acpc_brainmask',template_acpc_brainmask, ...
    'segmentation_outputs_directory',segmentation_outputs_directory, ...
    'BOLD_template_image',BOLD_template_image);

II. RUNNING INSTRUCTIONS:
1. Prior to downloading this GitHub repository on your system, ensure that you have the right versions of Python and required dependencies on your system. Refer to REQUIRED DEPENDENCIES, PYTHON VERSION, AND OTHER FILES, to ensure you have the proper versions of Python and required libraries. Please also ensure you have SPM12 on your system, which may be downloaded here: https://www.fil.ion.ucl.ac.uk/spm/software/spm12/.

2. Download this GitHub repository onto your system. 

3. Within the checkpoint file, please replace “/mnt/jxvs2_02/neil/StriatalSegmentation/“ to where your subfolder StriatalSegmentation is located.

4. Adjust the necessary parameters in CNNStriatalSegmentation_wrapper_script.m; supply the paths for the files and subfolders as instructed therein and as described below.

	For each run of the pipeline involving different subjects, the following are required and the paths must be adjusted:   segmentation_outputs_directory, T1_acpc_template_brain,template_acpc_brainmask.  The following input is optional: BOLD_template_image. 
		
		1. segmentation_outputs_directory refers to the directory where all final and intermediate outputs of this CNN pipeline will be saved for each subject run. 
		2. T1_acpc_template_brain refers to the path of the T1 weighted MRI image (in NAT space) relating to the subject used for this run.
		3. template_acpc_brainmask refers to the path of the brain mask relating to the subject used for this run.
		4. Bold_template_image refers to the path of the bold functional MRI image relating to the subject used for this run.
	
5. Ensure SPM12 and tippVol are on your path in MATLAB and run the script CNNStriatalSegmentation_wrapper_script.m. 

6. You may now inspect your final striatal segmentations for both your structural and functional images, found in the segmentation_outputs_directory (whose path you edited in CNNStriatalSegmentation_wrapper_script.m from step 5), in an image viewer of your choice. Our team used MRIcron, a free tool readily available at: https://www.nitrc.org/projects/mricron. The directory also contains intermediates generated in the pipeline, which may be viewed. 

The final anatomical resolution segmentation mask is named: 
anatRes_templateSpace_striatalCNNparcels.nii.

If the optional BOLD fMRI template image is specified, the final BOLD fMRI resolution segmentation mask is additionally produced and named:
BOLDRes_templateSpace_striatalCNNparcels.nii.

III. PIPELINE STEPS

1. The main script (main_CNNStriatalSegmentation.m) reads arguments given by the user in CNNStriatalSegmentation_wrapper_script.m for the paths of two categories of objects: the inputs to the pipeline and internal files/working directories for the pipeline.
2. The structural MRI image (T1) is rotated 90 degree (with the getRotatedCNN_image subfunction). An intermediate is generated from the T1 template image, with the prefix: striatalCNNrotated_.
3. The brain mask is rotated 90 degrees (with the getRotatedCNN_image subfunction). An intermediate is generated from the brain mask, with the prefix: striatalCNNrotated_.
4. The rotated T1 image is resliced according to the resolution of the CNN reslice template, using 7th degree spline interpolation in SPM (with the getReslicedCNN_image subfunction). In this reslicing run as well as in all future runs, wrapping is turned on in the x, y, and z directions. An intermediate is generated from the T1 template image, with the prefix: striatalCNNres_striatalCNNrotated_.
5. The brain mask is resliced according to the resolution of the CNN reslice template, using nearest neighbor interpolation in SPM (with the getReslicedCNN_image subfunction). An intermediate is generated from the template brain mask, with the prefix: striatalCNNres_striatalCNNrotated_.
6. The brain mask is padded. The padding is governed by a 3-D cubic structuring element whose width is set at 3 pixels. The line, structuringElement = strel('cube',3), may be edited if the user seeks a bigger width of the structuring element or desires to use a different geometric shape. These changes may have an effect on the amount of segmentations observed. Excessive padding can erode the segmentations while no padding can introduce background signals that can blend with striatal segmentations. 
7. Through the function pythonCNNstriatalSegmentation, the main script executes a python script (orig_mod_NNEval.py) that uses previously trained network weights to generate segmentations for the input T1 image. The T1 image is padded and 2 dimensions on each side of the image are added to achieve a 5 dimensional object [1x256x256x192x1]. The output of this python script is a .mat file, which contains 2 variables, out, which contains the raw segmentations, and mri, which contains the original image. After the python script returns the outputs, the out variable is squeezed. The .mat file generated from the the python script is: CNN_striatal_python_output_intermediate.mat.
8. This .mat file is processed with the segmentation_postprocessing subfunction. Out has a size of 256x256x192x6, where 6 represents the segmentation layers, including 1 for background. In the first step, the padded elements are removed and out’s size changes to 234x234x156x6. Next, the cnn network produced probability distributions ranging from 0-1 are converted into discrete values (0 or 1). Then, instead of each voxel being assigned to a probability estimate based on the likelihood of being in each striatal layer, each voxel is only assigned to 1 striatal region using the max function. This avoids overlapping segmentations and ensures each striatal region is specific and based on voxels that exist in that region. The intermediate generated at the end of this step is: raw_StriatalCNNparcels.nii. 
9. The image containing the striatal segmentations is rotated 90 degrees in the direction opposite of that from step 2. The generated intermediate is: striatalCNN_unrotated_raw_StriatalCNNparcels.nii.
10. The segmentations are resliced according to the resolution of the original T1 weighted MRI image input using 7th degree spline interpolation in SPM. The first final output, anatRes_templateSpace_striatalCNNparcels.nii, is generated. 
11. (Optional) If the user specifies a BOLD fMRI template image, then an additional output image is generated so that the segmentations following step 9 are resliced according to the resolution of the BOLD image, using 7th degree spline interpolation. This second final output is BOLDRes_templateSpace_striatalCNNparcels.nii. 


INPUTS:

    1. <T1 template filename> (e.g., ...MNINonLinear/T1w_restore_brain.nii)
    2. <brainmask template filename> (e.g., ...MNINonLinear/brainmask_fs.nii)
    3. <Output directory> (e.g., /mnt/drive/outputdir)
    4. OPTIONAL: <BOLD template filename> (e.g., ...MNINonLinear/Results/RSFC_fMRI_1/RSFC_fMRI_1.nii)


OUTPUTS, INCLUDING INTERMEDIATES:

	1. striatalCNNrotated_<T1 template filename>.nii
	2. striatalCNNrotated_<brainmask template filename>.nii
	3. striatalCNNres_striatalCNNrotated_<T1 template filename>.nii
	4. striatalCNNres_striatalCNNrotated_<brainmask template filename>.nii
	5. CNN_striatal_python_output_intermediate.mat
	6. raw_StriatalCNNparcels.nii
	7. striatalCNN_unrotated_raw_StriatalCNNparcels.nii
	8. anatRes_templateSpace_striatalCNNparcels.nii
	9. BOLDRes_templateSpace_striatalCNNparcels.nii (optional)

IV. REQUIRED DEPENDENCIES, PYTHON VERSION, AND OTHER FILES

This pipeline was tested using the following versions of Python and libraries:

Python: 2.7.5

Tensorflow: 2.10.0

Numpy: 1.23.2

Nibabel: 4.0.2

Scipy: 1.9.

SPM12 must be installed and on the MATLAB path prior to running the pipeline. 
