function [store] = main_CNNStriatalSegmentation(varargin)

    m_file_name_and_path=mfilename('fullpath');
    [m_file_directory,~,~]=fileparts(m_file_name_and_path);
    segmentation_python_code_filename='orig_mod_NNEval.py';
    segmentation_python_code=fullfile(m_file_directory,segmentation_python_code_filename);
    % Segmentation_python_code refers to the the path of the script orig_mod_NNEval.py, which is included in the github repository. The script uses previously %generated trained network weights to predict striatal segmentations for input MRI & fMRI images.

    segmentation_directory_name='StriatalSegmentation';
    segmentation_directory=fullfile(m_file_directory,segmentation_directory_name);
    % Segmentation_directory refers to the StriatalSegmentation folder, included in the github repository. The folder includes the below reslice_template.nii file as well as 4 files that are used by the python script for determining CNN network weights.

    CNN_reslice_template_filename='reslice_template.nii';
    CNN_reslice_template=fullfile(m_file_directory,'StriatalSegmentation',CNN_reslice_template_filename);
    % CNN_reslice_template refers to the path of reslice_template.nii, which is included in the github repository. This is a nifti image file provided so that
    %input images can be resliced according to the nii's resolution, which is the resolution expected by the python script, orig_mod_NNEval.py

    % Store, a struct, saves the file names and image types of
    % all final and intermediate outputs generated during this pipeline run.
    store.fname{1}='null';
    store.imagetype{1}='null';
    %% end of new part
    numArgIn = length(varargin);
    currentArgNumber = 1;
    [T1_acpc_template_brain, template_acpc_brainmask, segmentation_outputs_directory, BOLD_template_image] = deal([]);
    while (currentArgNumber <= numArgIn)
        StringCurrentArg = (string(varargin{currentArgNumber}));
        numToAdd = 2;
        switch(StringCurrentArg)
            case "T1_acpc_template_brain"
                T1_acpc_template_brain = varargin{currentArgNumber + 1};
            case "template_acpc_brainmask"
                template_acpc_brainmask = varargin{currentArgNumber + 1};
            case "segmentation_outputs_directory"
                segmentation_outputs_directory = varargin{currentArgNumber + 1};
            case "BOLD_template_image"
                BOLD_template_image = varargin{currentArgNumber + 1};
            otherwise
                error("Unrecognized input argument")
        end
        currentArgNumber = currentArgNumber + numToAdd;
    end
    disp('Read all arguments'); pause(eps); drawnow;

    if ~exist(segmentation_outputs_directory, 'dir')
        mkdir(segmentation_outputs_directory)
    end

    [a,b,c] = fileparts(T1_acpc_template_brain);
    if(~strcmp(a,segmentation_outputs_directory))
        copyfile(T1_acpc_template_brain,segmentation_outputs_directory);
    end
    T1_acpc_template_brain = fullfile(segmentation_outputs_directory, [b c]);

    [a,b,c] = fileparts(template_acpc_brainmask);
    if(~strcmp(a,segmentation_outputs_directory))
        copyfile(template_acpc_brainmask,segmentation_outputs_directory);
    end
    template_acpc_brainmask = fullfile(segmentation_outputs_directory, [b c]);

    if (~isempty(BOLD_template_image))
        [a,b,c] = fileparts(BOLD_template_image);
        if(~strcmp(a,segmentation_outputs_directory))
            copyfile(BOLD_template_image,segmentation_outputs_directory);
        end
        BOLD_template_image = fullfile(segmentation_outputs_directory, [b c]);
    end

    imageType = 'striatalCNNrotated_templateT1brain';
    [store,rotatedCNN_T1] = getRotatedCNN_image(store,T1_acpc_template_brain,segmentation_outputs_directory,imageType,'toCNN');
    imageType = 'striatalCNNrotated_templateBrainmask';
    [store,rotatedCNN_brainmask] = getRotatedCNN_image(store,template_acpc_brainmask,segmentation_outputs_directory,imageType,'toCNN');


    imageType = 'striatalCNNres_striatalCNNrotated_templateT1brain';
    isMask = false;
    imagePrefix = 'striatalCNNres_';
    [store,reslicedRotatedCNN_T1] = getReslicedCNN_image(store,rotatedCNN_T1,CNN_reslice_template,imageType,imagePrefix,isMask);
    imageType = 'striatalCNNres_striatalCNNrotated_templateBrainmask';
    isMask = true;
    imagePrefix = 'striatalCNNres_';
    [store,reslicedRotatedCNN_brainmask] = getReslicedCNN_image(store,rotatedCNN_brainmask,CNN_reslice_template,imageType,imagePrefix,isMask);

    segmentation_python_output_intermediate_filename = 'CNN_striatal_python_output_intermediate.mat';
    segmentation_python_output_intermediate_fullpath = fullfile(segmentation_outputs_directory , segmentation_python_output_intermediate_filename);

    % Padding the brain mask
    [VV_reslicedRotatedCNN_brainmask,YY_reslicedRotatedCNN_brainmask] = tippVol(reslicedRotatedCNN_brainmask);
    % Set NaN values to 0
    YY_reslicedRotatedCNN_brainmask(isnan(YY_reslicedRotatedCNN_brainmask)) = 0;

    % The following is the default setting created by john, at "3"
    %     structuringElement = strel('cube',3);
    % Keep the same as above if you want the default setting.
    
    padded_brain_mask = logical(YY_reslicedRotatedCNN_brainmask);
    
    structuringElement = strel('cube',3);
    twiceEroded_padded_brain_mask = imerode(imerode(padded_brain_mask,structuringElement),structuringElement); %3D erosion once

    eroded_padded_brain_mask = padded_brain_mask;
    numDilations = 8;
    for i = 1:numDilations
        eroded_padded_brain_mask = imdilate(eroded_padded_brain_mask,structuringElement); %3D dilation once
    end

