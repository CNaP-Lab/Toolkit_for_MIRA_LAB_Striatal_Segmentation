function [V,Y,XYZ] = tippVol(fname)
    % [V,Y] = tippVol(fname)
    %
    % This is a wrapper function for spm_vol and spm_read_vols. If only one
    % output is requested, only the vol structure is loaded and returned.

    V = spm_vol(fname);

    visstruct = false;

    if nargout > 1
        if isstruct(V)
            visstruct = true;
            V = {V};
        end

        Y = cell(length(V),1);
        XYZ = cell(length(V),1);
        for i = 1:length(V)
            [Y{i},XYZ{i}] = spm_read_vols(V{i});
            for j = 1:length(V{i})
                V{i}(j).dt = [16 0]; %cast structure to FLOAT32 so we don't end up with crappy image when we write new data with V structure
            end
            Y{i} = double(Y{i}); %cast to double so that we don't get stupid rounding errors when mathing about
            if ( V{i}(j).mat(1) > 0 )
                for j = 1:length(V{i})
                    V{i}(j).mat(1,:) = -V{i}(j).mat(1,:);
                    Y{i}(:,:,:,j) = Y{i}(end:-1:1,:,:,j);
                    XYZ{i}(:,:,:,j) = XYZ{i}(end:-1:1,:,:,j);
                end
            end
        end

        if visstruct
            if length(V)==1
                V = V{1};
                Y = Y{1};
                XYZ = XYZ{1};
            else
                error('Something went terribly wrong');
            end
        end
    end

end
