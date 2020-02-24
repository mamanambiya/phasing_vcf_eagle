# Genotype phasing Workflow using Eagle2

[![Build Status](https://travis-ci.org/h3abionet/chipimputation.svg?branch=master)](https://travis-ci.org/h3abionet/chipimputation)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A50.30.0-brightgreen.svg)](https://www.nextflow.io/)

[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg)](http://bioconda.github.io/)
[![Docker](https://img.shields.io/docker/automated/nfcore/chipimputation.svg)](https://hub.docker.com/r/h3abionet/chipimputation)
![Singularity Container available](
https://img.shields.io/badge/singularity-available-7E4C74.svg)

### Introduction
The pipeline is for genotype phasing (haplotype inference) a VCF file using Eagle2. 
It is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner.   
It comes with singularity containers making installation trivial and results highly reproducible.

### Setup

#### Headnode
  - [Nextflow](https://www.nextflow.io/) (can be installed as local user)
   - NXF_HOME needs to be set, and must be in the PATH
   - Note that we've experienced problems running Nextflow when NXF_HOME is on an NFS mount.
   - The Nextflow script also needs to be invoked in a non-NFS folder
  - Java 1.8+

#### Compute nodes

- The compute nodes need to have singularity installed.
- The compute nodes need access to shared storage for input, references, output
- The following commands need to be available in PATH on the compute nodes, in case of unavailabitity of singularity.

  - `vcftools` from [VCFtools](https://vcftools.github.io/index.html)
  - `bcftools`from [bcftools](https://samtools.github.io/bcftools/bcftools.html)
  - `bgzip` from [htslib](http://www.htslib.org)
  - `eagle` from [Eagle](https://data.broadinstitute.org/alkesgroup/Eagle/)


### How to run 
```nextflow run main.nf -profile singularity,test```