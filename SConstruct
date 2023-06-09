# -*- python -*-

import os

NAME='r8c'

skip = os.environ.get('SKIP')
if skip is None:
    skip = []
else:
    skip = skip.split()

commonEnv = Environment(
    ENV={'PATH' : os.environ['PATH']},
    CPPPATH=["src/main"],
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
env.VariantDir("build/main", "src/main", duplicate=0)

testEnv = commonEnv.Clone(
    LIBS=['pthread', 'libgtest', 'gcov'],
    CPPFLAGS='-g3 -coverage',
)
testEnv.VariantDir("build/test", "src/test", duplicate=0)

lib = env.Library(
    f"build/main/{NAME}.a", [
        "build/main/common/vect.c",
        "build/main/common/init.c",
        "build/main/common/start.s",
    ],
)
Alias("compile", lib)

testProg = testEnv.Program(
    f"build/test/{NAME}", [
        Glob("build/test/*.cpp"), Glob("build/test/*.c")
    ]
)

TEST_ONLY = os.getenv('TEST_ONLY')
test = testEnv.Command(
    f"build/test/{NAME}.log", testProg,
    f"build/test/{NAME} " + ("" if TEST_ONLY is None else f"--gtest_filter={TEST_ONLY}") + f" | tee build/test/{NAME}.log"
)

if "test" in skip:
    Alias("test", [])
else:
    Alias("test", [test])

if "docs" in skip:
    Alias("docs", [])
else:
    Alias("docs", docs)

Default(lib)