%     testVV = VV_reslicedRotatedCNN_brainmask;
%     testVV.fname = '/mnt/jxvs2_01/Thal_Loc_Data/RDoC_Analysis/TIPP_Home/temp1.nii';
%     spm_write_vol(testVV,eroded_padded_brain_mask);

    numErosions = 4 + numDilations;
    for i = 1:numErosions
        eroded_padded_brain_mask = imerode(eroded_padded_brain_mask,structuringElement); %3D erosion once
    end

    eroded_padded_brain_mask = eroded_padded_brain_mask & twiceEroded_padded_brain_mask;

%     testVV = VV_reslicedRotatedCNN_brainmask;
%     testVV.fname = '/mnt/jxvs2_01/Thal_Loc_Data/RDoC_Analysis/TIPP_Home/temp.nii';
%     spm_write_vol(testVV,eroded_padded_brain_mask);

    [out,mri] = pythonCNNstriatalSegmentation(segmentation_python_code , reslicedRotatedCNN_T1, segmentation_python_output_intermediate_fullpath, segmentation_directory, segmentation_outputs_directory);

    [store,raw_segmentation_filename] = segmentation_postprocessing(store,out,mri,eroded_padded_brain_mask,VV_reslicedRotatedCNN_brainmask,segmentation_outputs_directory);

    imageType = 'unrotated_striatalCNN_segmentation';
    [store,unrotatedCNN_segmentation] = getRotatedCNN_image(store,raw_segmentation_filename,segmentation_outputs_directory,imageType,'toACPC');

    imageType = 'anatRes_templateSpace_striatalCNNparcels';
    imagePrefix = [imageType '_'];
    isMask = true;
    [store,anatRes_templateSpace_striatalCNNparcels] = getReslicedCNN_image(store,unrotatedCNN_segmentation,T1_acpc_template_brain,imageType,imagePrefix,isMask);

    movefile([segmentation_outputs_directory '/anatRes_templateSpace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii'],[segmentation_outputs_directory '/anatRes_templateSpace_striatalCNNparcels.nii']);

    % make 10 ROIs - left and right for each of the 5 striatal regions
    filename_n=[segmentation_outputs_directory '/anatRes_templateSpace_striatalCNNparcels.nii'];
    [store]= getseparatedROIs(store,filename_n,segmentation_outputs_directory,'anat');


    if(~isempty(BOLD_template_image))
        imageType = 'BOLDRes_templateSpace_striatalCNNparcels';
        imagePrefix = [imageType '_'];
        isMask = true;
        [store,BOLDRes_templateSpace_striatalCNNparcels] = getReslicedCNN_image(store,unrotatedCNN_segmentation,BOLD_template_image,imageType,imagePrefix,isMask);

        movefile([segmentation_outputs_directory '/BOLDRes_templateSpace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii'],[segmentation_outputs_directory '/BOLDRes_templateSpace_striatalCNNparcels.nii']);
    
        filename_n=[segmentation_outputs_directory '/BOLDRes_templateSpace_striatalCNNparcels.nii'];
        [store]= getseparatedROIs(store,filename_n,segmentation_outputs_directory,'bold');

    
    end

    disp('Full striatal segmentation pipeline complete.');  pause(eps); drawnow;

