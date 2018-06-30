//
// Created by jakutenshi on 6/1/18.
//

#ifndef BENCHMARK_GRIPPER_BENCHMARKKEEPER_H
#define BENCHMARK_GRIPPER_BENCHMARKKEEPER_H


#include <vector>
#include <fstream>
#include "Benchmark.h"

class BenchmarkKeeper {
    std::vector<Benchmark> benchmarks;

public:
    void checkoutBenchmark(const Benchmark b) {
        benchmarks.push_back(b);
    }

    std::string getJSON() {
        std::string result = "{\n  \"benchmarks\": [\n";

        long bm_last_idx = benchmarks.size() - 1;
        for (long i = 0; i <= bm_last_idx; ++i) {
            result += benchmarks[i].getJSON();
            if (i != bm_last_idx) {
                result += ",\n";
            } else {
                result += "\n  ]\n}";
            }
        }

        return result;
    }

    void writeJSON(const std::string file_name) {
        std::ofstream out(file_name);
        out << getJSON();
        out.close();
    }
};


#endif //BENCHMARK_GRIPPER_BENCHMARKKEEPER_H
