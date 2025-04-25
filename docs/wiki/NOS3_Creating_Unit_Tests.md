# Scenario - Unit Test Creation

This scenario was developed to give trainees a walkthough of how to create a unit testing framework for a component within NOS3.

# Learning Goals 

By the end of this scenario you should be able to 
* Create unit tests to check the functionality of NOS3 satellite components and their commands
* Create unit tests for a brand new component or add to an existing test suite
* Reach full coverage for all relevant files within a component

# Prerequisites 
Before running the scenario, ensure the following steps are completed:
* [Getting Started](./Getting_Started.md)
  * [Installation](./Getting_Started.md#installation)
  * [Running](./Getting_Started.md#running)

# File Structure Exploration
With a terminal navigated to the top level of your NOS3 repository:
* `cd /nos3/components/sample/fsw/cfs/unit-test`
* If there is no unit-test directory within the cfs directory of your component, either copy one from sample or generate one with the sample script
* Ensure that the unit-test folder you are working from is within the fsw/cfs/ directory

Once you are in the unit-test folder
* Run the command `ls`
* You should see `CMakeLists.txt  coveragetest/  inc/  stubs/` as the output, if any files are missing, again copy from the sample component or generate with the sample script
* Open the `CMakeLists.txt` file
* Check that the name of the component files being included match the component you are working with, if not change them to match. Then close the file
* Navigate to the `coveragetest/`
* Run the command `ls` again, you should see `coveragetest_sample_app.c  sample_app_coveragetest_common.h` as the two files within this directory
* The `coveragetest_sample_app.c` is the file you will be writing the unit tests in
* `cd ..` out of `coveragetest`
* Run `cd inc` and open the `ut_sample_app.h` ensure here that the name of the files being included matches the component you intend to work on
* Finally `cd ..`, `cd stubs`, and `ls`
* You should see `libuart_stubs.c  sample_device_stubs.c`
* Check both files to make sure the component name matches the one you are working
* `cd ..` and `cd coveragetest/`
* open `coveragetest_sample_app.c`

# Writing Unit Tests