end

function [store]= getseparatedROIs(store,filename_n,segmentation_outputs_directory,anat_or_bold_flag)
    
    % the five ROIs of interest 
    ROIs = {'ROI1','ROI2','ROI3','ROI4','ROI5'};
    
    [a,b,c]=fileparts(filename_n);
    V=spm_vol(filename_n);
    [Y,XYZ]=spm_read_vols(V);
    Ycopy=Y;
    for i=1:5
       Y=Ycopy;
       % set everything asides from the particular segmentation to 0
       Y(Y~=i)=0;
       Yl=Y; 
       % gather right ROIs
       Y(XYZ(1,:)<0)=0;
       ROIfilename = fullfile(segmentation_outputs_directory, [anat_or_bold_flag 'right' ROIs{i} c])
       V.fname=ROIfilename;
       spm_write_vol(V,Y);
       
       [aa,bb,cc]=fileparts(V.fname);
       imagefname=[bb cc];
       store.fname{end+1}=imagefname;
       store.imagetype{end+1}=['right' ROIs{i}];
       
       % gather left ROIs
       Yl(XYZ(1,:)>0)=0;
       ROIfilename = fullfile(segmentation_outputs_directory, [anat_or_bold_flag 'left' ROIs{i} c])
       V.fname=ROIfilename;
       spm_write_vol(V,Yl);
         
       [aa,bb,cc]=fileparts(V.fname);
       imagefname=[bb cc];
       store.fname{end+1}=imagefname;
       store.imagetype{end+1}=['left' ROIs{i}];

    end
    
end


function [store,rotatedFileText] = getRotatedCNN_image(store,T1_filename,segmentation_outputs_directory,imageType,direction)
    %Rotate 90 deg
    [a,b,c] = fileparts(T1_filename);
    if (strcmpi(direction,'toCNN'))
        ang = pi/2;
        rotatedFileText = fullfile(segmentation_outputs_directory, ['striatalCNNrotated_' b c]);
    elseif (strcmpi(direction,'toACPC'))
        ang = -pi/2;
        rotatedFileText = fullfile(segmentation_outputs_directory, ['striatalCNN_unrotated_' b c]);
    end
    MM = [1 0 0 0; 0 cos(ang) sin(ang) 0; 0 -sin(ang) cos(ang) 0; 0 0 0 1];
    [VV,YY] = tippVol(T1_filename);

    VV.mat = MM * VV.mat;

    VV.fname = rotatedFileText;
    if( exist(rotatedFileText,'file') )
        warning(['Overwriting file : ' rotatedFileText]); pause(eps); drawnow;
        delete(rotatedFileText); pause(eps); drawnow;
    elseif (existInclSymlinks(rotatedFileText))
        tryToDeleteSymlink(rotatedFileText);
    end
    spm_write_vol(VV,YY); pause(eps); drawnow;


    [a,b,c] = fileparts(VV.fname);
    imagefname = [b c];
    store.fname{end+1}=imagefname;
    store.imagetype{end+1}=imageType;


