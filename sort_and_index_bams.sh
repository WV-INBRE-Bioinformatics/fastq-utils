#! /bin/bash

## Sort and index all bam files in a specified source_directory, placing sorted files and index files
## in the specified dest_dir.

## Creates dest_dir if it does not already exist. If it exists (and is a directory), prompts for overwrite.
## If it exists and is a file, exits with error.

## Each sort is run in a background process. Temp files are written to dest_dir/tmp/sample_name.nnnn.bam where the sample_name
## is derived from the bam file name.

## Uses samtools version 1.3.1.

#samtools_exec=/opt/samtools-1.3.1/samtools
samtools_exec=$SAMTOOLS

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

if [ -d $dest_dir ]; then
  echo "${dest_dir} exists. Overwrite? (y/n)"
  read response
  if [ "$reponse" -ne "y" ]; then
    exit
  fi
fi

mkdir -p ${dest_dir}/tmp

for f in ${source_dir}/*.bam ; do
  filename=$(basename $f)
  samplename=${filename%.bam}
  ( 
    ${samtools_exec} sort -o ${dest_dir}/${filename} -T ${dest_dir}/tmp/${samplename} ${f}
    ${samtools_exec} index ${dest_dir}/${filename}
  ) &
done

wait

## clean up tmp:
rm -R ${dest_dir}/tmp
