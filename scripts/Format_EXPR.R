library(data.table)
library(R.utils)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

tpm = as.matrix( read.csv( file.path(input_dir, "EXP_TPM.tsv"), stringsAsFactors=FALSE , sep="\t" , header=TRUE ) )
rownames(tpm) = sapply( tpm[,1] , function(x){ unlist( strsplit( x , "_" , fixed=TRUE ) )[1] } )
tpm = tpm[,-1]

rid = rownames(tpm)
cid = colnames(tpm)
tpm = apply(apply(tpm,2,as.character),2,as.numeric)
colnames(tpm) = cid
rownames(tpm) = rid

#############################################################################
#############################################################################
## Remove duplicate genes

expr_uniq <- tpm[!(rownames(tpm)%in%rownames(tpm[duplicated(rownames(tpm)),])),]
expr_dup <- tpm[(rownames(tpm)%in%rownames(tpm[duplicated(rownames(tpm)),])),]

expr_dup <- expr_dup[order(rownames(expr_dup)),]
id <- unique(rownames(expr_dup))

expr_dup.rm <- NULL
names <- NULL
for(j in 1:length(id)){
	tmp <- expr_dup[which(rownames(expr_dup)%in%id[j]),]
	tmp.sum <- apply(tmp,1,function(x){sum(as.numeric(as.character(x)),na.rm=T)})
	tmp <- tmp[which(tmp.sum%in%max(tmp.sum,na.rm=T)),]

	if( is.null(dim(tmp)) ){
	  expr_dup.rm <- rbind(expr_dup.rm,tmp) 
	  names <- c(names,names(tmp.sum)[1])
	}   
}
tpm <- rbind(expr_uniq,expr_dup.rm)
rownames(tpm) <- c(rownames(expr_uniq),names)
tpm = tpm[sort(rownames(tpm)),]

#############################################################################
#############################################################################

# sampleID = read.csv( file.path(input_dir, "sampleID.txt"), stringsAsFactors=FALSE , sep="\t" )
# rownames(sampleID) = sampleID$Patient
# 
# colnames(tpm) =  sampleID[ colnames(tpm) , ]$GEO

#############################################################################
#############################################################################

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
tpm = log2( tpm[ , colnames(tpm) %in% case[ case$expr %in% 1 , ]$patient ] + 1 )

write.table( tpm , file= file.path(output_dir, "EXPR.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=TRUE )
