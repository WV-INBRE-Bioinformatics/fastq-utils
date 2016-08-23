#! /bin/bash

## Runs FastQC on all .fastq.gz files in the specified source directory,
## generating output in the specified output directory.

## For each .fastq.gz file in the source directory, a folder with a name matching the filename will
## be created in the output directory

fastqc=$FASTQC
threads=1
java=$JAVA_HOME/bin/java

function usage 
{
    echo "usage: generate_qcs.sh [options] source_dir output_dir"
    echo ""
    echo "Options:"
    echo "    -h, --help       show this help"
    echo '    -f, --fastqc     executable for fastqc. Defaults to $FASTQC'
    echo '    -t, --threads    number of threads for each process. Defaults to 1.'
    echo '    -j, --java       path to Java executable. Defaults to $JAVA_HOME/bin/java'
    echo ""
}

# echo "$#"

if [ $# -lt 2 ]; then
  usage 
  exit
fi

# echo "processing command line options"

while [ $# -gt 2 ]; do
  case $1 in
    -h | --help       ) usage
                        exit
                        ;;
    -f | --fastqc     ) shift
                        fastqc=$1
                        shift
                        ;;
    -j | --java       ) shift
                        java=$1
                        shift
                        ;;
    -t | --threads    ) shift
                        threads=$1
                        shift
                        ;;
    * )                 echo "unknown option $1"
                        usage
                        exit 1
  esac
done

source_dir=$1
output_dir=$2

if [ -f $output_dir ] ; then
  echo "${output_dir} is a file"
  exit
fi

if [ -d $output_dir ] ; then
  echo "${output_dir} exists: overwrite? (y/n)"
  read response 
  if [ "$response" != "y" ] ; then
    exit
  fi
fi

mkdir -p $output_dir

$fastqc -o ${output_dir} --threads ${threads} --java ${java} -q ${source_dir}/*.fastq.gz

#for f in ${source_dir}/*.fastq.gz ; do
#  samp=$(basename $f)
#  samp=${samp%.fastq.gz}
#  mkdir ${output_dir}/$samp
#  if [ "$bg" == "1" ] ; then 
#    (
#        $fastqc -o ${output_dir}/$samp --threads ${threads} --java ${java} -q $f 
#        echo "Fastqc files generated for ${samp}"
#    )&
#  else
#    $fastqc -o ${output_dir}/$samp --threads ${threads} --java ${java} -q $f
#    echo "Fastqc files generated for ${samp}"
#  fi
#done

wait
