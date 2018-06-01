cmake_minimum_required(VERSION 3.10)
project(benchmark_gripper)

set(CMAKE_CXX_STANDARD 11)

add_executable(benchmark_gripper main.cpp Benchmark.h BenchmarkKeeper.h)
