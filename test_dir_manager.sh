#/bin/bash

# Replaces in all the lines, from the specified file $1, $2 with $3
replace_lines()
{
    FILEPATH=$1
    OLD=$2
    NEW=$3
    sed -i "s|$OLD|$NEW|g" $FILEPATH
}

# Removes all lines, from the specified file $1, that contains the specified substring $2
rm_lines()
{
    FILEPATH=$1
    SUBSTRING=$2
    sed "/$SUBSTRING/d" $FILEPATH > $REPLACE_TMP_FILE
    cp $REPLACE_TMP_FILE $FILEPATH
}

prepare_expected_data_1()
{
    replace_lines $EXPECTED_TREE ".AVI" ".avi"
    replace_lines $EXPECTED_TREE ".EXE" ".exe"
    replace_lines $EXPECTED_TREE "áéíóúñ" "aeioun"
    replace_lines $EXPECTED_TREE "with_sp " "with_sp_"
    replace_lines $EXPECTED_TREE "testd ir" "testd_ir"
    replace_lines $EXPECTED_TREE "test dir" "test_dir"
}

prepare_expected_data_2()
{
    rm_lines $EXPECTED_TREE ".EXE"
    rm_lines $EXPECTED_TREE ".exe"
    rm_lines $EXPECTED_TREE "testdir51"
}

prepare_expected_data_3()
{
    rm_lines $EXPECTED_TREE ".AVI"
    rm_lines $EXPECTED_TREE ".avi"
    rm_lines $EXPECTED_TREE "testdir52"
}

prepare_expected_data_4()
{
    replace_lines $EXPECTED_TREE "$TEST_DIR" "$OUTPUT_DIR"
    rm_lines $EXPECTED_TREE ".txt"
    rm_lines $EXPECTED_TREE ".exe"
    rm_lines $EXPECTED_TREE ".ini"
    rm_lines $EXPECTED_TREE ".EXE"
    rm_lines $EXPECTED_TREE "no_ext"
    rm_lines $EXPECTED_TREE ".xlextension"
    rm_lines $EXPECTED_TREE ".XLEXTENSION"
    rm_lines $EXPECTED_TREE "testdir51"
}

# Replaces in the tree descripted in the specified file $1 all ocurrences of "└" with "├"
# to make it easier the tests validations
normalize_tree()
{
    TREE_FILE=$1
    replace_lines $TREE_FILE "└" "├"
}

initialize_expected_tree()
{
    cp $ORIGINAL_TREE $EXPECTED_TREE
    normalize_tree $EXPECTED_TREE
}

# Generates a tree file $2 from specified directory $1
generate_tree()
{
    INPUT_DIR=$1
    TREE_FILE=$2
    tree $INPUT_DIR --dirsfirst --noreport > $TREE_FILE && normalize_tree $TREE_FILE
}

init_test()
{
    TEST_NUMBER=$1
    echo "*** Running Test "$TEST_NUMBER": "

    rm -rf $TMP_DIR && mkdir -p $TMP_DIR    
    rm -rf $OUTPUT_DIR
    rm -rf $TEST_DIR

    $SCRIPT_DIR/prepare_test_dir.sh

    tree $TEST_DIR --dirsfirst --noreport > $ORIGINAL_TREE   
}

print_ok()
{
    echo "$(tput setaf 2)OK$(tput sgr 0)"
}

exit_test()
{
    echo "$(tput setaf 1)FAILED!$(tput sgr 0)"
    exit 1
}

compare_output_vs_expected()
{
    DIR_TO_EVALUATE_PATH=$1
    generate_tree $DIR_TO_EVALUATE_PATH $OUTPUT_TREE
    diff $OUTPUT_TREE $EXPECTED_TREE >> /dev/null 2>&1 || exit_test
}

run_test_1()
{
    # In $TEST_DIR, rename all extensions to lowercase, keep only english chars and replace all whitespaces with _
    init_test "1"
    initialize_expected_tree
    prepare_expected_data_1

    $SCRIPT_DIR/dir_manager.sh -l -k -s _ $OUTPUT_DIR $TEST_DIR

    compare_output_vs_expected $TEST_DIR
    print_ok
}

run_test_2()
{
    # In $TEST_DIR removes all .exe (case insensitive) files
    init_test "2"
    initialize_expected_tree
    prepare_expected_data_2

    $SCRIPT_DIR/dir_manager.sh -r exe $OUTPUT_DIR $TEST_DIR

    compare_output_vs_expected $TEST_DIR
    print_ok
}

run_test_3()
{
    # In $TEST_DIR, move all .avi (case insensitive) files to $OUTPUT_DIR
    init_test "3"
    initialize_expected_tree
    prepare_expected_data_3

    $SCRIPT_DIR/dir_manager.sh -m avi $OUTPUT_DIR $TEST_DIR

    compare_output_vs_expected $TEST_DIR

    initialize_expected_tree
    prepare_expected_data_4
    compare_output_vs_expected $OUTPUT_DIR
    print_ok
}

run_test_4()
{
    # In $TEST_DIR, rename all extensions to lowercase, keep only english chars, replace all whitespaces with _,
    # removes all .exe (case insensitive) files, move all .avi (case insensitive) files to $OUTPUT_DIR
    init_test "4"
    initialize_expected_tree
    prepare_expected_data_1
    prepare_expected_data_2
    prepare_expected_data_3
    rm_lines $EXPECTED_TREE "testdir5"    

    $SCRIPT_DIR/dir_manager.sh -l -k -s _ -r exe -m avi $OUTPUT_DIR $TEST_DIR

    compare_output_vs_expected $TEST_DIR

    initialize_expected_tree
    prepare_expected_data_4
    prepare_expected_data_1
    compare_output_vs_expected $OUTPUT_DIR
    print_ok
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEST_DIR=$SCRIPT_DIR/testdir
OUTPUT_DIR=$SCRIPT_DIR/output
TMP_DIR=/tmp/test_dir_manager
ORIGINAL_TREE=$TMP_DIR/original_tree.txt
EXPECTED_TREE=$TMP_DIR/expected_tree.txt
OUTPUT_TREE=$TMP_DIR/output_tree.txt
REPLACE_TMP_FILE=$TMP_DIR/replace_tmp_file.txt

run_test_1
run_test_2
run_test_3
run_test_4

rm -rf $OUTPUT_DIR
rm -rf $TEST_DIR