# Toolkit_for_MIRA_LAB_Striatal_Segmentation -short readme edition

This readme will briefly describe how to run this version of the Striatal Segmentation pipeline on any given computer.
This version does not depend on TIPP. Prior to the running the pipeline, the parameters in the CNNStriatalSegmentation_call.m script
must be adjusted, as described in that script.

The script CNNStriatalSegmentation_call.m executes the script CNNStriatalSegmentation.m. This
latter script is the heart of the segmentation pipeline and incorporates several image processing modalities (rotation, reslicing, etc)
to make the input images suitable for generation of segmentation masks. This main script runs a python code, orig_mod_NNEval.py, which
in functionality, is equivalent to the python script generated in the MIRA Lab for their segmentation project.
Our main script involves several modularized sub-functions for processing. The ouput from the above-mentioned python script
is processed by our main script and the ultimate two outputs are T1-based segmentation masks and BOLD-based segmentation masks.
Further information will be provided on this pipeline shortly.

UPDATE:

This toolkit now requires user-specified masks for the caudate and putamen regions to enhance the accuracy of striatal segmentations. Following the initial CNN-based segmentation, the toolkit further refines the parcellation by adjusting the boundaries based on the provided masks and considering the adjacency of segmented regions.

Requires:

1. SPM12
2. tippVol

This pipeline was tested using the following versions of Python and libraries:

1. Python: 2.7.5
2. Tensorflow: 2.10.0
3. Numpy: 1.23.2
4. Nibabel: 4.0.2
5. Scipy: 1.9.1
