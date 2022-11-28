function [V,Y] = tippVol(fname)


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
    
    for i = 1:length(V)
        Y{i} = spm_read_vols(V{i});
        for j = 1:length(V{i})
            V{i}(j).dt = [16 0]; %cast structure to FLOAT32 so we don't end up with crappy image when we write new data with V structure
        end
        Y{i} = double(Y{i}); %cast to double so that we don't get stupid rounding errors when mathing about
        if V{i}(1).mat(1) > 0
            V{i}(1).mat(1,:) = -V{i}(1).mat(1,:);
            Y{i} = Y{i}(end:-1:1,:,:,:);
        end
    end
    
    if visstruct
        if length(V)==1
            V = V{1};
            Y = Y{1};
        else
            error('Something went terribly wrong');
        end
    end
end


end
