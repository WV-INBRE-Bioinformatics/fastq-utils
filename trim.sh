#/bin/bash

## Trims all pairs of *_R1.fastq.gz and *_R2.fastq.gz files in source
## directory and sends output to files with the same name in destination directory,
## using Trimmomatic.
## Unpaired reads are sent to files in unpaired directory.

## Default options. Uses java 1.8.0_102 and trimmomatic 0.36.

java=$JAVA_HOME
trimmomatic=$TRIMMOMATIC

function usage {
  echo "usage: [options] trim.sh source_directory destination_directory unpaired_directory"
  echo "Options:"
  echo "    -a, --adapterFile:    adapterFile (defaults to none, so no adapter trimming performed)"
  echo '    -t, --trimmomatic:    trimmomatic jar file (defaults to $TRIMMOMATIC)'
  echo '    -j, --java:           Java installation directory (defaults to $JAVA_HOME)'
  echo '    -x, --maxJVMs:        Maximum number of JVMs to create at one time (defaults to no maximum)'
  echo '    -c, --initialCrop     Crop reads to this length prior to adapter trimming (default: no cropping)'
}

while [ $# -gt 3 ] ; do
  case $1 in
    -h | --help         ) usage
                          exit
                          ;;
    -a | --adapterFile  ) shift
                          adapterFile=$1
                          shift
                          ;;
    -t | --trimmomatic  ) shift
                          trimmomatic=$1
                          shift
                          ;;
    -j | --java         ) shift
                          java=$1
                          shift
                          ;;
    -x | --maxJVMs      ) shift
                          maxJVMs=$1
                          shift
                          ;;
    -c | --initialCrop  ) shift
                          crop=$1
			  shift
			  ;;
    *                   ) echo "Unknown option $1"
                          usage
                          exit 1
  esac
done

if [ $# -lt 3 ]; then
  usage
  exit 1
fi

source_dir=${1%/}
dest_dir=${2%/}
unpaired_dir=${3%/}

if [ ! -d ${source_dir} ] ; then 
  echo "${source_dir} is not a directory"
  exit
fi

if [ -f $dest_dir ] ; then
  echo "${dest_dir} is a file"
  exit
fi

if [ -f $unpaired_dir ] ; then
  echo "${unpaired_dir} is a file"
  exit
fi

mkdir -p ${dest_dir}
mkdir -p ${unpaired_dir}

if [ ${crop} ] ; then
  trims="CROP:${crop} "
fi

if [ ${adapterFile} ] ; then
  trims="${trims}ILLUMINACLIP:${adapterFile}:2:30:10 "
fi
trims="${trims}LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:25"

r1Files=( ${source_dir}/*_R1.fastq.gz )
numFiles=${#r1Files[@]}

if [ ! ${maxJVMs} ]; then
    maxJVMs=${numFiles}
fi

start=0

while [ $start -lt $numFiles ] ; do 

	for f in ${r1Files[@]:start:maxJVMs}; do
		samp=$(basename $f)
		samp=${samp%_R1.fastq.gz}
	
		(
		  ${java}/bin/java -jar ${trimmomatic} PE ${source_dir}/${samp}_R1.fastq.gz ${source_dir}/${samp}_R2.fastq.gz ${dest_dir}/${samp}_R1.fastq.gz ${unpaired_dir}/${samp}_R1.fastq.gz ${dest_dir}/${samp}_R2.fastq.gz ${unpaired_dir}/${samp}_R2.fastq.gz ${trims}
		  exit_code=$?
		  if [ "${exit_code}"=="0" ]; then
			echo "$(date): Trimming ${samp} complete"
		  else 
			echo "$(date): Trimming ${samp} failed"
		  fi
		  exit $exit_code
		)&
	done
	wait

    start=$[ $start + $maxJVMs ]
done
