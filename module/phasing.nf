#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*
========================================================================================
=                                 h3achipimputation                                    =
========================================================================================
 h3achipimputation imputation functions and processes.
----------------------------------------------------------------------------------------
 @Authors

----------------------------------------------------------------------------------------
 @Homepage / @Documentation
  https://github.com/h3abionet/chipimputation
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
*/

// Show help message
if (params.help){
    helpMessage()
    exit 0
}

// check if files exist [name, file1, file2, ...]
def check_files(file_list) {
    file_list.each { myfile ->
        if (!file(myfile).exists() && !file(myfile).isFile()) exit 1, "|-- ERROR: File ${myfile} not found. Please check your config file."
    }
}

process split_vcf_to_chrm {
    tag "split_${base}_${chrm}"
    label "medium"
    
    input:
    tuple dataset, file(dataset_vcf), ref_name, ref_vcf, chrm, file(eagle_genetic_map)
    
    output:
    tuple dataset, file(dataset_vcf_chrm), ref_name, ref_vcf, chrm, file(eagle_genetic_map)
    
    script:
    base = file(dataset_vcf.baseName).baseName
    dataset_vcf_chrm = "${base}_${chrm}.vcf.gz"
    """
    tabix ${dataset_vcf}
    bcftools view \
        --regions ${chrm} \
        -m2 -M2 -v snps \
        ${dataset_vcf} \
        -Oz -o ${dataset_vcf_chrm}
    """
}


process phase_vcf_chrm {
    tag "phase_${base}_${chrm}"
    label "medium"
    
    input:
        tuple val(dataset), file(dataset_vcf_chrm), val(ref_name), file(ref_vcf), chrm, file(eagle_genetic_map)
    
    output:
        tuple val(dataset), file("${phased_vcf_file}.vcf.gz"), val(ref_name), file(ref_vcf), val(chrm), file(eagle_genetic_map)
    
    script:
        base = file(dataset_vcf_chrm.baseName).baseName
        phased_vcf_file = "${base}_phased"
        """
        tabix -f ${dataset_vcf_chrm}
        tabix -f ${ref_vcf}
        eagle \
            --numThreads=${task.cpus} \
            --vcfTarget=${dataset_vcf_chrm} \
            --geneticMapFile=${eagle_genetic_map} \
            --vcfRef=${ref_vcf} \
            --vcfOutFormat=z \
            --chrom=${chrm} \
            --outPrefix=${phased_vcf_file} 2>&1 | tee ${phased_vcf_file}.log
        """
}



// def helpMessage() {
//     log.info"""
//     =========================================
//     h3achipimputation v${params.version}
//     =========================================
//     Usage:

//     The typical command for running the pipeline is as follows:

//     nextflow run h3abionet/chipimputation --reads '*_R{1,2}.fastq.gz' -profile standard,docker

//     Mandatory arguments (Must be specified in the configuration file, and must be surrounded with quotes):
//       --target_datasets             Path to input study data (Can be one ou multiple for multiple runs)
//       --genome                      Human reference genome for checking REF mismatch
//       --ref_panels                  Reference panels to impute to (Can be one ou multiple for multiple runs)
//       -profile                      Configuration profile to use. Can use multiple (comma separated)
//                                     Available: standard, conda, docker, singularity, test

//     Other options:
//       --outDir                      The output directory where the results will be saved
//       --email                       Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits
//       --name                        Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic.
//       --project_name                Project name. If not specified, target file name will be used as project name
//     """.stripIndent()
// }
