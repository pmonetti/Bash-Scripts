#/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR=$SCRIPT_DIR/output
TEST_DIR=$SCRIPT_DIR/testdir

rm -rf $OUTPUT_DIR
rm -rf $TEST_DIR

$SCRIPT_DIR/prepare_test_dir.sh
$SCRIPT_DIR/dir_manager.sh -l -e -s _ -r sh -m xml $OUTPUT_DIR $TEST_DIR

