function [precision, recall] = precisionRecall(pag, gtpag)
% [PRECISION, RECALL] = PRECISIONRECALL(PCG, GTPCG) Returns precision and
% recall for comparing a  pag to the ground truth pag(as described in Tillman et al, learning
% equivalence classes...)
% precision = # of edges in pag that are in the gtpag (with correct orientations)/# of edges in pag
% recall = # of edges in pag that are in the gtpag (with correct orientation)/# of edges in gtpag
% NOTE: if i understood correctly, they do not take under consideration
% whether the edge is dashed or solid.

nEdgesPag = nnz(pag);
nEdgesGtPag = nnz(gtpag);
nCorrectEdges = nnz(((pag-gtpag)==0)& ((pag'-gtpag')==0) & ~~pag);
%nCorrectEdges = nnz(~triu(pcg-gtpcg & pcg'-gtpcg')&~~pcg);
precision = nCorrectEdges/nEdgesPag;
recall = nCorrectEdges/nEdgesGtPag;
end

