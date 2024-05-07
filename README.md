# Toolkit_for_MIRA_LAB_Striatal_Segmentation
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)<br>
Authors: John C. Williams, MS, Srineil Nizambad, BS, Yash Patel, MS, Philip Tubiolo, MS, Mario Serrano-Sosa, PhD, Karl Spuhler, PhD, Jared X. Van Snellenberg, PhD, and Chuan Huang, PhD.

Authors/developers of original CNN Striatal Segmentation Python code (https://github.com/MIRA-Lab-stack/Striatal_Segmentation): Mario Serrano-Sosa, PhD, Karl Spuhler, PhD, and Chuan Huang, PhD.

Table of Contents:

I. SUMMARY

II. RUNNING INSTRUCTIONS

III. PIPELINE STEPS

IV. UPDATE

V. REQUIRED DEPENDENCIES, PYTHON VERSION, AND OTHER FILES

---

## SUMMARY

This is a pipeline that produces CNN-based segmentations of the striatal regions of the brain for given structural and functional MRI images the user provides, using the algorithm described in:

Serrano-Sosa M, Van Snellenberg JX, Meng J, Luceno JR, Spuhler K, Weinstein JJ, Abi-Dargham A, Slifstein M, Huang C. Multitask Learning Based Three-Dimensional Striatal Segmentation of MRI: fMRI and PET Objective Assessments. J Magn Reson Imaging. 2021 Nov;54(5):1623-1635. doi: 10.1002/jmri.27682. Epub 2021 May 10. PMID: 33970510; PMCID: PMC9204799.

The original Python code (https://github.com/MIRA-Lab-stack/Striatal_Segmentation), which was slightly modified for usability on other systems (e.g., removing hard-coded paths), was developed by Mario Serrano-Sosa, PhD and the Medical Image Research and Analysis (MIRA) Labratory, directed by Chuan Huang PhD, Associate Professor of Radiology at Emory University (previously at  Stony Brook University School of Medicine).

This toolkit allows a user to utilize this CNN striatal segmentation, handling user inputs and performing all required image manipulations.  The user provides a native or MNI-space structual image, a brain mask in the same space, and, optionally, a BOLD fMRI template image to reslice the output into.  Outputs are returned in the input anatomical space and both anatomical and BOLD resolutions (latter optional).

The toolkit was developed by John C. Williams, Srineil Nizambad, Yash Patel and Jared X. Van Snellenberg, at the Cognitive Neuroscience and Psychosis Lab at Stony Brook University School of Medicine.

The striatal regions of interest (ROIs) segmented are the: ventral striatum (VST), pre-commissural putamen (prePU), post-commissural putamen (postPU), pre-commissural caudate (preCA), post-commissural caudate (postCA).

The user provides a T1-weighted structural MRI image in ACPC orientation, a corresponding brain mask in ACPC orientation, and, optionally, a BOLD functional MRI template image, warp image and fnirtSourceT1 image for use in reslicing and warping the outputs to BOLD resolution in MNI space.

The following outputs are produced: a NIfTI image containing segmentations that can be overlaid on the T1 image and 10 separate NIfTI images for right and left hemispheric divisions of each of the 5 striatal ROIs segmented, in T1-based resolution. If the optional BOLD fMRI template image was specified, an additional NIfTI image containing segmentations that can be overlaid on the fMRI image and 10 separate NIfTI images for right and left hemispheric divisions of each of the 5 striatal ROIs segmented are produced, in BOLD-based resolution in MNI space.

The main operating script of the pipeline is main_CNNStriatalSegmentation.m. This script is called by CNNStriatalSegmentation_example_script.m, which has a set of parameters that the user is instructed to adjust therein. Full running operations are discussed in the second section, RUNNING INSTRUCTIONS.

SPM12 and wb_command must be on your MATLAB path for this to work. You can find the links to these dependencies in the running instructions.

INPUTS:

1. `<T1 template filename>` (e.g., ...MNINonLinear/T1w_restore_brain.nii)
2. `<brainmask template filename>` (e.g., ...MNINonLinear/brainmask_fs.nii)
3. `<Segmentation Output Directory>` (e.g., /mnt/drive/outputdir)
4. `<Caudate Mask>` (e.g., ...caudateMask.nii)
5. `<Putamen Mask>` (e.g., ...putamenMask.nii)

OPTIONAL INPUTS :

7. `<BOLD template filename>` (image to reslice (resample) to, can be a BOLD image; e.g., ...MNINonLinear/Results/RSFC_fMRI_1/RSFC_fMRI_1.nii)
8. `<warpPathFileName>` (the warp from AC-PC aligned, distortion corrected, bias field corrected, native subject space to MNI space .../acpc_dc2standard.nii.gz)
9. `<fnirtSourceT1path>` (the source images for the FNIRT normalization from subject to MNI space - the non-skull-stripped T1 images, AC-PC aligned, distortion corrected, bias field corrected T1w image .../T1w_acpc_dc_restore.nii.gz)

OUTPUTS*:

1. anatRes_templateSpace_striatalCNNparcels.nii
2. anat_left_prePU.nii
3. anat_right_prePU.nii
4. anat_left_preCA.nii
5. anat_right_preCA.nii
6. anat_left_postCA.nii
7. anat_right_postCA.nii
8. anat_left_postPU.nii
9. anat_right_postPU.nii
10. anat_left_VST.nii
11. anat_right_VST.nii

OPTIONAL OUTPUTS (if BOLD functional MRI, warpPath and fnirtSourceT1path are provided):

12. BOLDRes_templateSpace_striatalCNNparcels_WARPED.nii
13. bold_left_prePU.nii
14. bold_right_prePU.nii
15. bold_left_preCA.nii
16. bold_right_preCA.nii
17. bold_left_postCA.nii
18. bold_right_postCA.nii
19. bold_left_postPU.nii
20. bold_right_postPU.nii
21. bold_left_VST.nii
22. bold_right_VST.nii

Several intermediates are also generated and discussed in PIPELINE STEPS.

EXAMPLE:

```
main_CNNStriatalSegmentation('T1_acpc_template_brain',T1_acpc_template_brain,...
        'template_acpc_brainmask',template_acpc_brainmask,...
        'segmentation_outputs_directory',segmentation_outputs_directory,...
        'caudateMask', caudateMask,...
        'putamenMask', putamenMask,...
	'BOLD_template_image',BOLD_template_image,...
        'warpPathFileName', warpPathFileName,...
        'fnirtSourceT1path',fnirtSourceT1path);
```

## RUNNING INSTRUCTIONS:

1. Prior to downloading this GitHub repository on your system, ensure that you have the right versions of Python and required dependencies on your system. Refer to REQUIRED DEPENDENCIES, PYTHON VERSION, AND OTHER FILES, to ensure you have the proper versions of Python and required libraries. Please also ensure you have SPM12 on your path, which may be downloaded from [here](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) as well as wb_command by Connectome Workbench which may be downloaded from [here](https://www.humanconnectome.org/software/workbench-command).
2. Download this GitHub repository onto your system.
3. Within the checkpoint file, please replace “/mnt/jxvs2_02/neil/StriatalSegmentation/“ to where your subfolder StriatalSegmentation is located.
4. Adjust the necessary parameters in CNNStriatalSegmentation_example_script.m; supply the paths for the files and subfolders as instructed therein and as described below.

   For each run of the pipeline involving different subjects, the following are required and the paths must be adjusted:   T1_acpc_template_brain, template_acpc_brainmask, segmentation_outputs_directory, caudateMask and putamenMask.  The following input is optional: BOLD_template_image, warpPathFileName, fnirtSourceT1path.
5. T1_acpc_template_brain refers to the path of the T1 weighted MRI image (in NAT space) relating to the subject used for this run.
6. template_acpc_brainmask refers to the path of the brain mask relating to the subject used for this run.
7. segmentation_outputs_directory refers to the directory where all final and intermediate outputs of this CNN pipeline will be saved for each subject run.
8. Bold_template_image refers to the path of the bold functional MRI image relating to the subject used for this run. This image is used to reslice (resample) to.
9. CaudateMask is the mask in native space applied to ensure the segmentation adheres to the anatomical boundaries defined by the mask.
10. PutamenMask is the mask in native space applied to ensure the segmentation adheres to the anatomical boundaries defined by the mask.
11. WarpPathFileName is the warp from AC-PC aligned, distortion corrected, bias field corrected, native subject space to MNI space, `acpc_dc2standard.nii.gz` in HCP MPP preprocessed data.
12. FnirtSourceT1path is the non-skull-stripped T1w source image used by FNIRT during preprocessing to generate the warp above, typically the acpc aligned, distortion corrected, bias field corrected T1w image, `T1w_acpc_dc_restore.nii.gz` in HCP MPP preprocessed data.
13. Ensure SPM12, tippVol and wb_command are on your path in MATLAB and run the script CNNStriatalSegmentation_example_script.m.
14. You may now inspect your final striatal segmentations for both your structural and functional images, found in the segmentation_outputs_directory (whose path you edited in CNNStriatalSegmentation_example_script.m from step 5), in an image viewer of your choice. Our team used MRIcron, a free tool readily available [here](https://www.nitrc.org/projects/mricron). The directory also contains intermediates generated in the pipeline, which may be viewed. Intermediates generated prior to the ROI corrections, which are confined within anatomical boundaries, are also preserved. This is due to the fact that wb_command requires explicit input and output file paths for operations, as it does not process these corrections in memory.

The final anatomical resolution segmentation mask is named:
anatRes_templateSpace_striatalCNNparcels.nii. The 10 separate hemispheric-specific ROI images produced are named: anat_left_prePU.nii,anat_right_prePU.nii,anat_left_preCA.nii,anat_right_preCA.nii,anat_left_postCA.nii,anat_right_postCA.nii,anat_left_postPU.nii,anat_right_postPU.nii, anat_left_VST.nii,anat_right_VST.nii.

If the optional BOLD fMRI template image, warpPath input and fnirtSourceT1 input is specified, the final BOLD fMRI resolution segmentation mask in MNI space is additionally produced and named:
BOLDRes_templateSpace_striatalCNNparcels_WARPED.nii. The 10 separate hemispheric-specific ROI images produced are named: bold_left_prePU.nii,bold_right_prePU.nii,bold_left_preCA.nii,bold_right_preCA.nii,bold_left_postCA.nii,bold_right_postCA.nii,bold_left_postPU.nii,bold_right_postPU.nii, bold_left_VST.nii,bold_right_VST.nii.

## PIPELINE STEPS

1. The main script (main_CNNStriatalSegmentation.m) reads arguments given by the user in CNNStriatalSegmentation_example_script.m for the paths of two categories of objects: the inputs to the pipeline and internal files/working directories for the pipeline.
2. The structural MRI image (T1) is rotated 90 degree (with the getRotatedCNN_image subfunction). An intermediate is generated from the T1 template image, with the prefix: striatalCNNrotated_.
3. The brain mask is rotated 90 degrees (with the getRotatedCNN_image subfunction). An intermediate is generated from the brain mask, with the prefix: striatalCNNrotated_.
4. The rotated T1 image is resliced according to the resolution of the CNN reslice template, using 7th degree spline interpolation in SPM (with the getReslicedCNN_image subfunction). In this reslicing run as well as in all future runs, wrapping is turned on in the x, y, and z directions. An intermediate is generated from the T1 template image, with the prefix: striatalCNNres_striatalCNNrotated_.
5. The brain mask is resliced according to the resolution of the CNN reslice template, using nearest neighbor interpolation in SPM (with the getReslicedCNN_image subfunction). An intermediate is generated from the template brain mask, with the prefix: striatalCNNres_striatalCNNrotated_.
6. The brain mask is padded. The padding is governed by a 3-D cubic structuring element whose width is set at 3 pixels. The line, structuringElement = strel('cube',3), may be edited if the user seeks a bigger width of the structuring element or desires to use a different geometric shape. These changes may have an effect on the amount of segmentations observed. Excessive padding can erode the segmentations while no padding can introduce background signals that can blend with striatal segmentations.
7. Through the function pythonCNNstriatalSegmentation, the main script executes a python script (orig_mod_NNEval.py) that uses previously trained network weights to generate segmentations for the input T1 image. The T1 image is padded and 2 dimensions on each side of the image are added to achieve a 5 dimensional object [1x256x256x192x1]. The output of this python script is a .mat file, which contains 2 variables, out, which contains the raw segmentations, and mri, which contains the original image. After the python script returns the outputs, the out variable is squeezed. The .mat file generated from the the python script is: CNN_striatal_python_output_intermediate.mat.
8. This .mat file is processed with the segmentation_postprocessing subfunction. Out has a size of 256x256x192x6, where 6 represents the segmentation layers, including 1 for background. In the first step, the padded elements are removed and out’s size changes to 234x234x156x6. Next, the cnn network produced probability distributions ranging from 0-1 are converted into discrete values (0 or 1). Then, instead of each voxel being assigned to a probability estimate based on the likelihood of being in each striatal layer, each voxel is only assigned to 1 striatal region using the max function. This avoids overlapping segmentations and ensures each striatal region is specific and based on voxels that exist in that region. The intermediate generated at the end of this step is: raw_StriatalCNNparcels.nii.
9. The image containing the striatal segmentations is rotated 90 degrees in the direction opposite of that from step 2. The generated intermediate is: striatalCNN_unrotated_raw_StriatalCNNparcels.nii.
10. a)The segmentations are resliced according to the resolution of the original T1 weighted MRI image input using 7th degree spline interpolation in SPM. The first final output, anatRes_templateSpace_striatalCNNparcels.nii, is generated.

    b) Now the corrections in the anatRes_templateSpace_striatalCNNparcels.nii is made using the user inputted Caudate and Putamen masks. The correction is based on anatomical Boundaries and adjacency of voxels. This process involves:

    1. **Loading the Initial CNN Output** : The initial segmentation results are loaded, identifying regions marked as caudate, putamen and Ventral Striatum.
    2. **Applying the Masks** : The user-provided caudate and putamen masks are applied to ensure the segmentation adheres to the anatomical boundaries defined by these masks.
    3. **Dilating and Adjusting Based on Adjacency and Bounds** : The toolkit performs a dilation operation within the confines of the provided masks, considering the adjacency of segmented regions. This step ensures that the segmentation expands to cover relevant areas while respecting anatomical constraints.
    4. **Finalizing the Corrected Parcellation** : The corrected segmentation is saved, reflecting adjustments made using the caudate and putamen masks.

    c) Through the subfunction getseparatedROIs, the 5 whole-brain ROIs segmented in the anatRes_templateSpace_striatalCNNparcels.nii are separated and split between the left and right hemispheres to produce 10 hemispheric-specific ROIs, which are saved as separate NIfTI images: anat_left_prePU.nii,anat_right_prePU.nii,anat_left_preCA.nii,anat_right_preCA.nii, anat_left_postCA.nii,anat_right_postCA.nii,anat_left_postPU.nii,anat_right_postPU.nii, anat_left_VST.nii,anat_right_VST.nii.

    This is achieved by having the product of step 10a set equal to zero for all values not equal to the integer representing the nth ROI in consideration. Since the product of 10a is an image where each voxel is either assigned to an integer representing each of the 5 ROIs (1-5) or not assigned to any ROI (0), each ROI can be separated as aforementioned. For each whole-brain ROI, the right and left hemispheric divisions of the ROI can be captured by setting the image to zero at indices that represent negative XYZ coordinates (as gathered by tippVol) and positive XYZ coordinates, respectively.
11. (Optional)

    a) If the user specifies a BOLD fMRI template image, Warp image and the fnirtSourceT1 image then an additional output image is generated from anatRes_templateSpace_striatalCNNparcels.nii leveraging the wb_command's functionality to reslice to BOLD resolution and warp to MNI space. This output is BOLDRes_templateSpace_striatalCNNparcels_WARPED.nii.

    b) Similar to step 10c, ten ROIs are separated from the BOLDRes_templateSpace_striatalCNNparcels_WARPED.nii image and split between the left and right hemispheres to produce the following: bold_left_prePU.nii,bold_right_prePU.nii,bold_left_preCA.nii,bold_right_preCA.nii, bold_left_postCA.nii,bold_right_postCA.nii,bold_left_postPU.nii,bold_right_postPU.nii, bold_left_VST.nii,bold_right_VST.nii

