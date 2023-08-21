#! /bin/bash
#
# Run script for flywheel/svrtk-fetal-brain-segmentation Gear.
#
# Authorship: Niall bourke
#

##############################################################################
# Define directory names and containers

FLYWHEEL_BASE=/flywheel/v0
INPUT_DIR=$FLYWHEEL_BASE/input/
OUTPUT_DIR=$FLYWHEEL_BASE/output
CONFIG_FILE=$FLYWHEEL_BASE/config.json
CONTAINER='[flywheel/svrtk-fetal-brain-segmentation]'
WORK=/flywheel/v0/work
mkdir -p ${WORK}

##############################################################################
# Parse configuration
function parse_config {

  CONFIG_FILE=$FLYWHEEL_BASE/config.json
  MANIFEST_FILE=$FLYWHEEL_BASE/manifest.json

  if [[ -f $CONFIG_FILE ]]; then
    echo "$(cat $CONFIG_FILE | jq -r '.config.'$1)"
  else
    CONFIG_FILE=$MANIFEST_FILE
    echo "$(cat $MANIFEST_FILE | jq -r '.config.'$1'.default')"
  fi
}

# define output choise:
config_output_nifti="$(parse_config 'output_nifti')"
# define options:
# config_motion="$(parse_config 'motion')"
# config_slice="$(parse_config 'sliceThickness')"
# config_res="$(parse_config 'resolution')"
# config_packages="$(parse_config 'packages')"


##############################################################################
# Handle INPUT files

echo "${CONTAINER}  Running auto-brain-bounti-segmentation-fetal algorithm"

# Set initial exit status
mri_svrtk_exit_status=0

# Find input file In input directory with the extension
# .nii, .nii.gz
input=`find $INPUT_DIR/input -iname '*.nii' -o -iname '*.nii.gz'`

# Check that input file exists
if [[ -e $input ]]; then
  echo "Input found: $input"
  cp ${input} ${WORK}/ 
fi

# Run brain-reconstruction if input files exist in the work directory
if [ "$(ls -A $WORK)" ]; then   
    echo "WORK directory contents:"
    echo "$(ls -l $WORK)"

    echo "Running brain-segmentation..."
    bash /home/auto-proc-svrtk/auto-brain-bounti-segmentation-fetal.sh $WORK $OUTPUT_DIR

    mri_svrtk_exit_status=$?
else
    echo "WORK directory is empty"
    echo "Exiting..."
    mri_svrtk_exit_status=$?
fi

##############################################################################
# Handle Exit status

if [[ $mri_svrtk_exit_status == 0 ]] && [[ "$(ls -A $OUTPUT_DIR)" ]]; then
  echo -e "${CONTAINER} Success!"
  exit 0
else
  echo "${CONTAINER}  Something went wrong! mri_svrtk exited non-zero!"
  exit 1
fi
