function []=save2txt(filename, file_mat, type, ncols, nrows)
    
    id= fopen(filename,'w');    
    if strcmp(type, '%d')
        format = repmat('%d\t', [1 ncols-1]);
        formatFinal=strcat(format, '%d\n');
    elseif strcmp(type, '%f')
        format = repmat('%f\t', [1 ncols-1]);
        formatFinal=strcat(format, '%f\n');
    end
    for row = 1:nrows
        fprintf(id,formatFinal,file_mat(row,:));
    end
    fclose(id);
    
end
