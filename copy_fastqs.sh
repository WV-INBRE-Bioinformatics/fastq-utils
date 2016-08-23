#/bin/bash

## Copies all fastq.gz files from Sample subdirectories of the provided
## project directories into the specified destination directory.

## Assumes exactly one *_R1*.fastq.gz file and exactly one matching *_R2* file
## in each sample directory.

## Sample directories are names Sample_* and must be unique among all project directories.
## Copied files are named xxx_R1.fastq.gz and xxx_R2.fastq.gz where the source Sample directory is Sample_xxx.

function usage {
  echo "usage: copy_fastqs.sh destination_dir project_dirs"
}

# echo $#
# echo ${@}

if [ "$#" -lt "2" ]; then 
  usage
  exit
fi

dest_dir=${1%/}
shift
project_dirs=${@}

if [ -f $dest_dir ] ; then
  echo "${dest_dir} is a file"
  exit
fi

if [ -d $dest_dir ] ; then
  echo "${dest_dir} exists: overwrite (y/n)"
  read response
  if [ "$response" != "y" ]; then
    exit
  fi
fi

mkdir -p $dest_dir

for project_dir in ${project_dirs}
do
  for sample_dir in ${project_dir}/Sample_* 
  do
    sample=${sample_dir#${project_dir}/Sample_}
    for r1_file in ${sample_dir}/*_R1*.fastq.gz 
    do
      cp ${r1_file} ${dest_dir}/${sample}_R1.fastq.gz &
    done
    for r2_file in ${sample_dir}/*_R2*.fastq.gz
    do
      cp ${r2_file} ${dest_dir}/${sample}_R2.fastq.gz &
    done
  done
done
wait
