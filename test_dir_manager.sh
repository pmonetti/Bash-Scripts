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
remove_lines()
{
    FILEPATH=$1
    SUBSTRING=$2
    sed "/$SUBSTRING/d" $FILEPATH > $REPLACE_TMP_FILE
    cp $REPLACE_TMP_FILE $FILEPATH
}

prepare_expected_output_1()
{
    replace_lines $EXPECTED_TREE ".AVI" ".avi"
    replace_lines $EXPECTED_TREE ".EXE" ".exe"
    replace_lines $EXPECTED_TREE "áéíóúñ" "aeioun"
    replace_lines $EXPECTED_TREE "with_sp " "with_sp_"
    replace_lines $EXPECTED_TREE "testd ir" "testd_ir"
    replace_lines $EXPECTED_TREE "test dir" "test_dir"
}

prepare_expected_output_2()
{
    remove_lines $EXPECTED_TREE ".EXE"
    remove_lines $EXPECTED_TREE ".exe"
    remove_lines $EXPECTED_TREE "testdir51"
}

prepare_expected_output_3()
{
    remove_lines $EXPECTED_TREE ".AVI"
    remove_lines $EXPECTED_TREE ".avi"
    remove_lines $EXPECTED_TREE "testdir52"
}

prepare_expected_output_4()
{
    cp $ORIGINAL_TREE $EXPECTED_TREE
    replace_lines $EXPECTED_TREE "└" "├"
    replace_lines $EXPECTED_TREE "$TEST_DIR" "$OUTPUT_DIR"
    remove_lines $EXPECTED_TREE ".txt"
    remove_lines $EXPECTED_TREE ".exe"
    remove_lines $EXPECTED_TREE ".ini"
    remove_lines $EXPECTED_TREE ".EXE"
    remove_lines $EXPECTED_TREE "no_ext"
    remove_lines $EXPECTED_TREE ".xlextension"
    remove_lines $EXPECTED_TREE ".XLEXTENSION"
    remove_lines $EXPECTED_TREE "testdir51"
}


# Replaces in the tree descripted in the specified file $1 all ocurrences of "└" with "├"
# to make it easier the tests validations
normalize_tree()
{
    TREE_FILE=$1
    replace_lines $TREE_FILE "└" "├"
}

# Generates a tree file $2 from specified directory $1
generate_tree()
{
    INPUT_DIR=$1
    TREE_FILE=$2
    tree $INPUT_DIR --dirsfirst --noreport > $TREE_FILE && normalize_tree $TREE_FILE
}

reset_test_dir()
{
    rm -rf $OUTPUT_DIR
    rm -rf $TEST_DIR
    $SCRIPT_DIR/prepare_test_dir.sh
    rm -rf $TMP_DIR
    mkdir -p $TMP_DIR
    tree $TEST_DIR --dirsfirst --noreport > $ORIGINAL_TREE
    cp $ORIGINAL_TREE $EXPECTED_TREE
    normalize_tree $EXPECTED_TREE
}

print_test_title()
{
    echo -n "*** Running Test "$1": "
}

print_ok()
{
    echo "$(tput setaf 2)OK$(tput sgr 0)"
}

print_failed()
{
    echo "$(tput setaf 1)FAILED!$(tput sgr 0)"
}

exit_test()
{
    print_failed
    exit 1
}

compare_output_vs_expected()
{
    diff $OUTPUT_TREE $EXPECTED_TREE >> /dev/null 2>&1 || exit_test
}

run_test_1()
{
    # In $TEST_DIR, rename all extensions to lowercase, keep only english chars and replace all whitespaces with _
    print_test_title "1"
    reset_test_dir
    $SCRIPT_DIR/dir_manager.sh -l -k -s _ $OUTPUT_DIR $TEST_DIR
    prepare_expected_output_1
    generate_tree $TEST_DIR $OUTPUT_TREE
    compare_output_vs_expected
    print_ok
}

run_test_2()
{
    # In $TEST_DIR removes all .exe (case insensitive) files
    print_test_title "2"
    reset_test_dir
    $SCRIPT_DIR/dir_manager.sh -r exe $OUTPUT_DIR $TEST_DIR
    prepare_expected_output_2
    generate_tree $TEST_DIR $OUTPUT_TREE
    compare_output_vs_expected
    print_ok
}

run_test_3()
{
    # In $TEST_DIR, move all .avi (case insensitive) files to $OUTPUT_DIR
    print_test_title "3"
    reset_test_dir

    $SCRIPT_DIR/dir_manager.sh -m avi $OUTPUT_DIR $TEST_DIR

    prepare_expected_output_3
    generate_tree $TEST_DIR $OUTPUT_TREE
    compare_output_vs_expected

    prepare_expected_output_4
    generate_tree $OUTPUT_DIR $OUTPUT_TREE
    compare_output_vs_expected
    print_ok
}

run_test_4()
{
    # In $TEST_DIR, rename all extensions to lowercase, keep only english chars, replace all whitespaces with _,
    # removes all .exe (case insensitive) files, move all .avi (case insensitive) files to $OUTPUT_DIR
    print_test_title "4"
    reset_test_dir

    $SCRIPT_DIR/dir_manager.sh -l -k -s _ -r exe -m avi $OUTPUT_DIR $TEST_DIR

    prepare_expected_output_1
    prepare_expected_output_2
    prepare_expected_output_3
    remove_lines $EXPECTED_TREE "testdir5"
    generate_tree $TEST_DIR $OUTPUT_TREE
    compare_output_vs_expected

    prepare_expected_output_4
    prepare_expected_output_1
    generate_tree $OUTPUT_DIR $OUTPUT_TREE
    compare_output_vs_expected
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