setwd('C:/Users/konstantina/OCT/Functions/SidMetric')

suppressWarnings(suppressMessages(library(SID)))

#1. Load trueG, estG
trueDag=as.matrix(read.table('trueDag.txt',  header = FALSE, sep='\t'))
estG=as.matrix(read.table('estG.txt',  header = FALSE, sep='\t'))
#estG can be a DAG or a CPDAG

#page 5 SID doc: entry (i,j) is a directed edge from i to j
#page 8 SID doc: (i,j)=1, (j,i)=1 undirected edge, cpdag

#2.Compute sid
sid_val <- structIntervDist(trueDag,estG)


#3. Write sid 
write.table(sid_val$sidUpperBound,'sidUpper.txt',
            row.names=FALSE, col.names = FALSE)
write.table(sid_val$sidLowerBound,'sidLower.txt',
            row.names=FALSE, col.names = FALSE)