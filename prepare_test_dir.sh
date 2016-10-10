#/bin/bash

# prepare_subdir creates 48 files whose filenames vary according to have or not capital letters in
# basenames or extensions, having or not not english characters in basenames, having or not spaces
# in basenames, having or not too large extensions (that finally are not extensions).
function prepare_subdir()
{
    DIRPATH=$1
    SUFFIX2=$2

    mkdir -p "$DIRPATH"

    PREFIX_ARRAY=( "" "with_sp_ " )
    SUFFIX1_ARRAY=( "" "_áéíóúñ" )

    for PREFIX in "${PREFIX_ARRAY[@]}"
    do
        for SUFFIX1 in "${SUFFIX1_ARRAY[@]}"
        do
            touch "$DIRPATH""$PREFIX""lowercase"$SUFFIX1""$SUFFIX2".txt"
            touch "$DIRPATH""$PREFIX""lowercase"$SUFFIX1""$SUFFIX2".avi"
            touch "$DIRPATH""$PREFIX""lowercase"$SUFFIX1""$SUFFIX2".sh"
            touch "$DIRPATH""$PREFIX""upper_in_BASENAME"$SUFFIX1""$SUFFIX2".ini"
            touch "$DIRPATH""$PREFIX""upper_in_extension"$SUFFIX1""$SUFFIX2".AVI"
            touch "$DIRPATH""$PREFIX""upper_in_BOTH"$SUFFIX1""$SUFFIX2".SH"

            touch "$DIRPATH""$PREFIX""lowercase_no_ext""$SUFFIX1""$SUFFIX2"
            touch "$DIRPATH""$PREFIX""upper_in_BASENAME_no_ext""$SUFFIX1""$SUFFIX2"

            touch "$DIRPATH""$PREFIX""lowercase"$SUFFIX1""$SUFFIX2".xlextension"
            touch "$DIRPATH""$PREFIX""upper_in_BASENAME"$SUFFIX1""$SUFFIX2".xlextension"
            touch "$DIRPATH""$PREFIX""upper_in_extension"$SUFFIX1""$SUFFIX2".XLEXTENSION"
            touch "$DIRPATH""$PREFIX""upper_in_BOTH"$SUFFIX1""$SUFFIX2".XLEXTENSION"
        done
    done
}

OUTPUT_DIR=/tmp/dir_analysis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEST_DIR=$SCRIPT_DIR"/testdir/"

prepare_subdir $TEST_DIR ""

prepare_subdir $TEST_DIR"testdir1/" "_1"
prepare_subdir $TEST_DIR"testdir1/testdir11/" "_11"
prepare_subdir $TEST_DIR"testdir1/test dir12/" "_12"
prepare_subdir $TEST_DIR"testdir1/tesTDir13/" "_13"
prepare_subdir $TEST_DIR"testdir1/testdir_áéíóúñ_14/" "_14"
prepare_subdir $TEST_DIR"testdir1/test dir_áéíóúñ_15/" "_15"

prepare_subdir $TEST_DIR"testd ir2/" "_2"
prepare_subdir $TEST_DIR"testd ir2/testdir21/" "_21"
prepare_subdir $TEST_DIR"testd ir2/testd ir22/" "_22"
prepare_subdir $TEST_DIR"testd ir2/tesTDir23/" "_23"
prepare_subdir $TEST_DIR"testd ir2/testdir_áéíóúñ_24/" "_24"
prepare_subdir $TEST_DIR"testd ir2/test dir_áéíóúñ_25/" "_25"

prepare_subdir $TEST_DIR"testdir_áéíóúñ_3/" "_3"
prepare_subdir $TEST_DIR"testdir_áéíóúñ_3/testdir31/" "_31"
prepare_subdir $TEST_DIR"testdir_áéíóúñ_3/testd ir32/" "_32"
prepare_subdir $TEST_DIR"testdir_áéíóúñ_3/tesTDir33/" "_33"
prepare_subdir $TEST_DIR"testdir_áéíóúñ_3/testdir_áéíóúñ_34/" "_34"
prepare_subdir $TEST_DIR"testdir_áéíóúñ_3/test dir_áéíóúñ_35/" "_35"

prepare_subdir $TEST_DIR"testd ir_áéíóúñ_4/" "_4"
prepare_subdir $TEST_DIR"testd ir_áéíóúñ_4/testdir41/" "_41"
prepare_subdir $TEST_DIR"testd ir_áéíóúñ_4/testd ir42/" "_42"
prepare_subdir $TEST_DIR"testd ir_áéíóúñ_4/tesTDir43/" "_43"
prepare_subdir $TEST_DIR"testd ir_áéíóúñ_4/testdir_áéíóúñ_44/" "_44"
prepare_subdir $TEST_DIR"testd ir_áéíóúñ_4/test dir_áéíóúñ_45/" "_45"

# Directories that are expected to be removed after applying dir_manager because they get empty
# Not all of them will be removed in every test
mkdir -p $TEST_DIR"testdir5/testdir51/"
touch $TEST_DIR"testdir5/testdir51/file51.sh"

mkdir -p $TEST_DIR"testdir5/testdir52/"
touch $TEST_DIR"testdir5/testdir52/file52.avi"

mkdir -p $TEST_DIR"testdir5/testdir53/"
touch $TEST_DIR"testdir5/testdir53/file53.sh"
touch $TEST_DIR"testdir5/testdir53/file53.avi"


