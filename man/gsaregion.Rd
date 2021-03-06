% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/goregion.R
\name{gsaregion}
\alias{gsaregion}
\title{Generalised gene set testing for Illumina's methylation array data}
\usage{
gsaregion(
  regions,
  all.cpg = NULL,
  collection,
  array.type = c("450K", "EPIC"),
  plot.bias = FALSE,
  prior.prob = TRUE,
  anno = NULL,
  equiv.cpg = TRUE,
  fract.counts = TRUE
)
}
\arguments{
\item{regions}{\code{GRanges} Object of DMR coordinates to test for GO term
enrichment.}

\item{all.cpg}{Character vector of all CpG sites tested. Defaults to all CpG
sites on the array.}

\item{collection}{A list of user specified gene sets to test. Can also be a
single character vector gene set. Gene identifiers must be Entrez Gene IDs.}

\item{array.type}{The Illumina methylation array used. Options are "450K" or
"EPIC". Defaults to "450K".}

\item{plot.bias}{Logical, if true a plot showing the bias due to the
differing numbers of probes per gene will be displayed.}

\item{prior.prob}{Logical, if true will take into account the probability of
significant differentially methylation due to numbers of probes per gene. If
false, a hypergeometric test is performed ignoring any bias in the data.}

\item{anno}{Optional. A \code{DataFrame} object containing the complete
array annotation as generated by the \code{\link{minfi}}
\code{\link{getAnnotation}} function. Speeds up execution, if provided.}

\item{equiv.cpg}{Logical, if true then equivalent numbers of cpgs are used
for odds calculation rather than total number cpgs. Only used if 
\code{prior.prob=TRUE}.}

\item{fract.counts}{Logical, if true then fractional counting of cpgs is used
to account for cgps that map to multiple genes. Only used if 
\code{prior.prob=TRUE}.}
}
\value{
A data frame with a row for each gene set and the following columns:
\item{N}{ number of genes in the gene set } \item{DE}{ number of genes that
are differentially methylated } \item{P.DE}{ p-value for over-representation
of the gene set } \item{FDR}{ False discovery rate, calculated using the
method of Benjamini and Hochberg (1995).  }
}
\description{
Given a user specified list of gene sets to test, \code{gsameth} tests
whether differentially methylated regions (DMRs) identified from Illumina's
Infinium HumanMethylation450 or MethylationEPIC array are enriched, taking
into account the differing number of probes per gene present on the array.
}
\details{
This function extends \code{gometh}, which only tests GO and KEGG pathways.
\code{gsameth} can take a list of user specified gene sets and test whether
the significant DMRs are enriched in these pathways. This function takes a
\code{GRanges} object of DMR coordinates, maps them to CpG sites on the
array and then to Entrez Gene IDs, and tests for enrichment using a
hypergeometric test, taking into account the number of CpG sites per gene on
the 450K/EPIC array.  Geeleher et al. (2013) showed that a severe bias
exists when performing gene set analysis for genome-wide methylation data
that occurs due to the differing numbers of CpG sites profiled for each
gene. \code{gsameth} and \code{gometh} is based on the \code{goseq} method
(Young et al., 2010). If \code{prior.prob} is set to FALSE, then prior
probabilities are not used and it is assumed that each gene is equally
likely to have a significant CpG site associated with it. 

The testing now also takes into account that some CpGs map to multiple genes. 
For a small number of gene families, this previously caused their associated 
GO categories/gene sets to be erroneously overrepresented and thus highly 
significant. If \code{fract.counts=FALSE} then CpGs are allowed to map to 
multiple genes (this is NOT recommended).

Genes associated with each CpG site are obtained from the annotation package
\code{IlluminaHumanMethylation450kanno.ilmn12.hg19} if the array type is
"450K". For the EPIC array, the annotation package
\code{IlluminaHumanMethylationEPICanno.ilm10b4.hg19} is used. To use a
different annotation package, please supply it using the \code{anno}
argument. 

In order to get a list which contains the mapped Entrez gene IDS,
please use the \code{getMappedEntrezIDs} function.
}
\examples{

\dontrun{ # to avoid timeout on Bioconductor build
library(IlluminaHumanMethylation450kanno.ilmn12.hg19)
library(org.Hs.eg.db)
library(limma)
library(DMRcate)
data(dmrcatedata)
myMs <- logit2(myBetas)
myMs.noSNPs <- rmSNPandCH(myMs, dist=2, mafcut=0.05)
patient <- factor(sub("-.*", "", colnames(myMs)))
type <- factor(sub(".*-", "", colnames(myMs)))
design <- model.matrix(~patient + type) 
myannotation <- cpg.annotate("array", myMs.noSNPs, what="M", arraytype = "450K",
                             analysis.type="differential", design=design, coef=39)
dmrcoutput <- dmrcate(myannotation, lambda=1000)
regions <- extractRanges(dmrcoutput)

ann <- getAnnotation(IlluminaHumanMethylation450kanno.ilmn12.hg19)
# All CpG sites tested
allcpgs <- rownames(ann)
# Use org.Hs.eg.db to extract a GO term
GOtoID <- suppressMessages(select(org.Hs.eg.db, keys=keys(org.Hs.eg.db), 
                                  columns=c("ENTREZID","GO"), keytype="ENTREZID"))
keep.set1 <- GOtoID$GO \%in\% "GO:0010951"
set1 <- GOtoID$ENTREZID[keep.set1]
keep.set2 <- GOtoID$GO \%in\% "GO:0042742"
set2 <- GOtoID$ENTREZID[keep.set2]
# Make the gene sets into a list
sets <- list(set1, set2)
names(sets) <- c("GO:0010951","GO:0042742")
# Testing with prior probabilities taken into account
# Plot of bias due to differing numbers of CpG sites per gene
gst <- gsaregion(regions = regions, all.cpg = allcpgs, collection = sets, 
                plot.bias = TRUE, prior.prob = TRUE)
topGSA(gst)
# Testing ignoring bias
gst.bias <- gsaregion(regions = regions, all.cpg = allcpgs, collection = sets, 
                    prior.prob = FALSE)
topGSA(gst.bias)
}

}
\references{
Phipson, B., Maksimovic, J., and Oshlack, A. (2016). missMethyl:
an R package for analysing methylation data from Illuminas
HumanMethylation450 platform. \emph{Bioinformatics}, \bold{15};32(2),
286--8. 

Geeleher, P., Hartnett, L., Egan, L. J., Golden, A., Ali, R. A. R.,
and Seoighe, C. (2013). Gene-set analysis is severely biased when applied to
genome-wide methylation data. \emph{Bioinformatics}, \bold{29}(15),
1851--1857. 

Young, M. D., Wakefield, M. J., Smyth, G. K., and Oshlack, A.
(2010). Gene ontology analysis for RNA-seq: accounting for selection bias.
\emph{Genome Biology}, 11, R14. 

Ritchie, M. E., Phipson, B., Wu, D., Hu, Y.,
Law, C. W., Shi, W., and Smyth, G. K. (2015). limma powers differential
expression analyses for RNA-sequencing and microarray studies. \emph{Nucleic
Acids Research}, gkv007. 

Benjamini, Y., and Hochberg, Y. (1995). Controlling
the false discovery rate: a practical and powerful approach to multiple
testing. \emph{Journal of the Royal Statistical Society Series}, B,
\bold{57}, 289-300.
}
\seealso{
\code{\link{gometh},\link{getMappedEntrezIDs}}
}
\author{
Belinda Phipson
}
