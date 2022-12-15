function [obj] = CNNStriatalSegmentation(obj)
    pause(eps); drawnow;
    % Uses T1w_acpc_dc_restore_brain.nii, ac-pc aligned (acpc), readout distortion
    % corrected (dc), bias field corrected (restore), skull-stripped (brain), T1w images.

    if isa(obj,'TIPPstudy')
        numSubjects = length(obj.(obj.sub));
        for i = 1:numSubjects
            obj.(obj.sub)(i).CNNStriatalSegmentation(); pause(eps); drawnow;
        end
    elseif ~isa(obj,'TIPPsubj')
        obj.par.CNNStriatalSegmentation();
    else %isa(obj,'TIPPsubj') - main function call
        obj = TIPPinternal_CNNStriatalSegmentation(obj);
    end

end

function [obj] = TIPPinternal_CNNStriatalSegmentation(obj)
    % For TIPPsubj only
    % Uses T1w_acpc_dc_restore_brain.nii, ac-pc aligned (acpc), readout distortion
    % corrected (dc), bias field corrected (restore), skull-stripped (brain), T1w images.

    % Get paths for things

    %Remove images from previous runs of this code first
    imageTypesUsed = { ...
        'striatalCNNrotated_NATt1brain', 'striatalCNNrotated_NATbrainmask', ...
        'unrotated_striatalCNN_segmentation', ...
        'anatRes_NATspace_striatalCNNparcels','BOLDRes_NATspace_striatalCNNparcels', ...
        'raw_StriatalCNNparcels', ...
        'striatalCNNres_striatalCNNrotated_NATt1brain','striatalCNNres_striatalCNNrotated_NATbrainmask'};
    for i = 1:length(imageTypesUsed)
        thisImageType = imageTypesUsed{i};
        obj.removeImagesOfType(thisImageType);
    end


    getFileNameBool = true;
    imageType = 'NATt1brain';
    [imagesOfType] = getImagesOfType(obj,imageType,getFileNameBool);
    if(length(imagesOfType) > 1)
        error('More than one T1 for a subject - need to decide what to do.  Should we average them?');
    elseif(length(imagesOfType) < 1)
        error('No T1 for a subject.')
    end
    T1_acpc_dc_restore_brain = imagesOfType{1}; %Get the char vector out of the cell

    %   imageType = 'NATbrainmask';
    imageType = 'MNIbrainmask';

    [imagesOfType] = getImagesOfType(obj,imageType,getFileNameBool);
    if(length(imagesOfType) > 1)
        error('More than one brain mask for a subject.');
    elseif(length(imagesOfType) < 1)
        error('No brain mask for a subject.')
    end
    nat_acpc_brainmask = imagesOfType{1};


    % Need to get a NATepi as a template
    imageType = 'NATepi';
    getFileNameBool = true;
    tippset = obj.set(1);
    tipptasks = [tippset.task];
    for i = 1:length(tipptasks)
        tippruns = [tipptasks(i).run];
        for j = 1:length(tippruns)
            [imagesOfType] = getImagesOfType(tippruns(i),imageType,getFileNameBool);
            if(length(imagesOfType) >= 1)
                break;
            end
        end
    end
    if(length(imagesOfType) < 1)
        error('No EPI images for a subject.')
    end
    BOLD_template_image = imagesOfType{1};

    segmentation_intermediate_directory = obj.home;

    [store]=main_CNNStriatalSegmentation('T1_acpc_dc_restore_brain',T1_acpc_dc_restore_brain,...
        'nat_acpc_brainmask',nat_acpc_brainmask,...
        'BOLD_template_image',BOLD_template_image,...
        'segmentation_intermediate_directory',segmentation_intermediate_directory);

    for i=2:length(store.fname)
        obj.imgs(end+1) = TIPPimg(store.fname{i},store.imagetype{i});
    end



end
