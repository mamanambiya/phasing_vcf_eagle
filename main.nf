#!/usr/bin/env nextflow
nextflow.preview.dsl=2
include { check_files } from './module/phasing'
include { split_vcf_to_chrm } from './module/phasing'
include { phase_vcf_chrm } from './module/phasing'

workflow {
    // check if study genotype files exist
    if(params.target_datasets) {
        params.target_datasets.each { name, vcf ->
            check_files([vcf])
        }
    }
    else{
        println "|-- ERROR: Missing parameter ${params.target_datasets}. Please check your config file."
        exit 1
    }
    // check if eagle map file exists
    if(params.eagle_genetic_map) {
        check_files([params.eagle_genetic_map])
    }
    else{
        println "|-- ERROR: Missing parameter ${params.eagle_genetic_map}. Please check your config file."
        exit 1
    }
    // check if ref panels and eagle map files exist, and build main data object
    target_datasets = []
    if(params.ref_panels) {
        params.ref_panels.each{ ref_name, ref_vcf ->
            params.chromosomes.each { chrm ->
                ref_vcf_chrm = file(sprintf(ref_vcf, chrm))
                check_files([ref_vcf_chrm])
                params.target_datasets.each { dataset, dataset_vcf ->
                    target_datasets << [dataset, file(dataset_vcf), ref_name, ref_vcf_chrm, chrm, file(params.eagle_genetic_map)]
                }
            }
        }
    }
    else{
        println "|-- ERROR: Missing parameter ${params.ref_panels}. Please check your config file."
        exit 1
    }

    // Step 1: Check chromosome
    datasets = Channel.from(target_datasets)
    split_vcf_to_chrm(datasets) | \
    phase_vcf_chrm
}
