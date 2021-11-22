#!/usr/env/bin nextflow

// Stage two channels for input dummy files
Channel.fromFilePairs("dummy_files/*_R{1,2}.fastq.gz", checkIfExists: true).view()
       .into{ ch_fwd; ch_rev }

// split into forward, reverse reads
forward_reads = ch_fwd.map{ it -> [ it[0], it[1][0] ] }.view()
reverse_reads = ch_rev.map{ it -> [ it[0], it[1][1] ] } 

// Sanity check with a process

process check_reads{

    echo true

    input:
    tuple val(base), file(R1), file(R2) from forward_reads.join(reverse_reads)

    output:
    stdout to out

    script:
    """
    echo "Sample ID: ${base}, read1 file: ${R1}, read2 file: ${R2}"
    """
}
