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
    [T1_acpc_dc_restore_brain, nat_acpc_brainmask, segmentation_outputs_directory, BOLD_template_image] = deal([]);
    while (currentArgNumber <= numArgIn)
        StringCurrentArg = (string(varargin{currentArgNumber}));
        numToAdd = 2;
        switch(StringCurrentArg)
            case "T1_acpc_dc_restore_brain"
                T1_acpc_dc_restore_brain = varargin{currentArgNumber + 1};
            case "nat_acpc_brainmask"
                nat_acpc_brainmask = varargin{currentArgNumber + 1};
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
    
    copyfile(T1_acpc_dc_restore_brain,segmentation_outputs_directory);
    [a,b,c] = fileparts(T1_acpc_dc_restore_brain);
    T1_acpc_dc_restore_brain = fullfile(segmentation_outputs_directory, [b c]);

    copyfile(nat_acpc_brainmask,segmentation_outputs_directory);
    [a,b,c] = fileparts(nat_acpc_brainmask);
    nat_acpc_brainmask = fullfile(segmentation_outputs_directory, [b c]);

    if (~isempty(BOLD_template_image))
        copyfile(BOLD_template_image,segmentation_outputs_directory);
        [a,b,c] = fileparts(BOLD_template_image);
        BOLD_template_image = fullfile(segmentation_outputs_directory, [b c]);
    end

    imageType = 'striatalCNNrotated_NATt1brain';
    [store,rotatedCNN_T1] = getRotatedCNN_image(store,T1_acpc_dc_restore_brain,segmentation_outputs_directory,imageType,'toCNN');
    imageType = 'striatalCNNrotated_NATbrainmask';
    [store,rotatedCNN_brainmask] = getRotatedCNN_image(store,nat_acpc_brainmask,segmentation_outputs_directory,imageType,'toCNN');


    imageType = 'striatalCNNres_striatalCNNrotated_NATt1brain';
    isMask = false;
    imagePrefix = 'striatalCNNres_';
    [store,reslicedRotatedCNN_T1] = getReslicedCNN_image(store,rotatedCNN_T1,CNN_reslice_template,imageType,imagePrefix,isMask);
    imageType = 'striatalCNNres_striatalCNNrotated_NATbrainmask';
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
    structuringElement = strel('cube',3);

    padded_brain_mask = logical(YY_reslicedRotatedCNN_brainmask);
    eroded_padded_brain_mask = imerode(padded_brain_mask,structuringElement); %3D erosion once

    [out,mri] = pythonCNNstriatalSegmentation(segmentation_python_code , reslicedRotatedCNN_T1, segmentation_python_output_intermediate_fullpath, segmentation_directory, segmentation_outputs_directory);

    [store,raw_segmentation_filename] = segmentation_postprocessing(store,out,mri,eroded_padded_brain_mask,VV_reslicedRotatedCNN_brainmask,segmentation_outputs_directory);

    imageType = 'unrotated_striatalCNN_segmentation';
    [store,unrotatedCNN_segmentation] = getRotatedCNN_image(store,raw_segmentation_filename,segmentation_outputs_directory,imageType,'toACPC');

    imageType = 'anatRes_NATspace_striatalCNNparcels';
    imagePrefix = [imageType '_'];
    isMask = true;
    [store,anatRes_NATspace_striatalCNNparcels] = getReslicedCNN_image(store,unrotatedCNN_segmentation,T1_acpc_dc_restore_brain,imageType,imagePrefix,isMask);

    movefile([segmentation_outputs_directory '/anatRes_NATspace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii'],[segmentation_outputs_directory '/anatRes_NATspace_striatalCNNparcels.nii']);

    if(~isempty(BOLD_template_image))
        imageType = 'BOLDRes_NATspace_striatalCNNparcels';
        imagePrefix = [imageType '_'];
        isMask = true;
        [store,BOLDRes_NATspace_striatalCNNparcels] = getReslicedCNN_image(store,unrotatedCNN_segmentation,BOLD_template_image,imageType,imagePrefix,isMask);

        movefile([segmentation_outputs_directory '/BOLDRes_NATspace_striatalCNNparcels_striatalCNN_unrotated_raw_StriatalCNNparcels.nii'],[segmentation_outputs_directory '/BOLDRes_NATspace_striatalCNNparcels.nii']);
    end

    disp('Full striatal segmentation pipeline complete.');  pause(eps); drawnow;



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

        tf_out_modified = zeros(size(mri));

        % The below is meant to take care of having the sixth
        % segmentation. We end up with 5 striatal regions and neglect
        % background. That's what id-1 is meant for. Before that line,
        % we also give each vox an id # representing the striatal region
        % instead of the previous probability estimate. Also, each voxel is
        % only assigned to 1 stratial region based on the max function.
        for vox = 1:numel(tf_out_modified)
            %         vox
            [xx,yy,zz] = ind2sub(size(tf_out_modified),vox);
            [v,id] = max(out(xx,yy,zz,:));
            tf_out_modified(vox) = id - 1;
        end
        out = tf_out_modified;

        %   Remove anything outside of the brain mask, eroded by one voxel.
        outsideOfMask = ~eroded_padded_brain_mask;
        out(outsideOfMask) = 0;
        % disp('erosion removed here');

        raw_segmentation_filename = [segmentation_outputs_directory '/' 'raw_StriatalCNNparcels.nii'];

        VV_reslicedRotatedCNN_brainmask.fname = raw_segmentation_filename;
        if( exist(raw_segmentation_filename,'file') )
            warning(['Overwriting file : ' raw_segmentation_filename]); pause(eps); drawnow;
            delete(raw_segmentation_filename); pause(eps); drawnow;
        end
        spm_write_vol(VV_reslicedRotatedCNN_brainmask,out); pause(eps); drawnow;

        imageType = 'raw_StriatalCNNparcels';
        %
        [a,b,c] = fileparts(VV_reslicedRotatedCNN_brainmask.fname);
        imagefname = [b c];

        store.fname{end+1}=imagefname;
        store.imagetype{end+1}=imageType;


    end
end