end

function [store,reslicedRotatedCNN_T1] = getReslicedCNN_image(store,source_T1,reslice_template,imageType,imagePrefix,isMask)
    %Reslice to the resolution desired by the CNN python script
    %If is a mask, will use nearest neighbor interpolation.  Make sure
    %isMask = true!
    %If not, uses 7th degree spline interpolation.
    if(isMask)
        slicejob{1}.spm.spatial.coreg.write.roptions.interp = 0; %Nearest neighbor interpolation
    else
        slicejob{1}.spm.spatial.coreg.write.roptions.interp = 7; %7th degree spline interpolation
    end
    slicejob{1}.spm.spatial.coreg.write.ref = {[reslice_template ',1']};

    slicejob{1}.spm.spatial.coreg.write.source = {[source_T1 ',1']};
    slicejob{1}.spm.spatial.coreg.write.roptions.wrap = [1,1,1];
    slicejob{1}.spm.spatial.coreg.write.roptions.mask = 0;
    slicejob{1}.spm.spatial.coreg.write.roptions.prefix = imagePrefix;
    [sourcePath,sourceName,sourceExtension] = fileparts(source_T1);
    reslicedRotatedCNN_T1 = fullfile(sourcePath, [imagePrefix sourceName sourceExtension]);
    if( exist(reslicedRotatedCNN_T1,'file') )
        warning(['Overwriting file : ' reslicedRotatedCNN_T1]); pause(eps); drawnow;
        delete(reslicedRotatedCNN_T1); pause(eps); drawnow;
    elseif (existInclSymlinks(reslicedRotatedCNN_T1))
        tryToDeleteSymlink(reslicedRotatedCNN_T1);
    end
    spm_jobman('run',{slicejob(1)}); pause(eps); drawnow;

    [a,b,c] = fileparts(reslicedRotatedCNN_T1);
    imagefname = [b c];
    store.fname{end+1}=imagefname;
    store.imagetype{end+1}=imageType;


end


function [out,mri] = pythonCNNstriatalSegmentation(segmentation_python_code , T1_acpc_restore_brain, segmentation_python_output_intermediate_fullpath, segmentation_network_weights_directory, segmentation_outputs_directory)
    disp('Deploying CNN Striatal Segmentation python script.'); pause(eps); drawnow;

    %call the python script that generates the striatal segmentations,
    %requring arg1, arg2, arg3.
    if(exist(segmentation_python_output_intermediate_fullpath,'file'))
        delete(segmentation_python_output_intermediate_fullpath); pause(eps); drawnow;
    elseif (existInclSymlinks(segmentation_python_output_intermediate_fullpath))
        tryToDeleteSymlink(segmentation_python_output_intermediate_fullpath);
    end
    segmentation_model_file = fullfile(segmentation_network_weights_directory,'model');
    checkpointFilePath = fullfile(segmentation_network_weights_directory,'checkpoint');
    checkpointFileString = sprintf([...
        'model_checkpoint_path: "' segmentation_model_file '"' '\n' ...
        'all_model_checkpoint_paths: "' segmentation_model_file '"' '\n' ...
        ]);
    try
        checkpointFileText = fileread(checkpointFilePath);
        if(strcmp(checkpointFileText,checkpointFileString))
            checkpointFileMatch = true;
        else
            checkpointFileMatch = false;
        end
    catch err
        checkpointFileMatch = false;
    end

    if(~checkpointFileMatch)
        fileID = fopen(checkpointFilePath,'w+'); pause(eps); drawnow;
        fprintf(fileID,checkpointFileString); pause(eps); drawnow;
        fclose(fileID); pause(eps); drawnow;
    end

    pythonCallString = ['python3 ' segmentation_python_code ' ' T1_acpc_restore_brain ' ' segmentation_python_output_intermediate_fullpath ' ' segmentation_network_weights_directory];
    [status,cmdout] = system(pythonCallString,'-echo'); pause(eps); drawnow;
    a = load(segmentation_python_output_intermediate_fullpath);
    out = squeeze(a.out);
    mri = a.mri;

    pause(eps); drawnow;
