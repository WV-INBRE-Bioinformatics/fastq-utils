#! /bin/bash


## Uses bam files with marked duplicates from a specified source directory, removes the duplicates and their respective indexed files in a destination directory.
## in the specified dest_dir.

## Creates dest_dir if it does not already exist. If it exists (and is a directory), prompts for overwrite.
## If it exists and is a file, exits with error.

## Uses samtools version 1.3.1.

samtools_exec=/opt/samtools-1.3.1/bin/samtools

function usage {
  echo "usage: [options] sort_and_index_bams.sh source_dir dest_dir"
  echo "Options:"
  echo '    -h, --help:     show this help'
  echo '    -s, --samtools: samtools executable (defaults to $SAMTOOLS)'
}

while [ $# -gt 2 ] ; do
  case $1 in 
    -h | --help     ) usage
                      exit
                      ;;
    -s | --samtools ) shift
                      samtools_exec=$1
                      shift
                      ;;
    *               ) echo "Unknown option $1"
                      usage
                      exit 1
  esac
done

if [ "$#" -ne "2" ] ; then
  usage
  exit 1 
fi

source_dir=${1%/} 
dest_dir=${2%/}

if [ -f $dest_dir ]; then
  echo "${dest_dir} is a file"
  exit 1 
fi


mkdir -p ${dest_dir}

for f in ${source_dir}/*.bam ; do
  filename=$(basename $f)
  samplename=${filename%.bam}
  (
    ${samtools_exec} view -b -F 1024 -o ${dest_dir}/${filename} ${f}
    ${samtools_exec} index ${dest_dir}/${filename}
  ) & 
done

wait

