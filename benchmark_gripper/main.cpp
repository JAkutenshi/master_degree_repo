#include <iostream>
#include <chrono>
#include "BenchmarkKeeper.h"

int fibonacci(int n)
{
    if (n < 3) return 1;
    return fibonacci(n-1) + fibonacci(n-2);
}

int main()
{
    BENCHMARK_INIT()


    for (int j = 10; j <= 20; j += 10) {
        BENCHMARK_REPETITIONS_START(10)
        bm.setNewBenchmark("TEST/" + std::to_string(j));
        BENCHMARK_START_CUSTOM_NAME()
        int result = fibonacci(j);
        BENCHMARK_END(2048)
        BENCHMARK_REPETITIONS_END()
    }

    BENCHMARK_WRITE_JSON("tests.json")

    return 0;
}