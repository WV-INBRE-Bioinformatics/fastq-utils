## Aligns paired-end data using HISAT2.
## Data are read from the supplied source folder, which is assumed to have
## a file ending _R1.fastq.gz for the first read for a given sample, with a
## matching file ending _R2.fastq.gz for the second read for the same sample.

## Data are output to the specified output folder, using the file name without _R1.fastq.gz
## as the name of the resulting bam file, and with a .log extension for the standard output. 

#hisat=/opt/hisat2-2.0.4/hisat2
#samtools=/opt/samtools-1.3.1/samtools
hisat=$HISAT
samtools=$SAMTOOLS
center=Marshall_Genomics_Core
platform=Illumina
model=HiSeq1500

function usage {
  echo "usage: [options] align.sh source_dir genome_file output_dir"
  echo "Options:"
  echo '    -h, --help:      Show this help'
  echo '    -H, --hisat:     HISAT2 executable (defaults to $HISAT)'
  echo '    -s, --samtools:  samtools executable (defaults to $SAMTOOLS)'
  echo "    -c, --center:    center tag for read group in bam file (defaults to Marshall_Genomics_Core)"
  echo "    -p, --platform:  platform tag for read group in bam file (defaults to Illumina)"
  echo "    -m, --model:     model tag for read group in bam file (defaults to HiSeq1500)"
}


while [ $# -gt 3 ] ; do
  case $1 in 
    -h | --help     ) usage
                      exit
                      ;;
    -s | --samtools ) shift
                      samtools=$1
                      shift
                      ;;
    -H | --hisat    ) shift
                      hisat=$1
                      shift
                      ;;
    -c | --center   ) shift
                      center=$1
                      shift
                      ;;
    -p | --platform ) shift
                      platform=$1
                      shift
                      ;;
    -m | --model    ) shift
                      model=$1
                      shift
                      ;;
    *               ) echo "Unknown option $1"
                      usage
                      exit 1
  esac 
done

if [ $# -lt 3 ]; then
  usage
  exit
fi

source_dir=${1%/}
genome_file=$2
dest_dir=${3%/}

if [ ! -d ${source_dir} ] ; then 
  echo "${source_dir} is not a directory"
  exit
fi

if [ -f $dest_dir ] ; then
  echo "${dest_dir} is a file"
  exit
fi

if [ -d $dest_dir ] ; then 
  echo "${dest_dir} exists: overwrite? (y/n)"
  read response 
  if [ "$response" != "y" ] ; then 
    exit 
  fi
fi

mkdir -p $dest_dir

for f in ${source_dir}/*_R1.fastq.gz; do
  samp=$(basename $f)
  samp=${samp%_R1.fastq.gz}
  (
    ${hisat} --phred33 --no-mixed --rg-id ${samp} --rg SM:${samp} --rg CN:${center} --rg PL:${platform} --rg PM:${model}  -x ${genome_file} -1 ${f} -2 ${f/_R1.fastq.gz/_R2.fastq.gz} 2>${dest_dir}/${samp}.log | ${samtools} view -b -o ${dest_dir}/${samp}.bam -
    exit_code=$?
    if [ "${exit_code}"=="0" ]; then 
        echo "$(date): Aligning ${samp} complete"
    else
        echo "$(date): Aligning ${samp} failed"
    fi
    exit $exit_code
  )&
done 
wait
