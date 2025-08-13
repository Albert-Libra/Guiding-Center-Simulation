function [count, t_val, x_val, y_val, z_val, p_para_val] = read_gct(filename)
    % This function reads a binary file(.gct) containing guiding center trajectory data.
    % The function returns:
    %   count      : number of records
    %   t_val      : array of time values, Epoch time [s]
    %   x_val      : array of GSM x position, [RE]
    %   y_val      : array of GSM y positions, [RE]
    %   z_val      : array of GSM z positions, [RE]
    %   p_para_val : array of parallel momentum values, [MeV*s/RE]
    
    fid = fopen(filename, 'rb');
    if fid < 0
        error('Failed to open file %s', filename);
    end
    
    % Read the number of records
    count = fread(fid, 1, 'int32'); % 'long' is 8 bytes on some platforms, use 'int32' if 4 bytes
    if isempty(count)
        error('File is empty or has an incorrect format');
    end
    
    % Read all data
    data = fread(fid, [5, count], 'double')';
    fclose(fid);

    if size(data,1) ~= count
        warning('The actual number of data rows (%d) does not match the expected count (%d). The file may not have been completely written.', size(data,1), count);
        % Pad the data to the expected length to avoid indexing errors
        data(count,5) = 0;
    end
    
    % Assign to corresponding arrays
    t_val      = data(:,1);
    x_val      = data(:,2);
    y_val      = data(:,3);
    z_val      = data(:,4);
    p_para_val = data(:,5);
    
end