INPUTS:

1. `<T1 template filename>` (e.g., ...MNINonLinear/T1w_restore_brain.nii)
2. `<brainmask template filename>` (e.g., ...MNINonLinear/brainmask_fs.nii)
3. `<Segmentation Output Directory>` (e.g., /mnt/drive/outputdir)
4. `<Caudate Mask>` (e.g., ...caudateMask.nii)
5. `<Putamen Mask>` (e.g., ...putamenMask.nii)

OPTIONAL INPUTS:

7. `<BOLD template filename>` (image to reslice (resample) to, can be a BOLD image; e.g., ...MNINonLinear/Results/RSFC_fMRI_1/RSFC_fMRI_1.nii)
8. `<warpPathFileName>` (the warp from AC-PC aligned, distortion corrected, bias field corrected, native subject space to MNI space; e.g., .../acpc_dc2standard.nii.gz)
9. `<fnirtSourceT1path>` (the template T1 image used by FNIRT during preprocessing to generate the warp; e.g., Here the acpc aligned, distortion corrected, bias field corrected T1w image .../T1w_acpc_dc_restore.nii.gz)

OUTPUTS, INCLUDING INTERMEDIATES:

    1. striatalCNNrotated_`<T1 template filename>`.nii
	2. striatalCNNrotated_`<brainmask template filename>`.nii
	3. striatalCNNres_striatalCNNrotated_`<T1 template filename>`.nii
	4. striatalCNNres_striatalCNNrotated_`<brainmask template filename>`.nii
	5. CNN_striatal_python_output_intermediate.mat
	6. raw_StriatalCNNparcels.nii
	7. striatalCNN_unrotated_raw_StriatalCNNparcels.nii
	8. anatRes_templateSpace_striatalCNNparcels.nii
 	9. anat_left_prePU.nii
	10. anat_right_prePU.nii
	11. anat_left_preCA.nii
	12. anat_right_preCA.nii
	13. anat_left_postCA.nii
	14. anat_right_postCA.nii
	15. anat_left_postPU.nii
	16. anat_right_postPU.nii
	17. anat_left_VST.nii
	18. anat_right_VST.nii
	19. `<Segmentation Output Directory>`/Intermediates/*intermediate files for clustering and removing holes* 

    (20-30 are OPTIONAL, dependent on whether a BOLD fMRI input, warpPath input and fnirtSourceT1 input are provided)
	20. BOLDRes_templateSpace_striatalCNNparcels_WARPED.nii
	21. bold_left_prePU.nii
	22. bold_right_prePU.nii
	23. bold_left_preCA.nii
	24. bold_right_preCA.nii
	25. bold_left_postCA.nii
	26. bold_right_postCA.nii
	27. bold_left_postPU.nii
	28. bold_right_postPU.nii
	29. bold_left_VST.nii
	30. bold_right_VST.nii

## REQUIRED DEPENDENCIES, PYTHON VERSION, AND OTHER FILES

This pipeline was tested using the following versions of Python and libraries:

Python: 2.7.5

Tensorflow: 2.10.0

Numpy: 1.23.2

Nibabel: 4.0.2

Scipy: 1.9.

SPM12 must be installed and on the MATLAB path prior to running the pipeline.

wb_command from Connectome Workbench
