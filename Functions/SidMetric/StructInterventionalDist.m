function [SID_upper, SID_lower] = StructInterventionalDist(trueDag, estG)

    Nnodes=size(trueDag,2);
    
    rcodePath= fileparts(which('sidR.R'));
    
    save2txt(strcat(rcodePath,'\trueDag.txt'), trueDag,'%d', Nnodes, Nnodes);
    save2txt(strcat(rcodePath,'\estG.txt'), estG,'%d', Nnodes, Nnodes);

    
    rscript = '"C:\Program Files\R\R-3.6.3\bin\Rscript.exe" ';

    command = [rscript, rcodePath, '\sidR.R '];                 
    status = system(command);

    idFile1 = fopen(strcat(rcodePath,'\sidLower.txt'),'r');
    SID_lower=fscanf(idFile1,"%f");
    fclose(idFile1);

    idFile2 = fopen(strcat(rcodePath,'\sidUpper.txt'),'r');
    SID_upper=fscanf(idFile2,"%f");
    fclose(idFile2);
    
end
