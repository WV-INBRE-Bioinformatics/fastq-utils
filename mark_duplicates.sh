#! /bin/bash

## Marks duplicates for all bam files in source_dir, writing the new bam files to dest_dir. Bam files are indexed
## after marking duplicates. Duplicate metrics are written to a txt file of the form file_dup_metrics.txt, where file.bam
## is the original file name.


#java_bin=/opt/jdk1.8.0_102/bin/java
#picard_tools=/opt/picard-tools-2.6.0/picard.jar
#samtools=/opt/samtools-1.3/samtools

java_bin=$JAVA_HOME/bin/java
picard_tools=$PICARD
samtools=$SAMTOOLS

function usage {
  echo "usage: mark_duplicates.sh [options] source_dir dest_dir"
  echo "Options:"
  echo "    -h, --help:     show this help"
  echo '    -s, --samtools: samtools executable (defaults to $SAMTOOLS)'
  echo '    -p, --picard:   picard jar file (defaults to $PICARD)'
  echo '    -j, --java:     Java runtime executable (defaults to $JAVA_HOME/bin/java)'
  echo '    -x, --maxJVMs:  Maximum number of JVMs (default: no maximum)'
}

while [ $# -gt 2 ]; do
    case $1 in 
      -h | --help     ) usage
                        exit
                        ;;
      -s | --samtools ) shift
                        samtools=$1
                        shift
                        ;;
      -p | --picard   ) shift
                        picard=$1
                        shift
                        ;;
      -j | --java     ) shift
                        java_bin=$1
                        shift
                        ;;
      -x | --maxJVMs  ) shift
                        maxJVMs=$1
                        shift
                        ;;
      *               ) echo "Unknown option $1"
                        usage
                        exit 1
    esac
done

if [ "$#" -ne "2" ]; then
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
  echo "${dest_dir} exists: overwrite? (y/n)"
  read response
  if [ "$response" -ne "y" ]; then
    exit
  fi
fi

mkdir -p ${dest_dir}

files=( ${source_dir}/*.bam )
numFiles=${#files[@]}

if [ ! ${maxJVMs} ]; then
    maxJVMs=${numFiles}
fi

start=0

while [ $start -lt $numFiles ] ; do 


	for f in ${files[@]:start:maxJVMs}; do 
	  filename=$(basename $f)
	  sample=${filename%.bam}
	  (
		${java_bin} -jar ${picard_tools} MarkDuplicates QUIET=true I=${f} O=${dest_dir}/${filename} M=${dest_dir}/${sample}_dup_metrics.txt
		${samtools} index ${dest_dir}/${filename}
	  ) &
	done

	wait
	
	start=$[ $start + $maxJVMs ]

done
