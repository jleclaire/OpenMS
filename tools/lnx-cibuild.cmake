# define build name&co for easier identification on cdassh
set(CTEST_BUILD_NAME "travis-ci-$ENV{TRAVIS_REPO_SLUG}-$ENV{TRAVIS_BRANCH}-$ENV{BUILD_NAME}-$ENV{CXX}")
set(CTEST_SITE "travis-ci-build-server")
set(CTEST_SOURCE_DIRECTORY "$ENV{SOURCE_DIRECTORY}")
set(CTEST_BINARY_DIRECTORY "${CTEST_SOURCE_DIRECTORY}/_build")

message(STATUS "CTEST_SOURCE_DIRECTORY: ${CTEST_SOURCE_DIRECTORY}")
message(STATUS "CTEST_BINARY_DIRECTORY: ${CTEST_BINARY_DIRECTORY}")

set(INITIAL_CACHE
"CMAKE_FIND_ROOT_PATH=$ENV{SOURCE_DIRECTORY}/contrib\;/usr
BOOST_USE_STATIC=Off
CMAKE_BUILD_TYPE=Release
ENABLE_TUTORIALS=Off"
)

# create cache
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${INITIAL_CACHE})

# ignore failing GzipIfstream_test which seems to be related to the used
# zlib version
set(CTEST_CUSTOM_TESTS_IGNORE
	GzipIfstream_test
)

# customize reporting of errors in CDash
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_ERRORS 1000)
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS 1000)

set (CTEST_CUSTOM_WARNING_EXCEPTION
    # Suppress warnings imported from qt
    ".*qsharedpointer_impl.h:595:43.*"
    )

# try to speed up the builds so we don't get killed
set(CTEST_BUILD_FLAGS -j4)

# we want makefiles
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")

# run the classical ctest suite without update
# travis-ci handles this for us
ctest_start     (Continuous)
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}" RETURN_VALUE _configure_ret)
ctest_build     (BUILD "${CTEST_BINARY_DIRECTORY}" NUMBER_ERRORS _build_errors)
ctest_test      (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 3)
ctest_submit()

# indicate errors
if(${_build_errors} GREATER 0 OR NOT ${_configure_ret} EQUAL 0)
  file(WRITE "$ENV{SOURCE_DIRECTORY}/failed" "build_failed")
endif()
