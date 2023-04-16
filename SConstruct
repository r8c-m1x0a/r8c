# -*- python -*-

import os

PROGRAM='r8c'

BASE_DIR = Dir('.').srcnode().abspath

commonEnv = Environment(
    ENV={'PATH' : os.environ['PATH']},
    CPPPATH=[f"{BASE_DIR}/src"],
)

env = commonEnv.Clone(
    AS='m32c-elf-as',
    CC='m32c-elf-gcc',
    CXX='m32c-elf-g++',
    CFLAGS='-std=gnu99',
    CXXFLAGS='-std=c++14',
    CPPFLAGS='-Wall -Werror -Wno-unused-variable -fno-exceptions -Os -mcpu=r8c',
    LINK='m32c-elf-gcc',
)
env.VariantDir(f"{BASE_DIR}/build", f"{BASE_DIR}/src", duplicate=0)

testEnv = commonEnv.Clone(
    LIBS=['pthread', 'libgtest', 'gcov'],
    CPPFLAGS='-g3 -coverage',
)
testEnv.VariantDir(f"{BASE_DIR}/build/test", f"{BASE_DIR}/src/test", duplicate=0)

lib = env.Library(
    f"{PROGRAM}.a", [
        f"{BASE_DIR}/build/common/vect.c",
        f"{BASE_DIR}/build/common/init.c",
        f"{BASE_DIR}/build/common/start.s",
    ],
)
testProg = testEnv.Program(
    f"{BASE_DIR}/build/test/{PROGRAM}", [
        f"{BASE_DIR}/build/test/main_test.cpp"
    ]
)

TEST_ONLY = os.getenv('TEST_ONLY')
test = testEnv.Command(
    f"{BASE_DIR}/build/test/{PROGRAM}.log", testProg,
    f"{BASE_DIR}/build/test/{PROGRAM} " + ("" if TEST_ONLY is None else f"--gtest_filter={TEST_ONLY}") + f" | tee {BASE_DIR}/build/test/{PROGRAM}.log"
)
testEnv.AlwaysBuild(test)
Alias("test", f"{BASE_DIR}/build/test/{PROGRAM}.log")

Default(lib)
