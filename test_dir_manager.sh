#/bin/bash

reset_test_dir()
{
    rm -rf $OUTPUT_DIR
    rm -rf $TEST_DIR
    $SCRIPT_DIR/prepare_test_dir.sh
    rm -rf $TEMP_DIR
    mkdir -p $TEMP_DIR
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR=$SCRIPT_DIR/output
TEST_DIR=$SCRIPT_DIR/testdir
TMP_DIR=/tmp/dir_manager
TREE_OUTPUT=$TMP_DIR/tree_output.tx


# In $TEST_DIR, rename all extensions to lowercase, keep only english chars and replace all whitespaces with _
reset_test_dir
$SCRIPT_DIR/dir_manager.sh -l -k -s _ $OUTPUT_DIR $TEST_DIR
tree $TEST_DIR --dirsfirst > $TREE_OUTPUT
diff $TREE_OUTPUT salida2.txt > /dev/null || { echo 'Invalid directory'; exit 1; }


# In $TEST_DIR removes all .sh (case insensitive) files
reset_test_dir
$SCRIPT_DIR/dir_manager.sh -r sh $OUTPUT_DIR $TEST_DIR


# In $TEST_DIR, move all .avi (case insensitive) files to $OUTPUT_DIR
reset_test_dir
$SCRIPT_DIR/dir_manager.sh -m avi $OUTPUT_DIR $TEST_DIR


# In $TEST_DIR, rename all extensions to lowercase, keep only english chars, replace all whitespaces with _,
# removes all .sh (case insensitive) files, move all .avi (case insensitive) files to $OUTPUT_DIR
reset_test_dir
$SCRIPT_DIR/dir_manager.sh -l -k -s _ -r sh -m avi $OUTPUT_DIR $TEST_DIR
