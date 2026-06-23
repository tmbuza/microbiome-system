###############################################################################
# Create MAS example data acquisition package
###############################################################################

mkdir -p data/metadata
mkdir -p data/manifests
mkdir -p data/raw/ena
mkdir -p data/raw/ncbi
mkdir -p data/inventory
mkdir -p data/validation
mkdir -p data/reports

###############################################################################
# Example BioProject metadata
###############################################################################

cat > data/metadata/runinfo-PRJNA802976.csv <<'EOF'
Run,BioProject,BioSample,LibraryStrategy,LibraryLayout,Platform,Model
SRR17868090,PRJNA802976,SAMN00000001,AMPLICON,PAIRED,ILLUMINA,Illumina MiSeq
SRR17868091,PRJNA802976,SAMN00000002,AMPLICON,PAIRED,ILLUMINA,Illumina MiSeq
SRR17868092,PRJNA802976,SAMN00000003,AMPLICON,PAIRED,ILLUMINA,Illumina MiSeq
EOF

cat > data/metadata/ena-PRJNA802976.tsv <<'EOF'
run_accession	sample_accession	study_accession	fastq_ftp
SRR17868090	SAMN00000001	PRJNA802976	ftp://example/SRR17868090_1.fastq.gz;ftp://example/SRR17868090_2.fastq.gz
SRR17868091	SAMN00000002	PRJNA802976	ftp://example/SRR17868091_1.fastq.gz;ftp://example/SRR17868091_2.fastq.gz
SRR17868092	SAMN00000003	PRJNA802976	ftp://example/SRR17868092_1.fastq.gz;ftp://example/SRR17868092_2.fastq.gz
EOF

cat > data/metadata/srr-accessions.txt <<'EOF'
SRR17868090
SRR17868091
SRR17868092
EOF

###############################################################################
# Example manifests
###############################################################################

cat > data/manifests/download-manifest.tsv <<'EOF'
run_accession	layout	repository	expected_fastq_files
SRR17868090	PAIRED	ENA	2
SRR17868091	PAIRED	ENA	2
SRR17868092	PAIRED	ENA	2
EOF

cat > data/manifests/test-manifest.tsv <<'EOF'
run_accession	layout	repository	expected_fastq_files
SRR17868090	PAIRED	ENA	2
SRR17868091	PAIRED	ENA	2
SRR17868092	PAIRED	ENA	2
EOF

###############################################################################
# Tiny example FASTQ files
###############################################################################

cat > /tmp/SRR17868090_1.fastq <<'EOF'
@SRR17868090.1/1
ACGTACGTACGT
+
FFFFFFFFFFFF
EOF

cat > /tmp/SRR17868090_2.fastq <<'EOF'
@SRR17868090.1/2
TGCATGCATGCA
+
FFFFFFFFFFFF
EOF

cat > /tmp/SRR17868091_1.fastq <<'EOF'
@SRR17868091.1/1
ACGTACGTACGT
+
FFFFFFFFFFFF
EOF

cat > /tmp/SRR17868091_2.fastq <<'EOF'
@SRR17868091.1/2
TGCATGCATGCA
+
FFFFFFFFFFFF
EOF

cat > /tmp/SRR17868092_1.fastq <<'EOF'
@SRR17868092.1/1
ACGTACGTACGT
+
FFFFFFFFFFFF
EOF

cat > /tmp/SRR17868092_2.fastq <<'EOF'
@SRR17868092.1/2
TGCATGCATGCA
+
FFFFFFFFFFFF
EOF

gzip -c /tmp/SRR17868090_1.fastq > data/raw/ena/SRR17868090_1.fastq.gz
gzip -c /tmp/SRR17868090_2.fastq > data/raw/ena/SRR17868090_2.fastq.gz
gzip -c /tmp/SRR17868091_1.fastq > data/raw/ena/SRR17868091_1.fastq.gz
gzip -c /tmp/SRR17868091_2.fastq > data/raw/ena/SRR17868091_2.fastq.gz
gzip -c /tmp/SRR17868092_1.fastq > data/raw/ena/SRR17868092_1.fastq.gz
gzip -c /tmp/SRR17868092_2.fastq > data/raw/ena/SRR17868092_2.fastq.gz

###############################################################################
# Example inventory and validation outputs
###############################################################################

cat > data/inventory/fastq-inventory-ena.tsv <<'EOF'
file	run_accession	read	directory
SRR17868090_1.fastq.gz	SRR17868090	1	data/raw/ena
SRR17868090_2.fastq.gz	SRR17868090	2	data/raw/ena
SRR17868091_1.fastq.gz	SRR17868091	1	data/raw/ena
SRR17868091_2.fastq.gz	SRR17868091	2	data/raw/ena
SRR17868092_1.fastq.gz	SRR17868092	1	data/raw/ena
SRR17868092_2.fastq.gz	SRR17868092	2	data/raw/ena
EOF

cat > data/validation/validation-report.tsv <<'EOF'
item	status	notes
metadata	OK	example metadata present
fastq_files	OK	six paired-end example FASTQ files present
manifest	OK	example manifest present
EOF