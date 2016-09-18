#/bin/bash

function prepare_subdir()
{
    DIRPATH=$1
    SUFFIX=$2

    mkdir -p "$DIRPATH"

    touch "$DIRPATH""without_upper"$SUFFIX".txt"
    touch "$DIRPATH""upper_in_BAsename"$SUFFIX".ini"
    touch "$DIRPATH""upper_in_extension"$SUFFIX".AVI"
    touch "$DIRPATH""upper_in_Both"$SUFFIX".sh"
    touch "$DIRPATH""sp_w ithout_upper"$SUFFIX".txt"
    touch "$DIRPATH""sp_u pper_in_BAsename"$SUFFIX".ini"
    touch "$DIRPATH""sp_u pper_in_extension"$SUFFIX".AVI"
    touch "$DIRPATH""sp_u pper_in_Both"$SUFFIX".sh"
    touch "$DIRPATH""without_upper_áéíóúñ"$SUFFIX".txt"
    touch "$DIRPATH""upper_in_BAsename_áéíóúñ"$SUFFIX".ini"
    touch "$DIRPATH""upper_in_extension_áéíóúñ"$SUFFIX".AVI"
    touch "$DIRPATH""upper_in_Both_áéíóúñ"$SUFFIX".sh"
    touch "$DIRPATH""sp_w ithout_upper_áéíóúñ"$SUFFIX".txt"
    touch "$DIRPATH""sp_u pper_in_BAsename_áéíóúñ"$SUFFIX".ini"
    touch "$DIRPATH""sp_u pper_in_extension_áéíóúñ"$SUFFIX".AVI"
    touch "$DIRPATH""sp_u pper_in_Both_áéíóúñ"$SUFFIX".sh"

    touch "$DIRPATH""without_upper_no_ext"$SUFFIX""
    touch "$DIRPATH""upper_in_BAsename_no_ext"$SUFFIX""
    touch "$DIRPATH""upper_in_extension_no_ext"$SUFFIX""
    touch "$DIRPATH""upper_in_Both_no_ext"$SUFFIX""
    touch "$DIRPATH""sp_w ithout_upper_no_ext"$SUFFIX""
    touch "$DIRPATH""sp_u pper_in_BAsename_no_ext"$SUFFIX""
    touch "$DIRPATH""sp_u pper_in_extension_no_ext"$SUFFIX""
    touch "$DIRPATH""sp_u pper_in_Both_no_ext"$SUFFIX""
    touch "$DIRPATH""without_upper_áéíóúñ_no_ext"$SUFFIX""
    touch "$DIRPATH""upper_in_BAsename_áéíóúñ_no_ext"$SUFFIX""
    touch "$DIRPATH""upper_in_extension_áéíóúñ_no_ext"$SUFFIX""
    touch "$DIRPATH""upper_in_Both_áéíóúñ_no_ext"$SUFFIX""
    touch "$DIRPATH""sp_w ithout_upper_áéíóúñ_no_ext"$SUFFIX""
    touch "$DIRPATH""sp_u pper_in_BAsename_áéíóúñ_no_ext"$SUFFIX""
    touch "$DIRPATH""sp_u pper_in_extension_áéíóúñ_no_ext"$SUFFIX""
    touch "$DIRPATH""sp_u pper_in_Both_áéíóúñ_no_ext"$SUFFIX""

    touch "$DIRPATH""without_upper"$SUFFIX".largeextension"
    touch "$DIRPATH""upper_in_BAsename"$SUFFIX".largeextension"
    touch "$DIRPATH""upper_in_extension"$SUFFIX".largeextension"
    touch "$DIRPATH""upper_in_Both"$SUFFIX".largeextension"
    touch "$DIRPATH""sp_w ithout_upper"$SUFFIX".largeextension"
    touch "$DIRPATH""sp_u pper_in_BAsename"$SUFFIX".largeextension"
    touch "$DIRPATH""sp_u pper_in_extension"$SUFFIX".largeextension"
    touch "$DIRPATH""sp_u pper_in_Both"$SUFFIX".largeextension"
    touch "$DIRPATH""without_upper_áéíóúñ"$SUFFIX".largeextension"
    touch "$DIRPATH""upper_in_BAsename_áéíóúñ"$SUFFIX".largeextension"
    touch "$DIRPATH""upper_in_extension_áéíóúñ"$SUFFIX".largeextension"
    touch "$DIRPATH""upper_in_Both_áéíóúñ"$SUFFIX".largeextension"
    touch "$DIRPATH""sp_w ithout_upper_áéíóúñ"$SUFFIX".largeextension"
    touch "$DIRPATH""sp_u pper_in_BAsename_áéíóúñ"$SUFFIX".largeextension"
    touch "$DIRPATH""sp_u pper_in_extension_áéíóúñ"$SUFFIX".largeextension"
    touch "$DIRPATH""sp_u pper_in_Both_áéíóúñ"$SUFFIX".largeextension"
}

OUTPUT_DIR=/tmp/dir_analysis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

prepare_subdir $SCRIPT_DIR"/testdir/" ""
prepare_subdir $SCRIPT_DIR"/testdir/testdir1/" "1"
prepare_subdir $SCRIPT_DIR"/testdir/testdir1/testdir11/" "11"
prepare_subdir $SCRIPT_DIR"/testdir/testdir1/test dir12/" "12"
prepare_subdir $SCRIPT_DIR"/testdir/testdir1/tesTDir13/" "13"
prepare_subdir $SCRIPT_DIR"/testdir/testd ir2/" "2"
prepare_subdir $SCRIPT_DIR"/testdir/testd ir2/testdir21/" "21"
prepare_subdir $SCRIPT_DIR"/testdir/testd ir2/testd ir22/" "22"

