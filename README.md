# extract-sequences-from-big_genome extract dna seq from big-genomes based blast results with your query sequences
youd better to run these scripts one by one and check the results after each step to make the next step
you could use this scripts to extract your pourpuse genes, and your need cut the cds into several frags consindering the introns
# 0.for the genome size so large, like the formerly reported one, Protopterus annectens, we need to cut the genome into proper size to satisfied with our computer. sometimes when you bulid the blast library, it will get errors, notice that
  I: make sure the perl version higer;
  II: choose the blast not blast+, casue we found the old version of blast is more sensitive than blast+

# 1-cheak_chromosome_infor.pl: check the infor of chromosoems
# 2-chromosomes_split_inner_chr.pl: cut the genome chromosomes based on the last infor and then do the blast, 
or you can just cut by the whole chromosomes with 2-chromosomes_split_inter_chr_for_large_chro.pl; need to clarify that you should keep the sccaffolds and check the results after blast with scaffold, if matched you query, you need to extract its scaffold as a single chromosome to extract the porpuse seqs
# 3-1.single.select.seq-genome_seek_blast.pl: one way (for larger blast results) stored all chromosomes, then you could select the purpose fas within blast results. 
Or with 3-1.single.select.seq-blast_seek_genome.pl,  another script for small items within blast result involved of less chromosomes;
# 3-2.combined.gene.region-genome_seek_blast.pl dr 3-2.combined.gene.region-blast_seek_genome.plscripts the above 3-1 ones: this step you need mannually select the blast results and got the mannually.blast.gene.m8, then perform this script
# 4.manually_tranfer.complementary.complete.pl: change the complement chains based on the results A-T,T-A,C-G,G-C

## at last, you need check the results if satisfied with your purpose, if not, try:
  I: cut the genome with differemt size of segements, like 1G or 2G, exclude the breakage point caused error
  II: try to lower the evalue of blast, cause your query seq sometimes is too short like a region of cds with minner tens of bps, the strict evalue will screen your porpuse seqs
