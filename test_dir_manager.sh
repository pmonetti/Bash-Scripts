#/bin/bash

reset_test_dir()
{
    rm -rf $OUTPUT_DIR
    rm -rf $TEST_DIR
    $SCRIPT_DIR/prepare_test_dir.sh
    rm -rf $TMP_DIR
    mkdir -p $TMP_DIR
}

replace()
{
    FILEPATH=$1
    OLD=$2
    NEW=$3
    sed "s/$OLD/$NEW/g" $FILEPATH > $REPLACE_TMP_FILE
    cp $REPLACE_TMP_FILE $FILEPATH
}

remove_line()
{
    FILEPATH=$1
    SUBSTRING=$2
    sed "/$SUBSTRING/d" $FILEPATH > $REPLACE_TMP_FILE
    cp $REPLACE_TMP_FILE $FILEPATH
}

rename_expected_tree_files()
{
    replace $EXPECTED_TREE ".AVI" ".avi"
    replace $EXPECTED_TREE ".EXE" ".exe"
    replace $EXPECTED_TREE "áéíóúñ" "aeioun"
    replace $EXPECTED_TREE "with_sp " "with_sp_"
    replace $EXPECTED_TREE "testd ir" "testd_ir"
    replace $EXPECTED_TREE "test dir" "test_dir"
}

remove_expected_tree_files()
{
    remove_line $EXPECTED_TREE ".EXE"
    remove_line $EXPECTED_TREE ".exe"
    remove_line $EXPECTED_TREE "testdir51"
}

move_expected_tree_files()
{
    remove_line $EXPECTED_TREE ".EXE"
    remove_line $EXPECTED_TREE ".exe"
    remove_line $EXPECTED_TREE "testdir51"
}


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR=$SCRIPT_DIR/output
TEST_DIR=$SCRIPT_DIR/testdir
TMP_DIR=/tmp/dir_manager
ORIGINAL_TREE=$TMP_DIR/original_tree.txt
EXPECTED_TREE=$TMP_DIR/expected_tree.txt
OUTPUT_TREE=$TMP_DIR/output_tree.txt
REPLACE_TMP_FILE=$TMP_DIR/replace_tmp_file.txt


# In $TEST_DIR, rename all extensions to lowercase, keep only english chars and replace all whitespaces with _
echo "*********** Running Test 1***********"
reset_test_dir
tree $TEST_DIR --dirsfirst --noreport > $ORIGINAL_TREE
cp $ORIGINAL_TREE $EXPECTED_TREE
rename_expected_tree_files
$SCRIPT_DIR/dir_manager.sh -l -k -s _ $OUTPUT_DIR $TEST_DIR
tree $TEST_DIR --dirsfirst --noreport > $OUTPUT_TREE
diff $OUTPUT_TREE $EXPECTED_TREE > /dev/null || { echo '"*********** Test 1 Failed ***********"'; exit 1; }
echo "*********** Test 1 Ok ***********"

# In $TEST_DIR removes all .exe (case insensitive) files
echo "*********** Running Test 2***********"
reset_test_dir
tree $TEST_DIR --dirsfirst --noreport > $ORIGINAL_TREE
cp $ORIGINAL_TREE $EXPECTED_TREE
replace $EXPECTED_TREE "└" "├"
remove_expected_tree_files
$SCRIPT_DIR/dir_manager.sh -r exe $OUTPUT_DIR $TEST_DIR
tree $TEST_DIR --dirsfirst --noreport > $OUTPUT_TREE
replace $OUTPUT_TREE "└" "├"
diff $OUTPUT_TREE $EXPECTED_TREE > /dev/null || { echo '"*********** Test 2 Failed ***********"'; exit 1; }
echo "*********** Test 2 Ok ***********"


# In $TEST_DIR, move all .avi (case insensitive) files to $OUTPUT_DIR
#reset_test_dir
#$SCRIPT_DIR/dir_manager.sh -m avi $OUTPUT_DIR $TEST_DIR


# In $TEST_DIR, rename all extensions to lowercase, keep only english chars, replace all whitespaces with _,
# removes all .exe (case insensitive) files, move all .avi (case insensitive) files to $OUTPUT_DIR
#reset_test_dir
#$SCRIPT_DIR/dir_manager.sh -l -k -s _ -r exe -m avi $OUTPUT_DIR $TEST_DIR


rm -rf $OUTPUT_DIR
rm -rf $TEST_DIR