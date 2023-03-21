# -*- python -*-

import os

PROGRAM='r8c'

VariantDir('build', ['src'], duplicate=0)

env = Environment(
    ENV = {'PATH' : os.environ['PATH']},
    AS='m32c-elf-as',
    CC='m32c-elf-gcc',
    CXX='m32c-elf-g++',
    CFLAGS='-std=gnu99',
    CXXFLAGS='-std=c++14',
    CPPFLAGS='-Wall -Werror -Wno-unused-variable -fno-exceptions -Os -mcpu=r8c',
    CPPPATH=['src'],
    LINK='m32c-elf-gcc',
    LINKFLAGS=f"-mcpu=r8c -nostartfiles -Wl,-Map,{PROGRAM}.map -T src/M120AN/m120an.ld -lsupc++",
)

testEnv = Environment(
    ENV = {'PATH' : os.environ['PATH']},
    LIBS=['pthread', 'libgtest'],
    CPPFLAGS='-g3',
    CPPPATH=['src'],
)

lib = env.Library(
    f"{PROGRAM}.a", [
        'build/common/vect.c',
        'build/common/init.c',
        'build/common/start.s',
    ],
)
testProg = testEnv.Program(
    f"{PROGRAM}", [
        "build/test/main_test.cpp"
    ]
)

BASE_DIR = Dir('.').srcnode().abspath

TEST_ONLY = os.getenv('TEST_ONLY')
test = testEnv.Command(
    f"{BASE_DIR}/{PROGRAM}.log", testProg,
    f"{BASE_DIR}/{PROGRAM} " + ("" if TEST_ONLY is None else f"--gtest_filter={TEST_ONLY}") + f" | tee {BASE_DIR}/{PROGRAM}.log"
)
testEnv.AlwaysBuild(test)
Alias("test", f"{BASE_DIR}/{PROGRAM}.log")

Default(lib)
