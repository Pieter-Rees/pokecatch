#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to run a test file
run_test_file() {
    local test_file=$1
    echo -e "\n${GREEN}Running tests in $test_file...${NC}"
    echo "================="
    
    # Make the test file executable
    chmod +x "$SCRIPT_DIR/$test_file"
    
    # Run the test file
    if "$SCRIPT_DIR/$test_file"; then
        echo -e "${GREEN}✓ All tests passed in $test_file${NC}"
        return 0
    else
        echo -e "${RED}✗ Some tests failed in $test_file${NC}"
        return 1
    fi
}

# Main test runner
echo -e "${GREEN}Starting all tests...${NC}"
echo "================="

# Change to the tests directory
cd "$SCRIPT_DIR"

# Get all test files
test_files=(test_*.sh)

# Run each test file
failed_tests=0
for test_file in "${test_files[@]}"; do
    if ! run_test_file "$test_file"; then
        failed_tests=$((failed_tests + 1))
    fi
done

# Print summary
echo -e "\n${GREEN}Test Summary:${NC}"
echo "================="
if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}✓ All test files passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ $failed_tests test file(s) failed${NC}"
    exit 1
fi 