end



function [store,raw_segmentation_filename] = segmentation_postprocessing(store,out,mri,eroded_padded_brain_mask,VV_reslicedRotatedCNN_brainmask,segmentation_outputs_directory)
    % After previous step, we get a.out in size of 256x256x192x6, where
    % 6 represents the segmentation layers, including 1 for background.

    %     disp('Beginning striatal CNN segmentation post-processing.');
    x = size(out,1) - size(mri,1);
    out(1:x,:,:,:) = [];
    y = size(out,2) - size(mri,2);
    out(:,1:y,:,:) = [];
    z = size(out,3) - size(mri,3);
    out(:,:,1:z,:) = [];
    %     After last 3 lines, a.out's size changes to {{234x234x156x6}} since
    %     since we eliminated the padded elements. {{value}} depends on the original
    %     input image size/dimensions.

    %The cnn network produces probability distributions (whether the
    %voxels are striatal or not) so these values range from 0-1 and are
    %continuous decimal values, so in the next steps, we will change the
    %probability distributions into discrete values (0 or 1).
    out = out .*repmat(mri>0, [1,1,1,1,size(out,5)]);

    % The below is meant to take care of having the sixth
    % segmentation. We end up with 5 striatal regions and neglect
    % background.
    % That's what id-1 is meant for. Before that line,
    % we also give each vox an id # representing the striatal region
    % instead of the previous probability estimate. Also, each voxel is
    % only assigned to 1 stratial region based on the max function.
    [~,index] = max(out,[],4);
    out = index - 1;

    %   Remove anything outside of the brain mask, eroded by one voxel.
    outsideOfMask = ~eroded_padded_brain_mask;
    out(outsideOfMask) = 0;
    % disp('erosion removed here');

    raw_segmentation_filename = [segmentation_outputs_directory '/' 'raw_StriatalCNNparcels.nii'];

    VV_reslicedRotatedCNN_brainmask.fname = raw_segmentation_filename;
    if( exist(raw_segmentation_filename,'file') )
        warning(['Overwriting file : ' raw_segmentation_filename]); pause(eps); drawnow;
        delete(raw_segmentation_filename); pause(eps); drawnow;
    elseif (existInclSymlinks(raw_segmentation_filename))
        tryToDeleteSymlink(raw_segmentation_filename);
    end
    spm_write_vol(VV_reslicedRotatedCNN_brainmask,out); pause(eps); drawnow;

    imageType = 'raw_StriatalCNNparcels';
    %
    [a,b,c] = fileparts(VV_reslicedRotatedCNN_brainmask.fname);
    imagefname = [b c];

    store.fname{end+1}=imagefname;
    store.imagetype{end+1}=imageType;


end

function [fileExist] = existInclSymlinks(fname)
    fnameWithAsterisk = [fname,'*'];
    dirList = dir(fnameWithAsterisk);
    dirNames = {dirList.name};
    isFile = ~[dirList.isdir];
    [a,b,c] = fileparts(fname);
    fileNameNoPath = [b,c];
    fileExist = any( contains(dirNames,fileNameNoPath) & isFile );
end

function [] = tryToDeleteSymlink(fname)
    try
        warning(['Overwriting symlink : ' fname]); pause(eps); drawnow;
        unlinkCommand = ['unlink ' fname];
        system(unlinkCommand,'-echo'); pause(eps); drawnow;
    catch err
        disp(err);
        warning('Could not overwrite symlink');
    end
end
