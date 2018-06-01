//
// Created by jakutenshi on 5/31/18.
//

#ifndef BENCHMARK_GRIPPER_BENCHMARK_H
#define BENCHMARK_GRIPPER_BENCHMARK_H

#include <stdint-gcc.h>
#include <string>
#include <chrono>

#define BENCHMARKS_ITERATIONS_COUNT 10000
#define BENCHMARKS_SKIP_FIRST_COUNT 80

#define BENCHMARK_INIT() BenchmarkKeeper bm_keeper; Benchmark bm; \
std::cout << "===== BENCHMARK driver enabled with iterations count " << std::to_string(BENCHMARKS_ITERATIONS_COUNT); \
std::cout << " and " << std::to_string(BENCHMARKS_SKIP_FIRST_COUNT) << " will skipped =====\n"; \

#define BENCHMARK_REPETITIONS_START(count) \
std::cout << "=====" << std::to_string(count) << " repetitions starts =====\n"; \
for (int bm_repetition_index = 0; bm_repetition_index < count; bm_repetition_index++) {


#define BENCHMARK_REPETITIONS_END() \
} \
std::cout << "===== repetitions ends =====\n"; \

#define BENCHMARK_START_CUSTOM_NAME()                   \
for (int bm_iteration_index = 0; bm_iteration_index < BENCHMARKS_ITERATIONS_COUNT + BENCHMARKS_SKIP_FIRST_COUNT; bm_iteration_index++) { \
    bm.start();

#define BENCHMARK_START(bm_name)                        \
bm.setNewBenchmark(bm_name);                            \
for (int bm_iteration_index = 0; bm_iteration_index < BENCHMARKS_ITERATIONS_COUNT + BENCHMARKS_SKIP_FIRST_COUNT; bm_iteration_index++) { \
    bm.start();

#define BENCHMARK_END(bytes)         \
    bm.stop(bytes);                   \
}                                    \
if (bm.computeResults()) {           \
    bm_keeper.checkoutBenchmark(bm); \
    bm.printResultLine();            \
}


#define BENCHMARK_STD_OUT_JSON() std::cout << bm_keeper.getJSON();

#define BENCHMARK_WRITE_JSON(file_name) bm_keeper.writeJSON(file_name);

class Benchmark {
    struct Test {
        long double duration = 0;
        long double cpu      = 0;
        uint64_t bytes       = 0;
    };
    Test* iterations;

    long double cycles_per_nsec   = 0;
    uint64_t    start_time        = 0;
    uint64_t    start_cycles      = 0;
    int         current_iteration = 0;
    int         skip_iteration    = 0;

    long double result_time       = 0; //mean
    long double result_cpu        = 0; //mean
    long double bytes_per_second  = 0;
    uint64_t    bm_id             = 0;

    std::string name = "";

    static uint64_t getNowNanoseconds() {
        auto now = std::chrono::system_clock::now();
        auto duration = now.time_since_epoch();
        auto nanos = std::chrono::duration_cast<std::chrono::nanoseconds>(duration).count();
        return nanos;
    }

    static uint64_t getCPUCycles() {
        uint32_t a;
        uint32_t d;

        /* For x86_64 we need to merge the result in 2 32 bit registers
           into one clean 64 bit result. */
        __asm__ __volatile__(" rdtsc\n" : "=a" (a), "=d" (d));
        return ((uint64_t) a) | (((uint64_t) d) << 32);
    }

    void calibrateCPUTicks() {
        auto start_t = getNowNanoseconds();
        auto start_c = getCPUCycles();
        for (int i = 0; i < 10000; i++)
            for (int j = 0; j < 10000; j++);
        auto end_c = getCPUCycles();
        auto end_t = getNowNanoseconds();
        cycles_per_nsec = (end_c - start_c) / (end_t - start_t);
    }
public:
    Benchmark() :
        name("NONAME_BM"), bm_id(getNowNanoseconds()) {
        calibrateCPUTicks();
        iterations = new Test[BENCHMARKS_ITERATIONS_COUNT];
    }

    Benchmark(std::string name) :
            name(name), bm_id(getNowNanoseconds()) {
        calibrateCPUTicks();
        iterations = new Test[BENCHMARKS_ITERATIONS_COUNT];
    }

    void start() {
        start_time   = getNowNanoseconds();
        start_cycles = getCPUCycles();
    }

    void stop(uint64_t bytes = 0) {
        if (skip_iteration < BENCHMARKS_SKIP_FIRST_COUNT) {
            skip_iteration++;
            return;
        }
        iterations[current_iteration].duration = getNowNanoseconds() - start_time;
        auto end = getCPUCycles();
        iterations[current_iteration].cpu      = (end    - start_cycles) / cycles_per_nsec;
        iterations[current_iteration].bytes    = bytes;
        current_iteration++;
    }

    bool computeResults() {
        if (current_iteration <= BENCHMARKS_SKIP_FIRST_COUNT ) {
            return false;
        }

        long double mean_time  = iterations[0].duration;
        long double mean_cpu   = iterations[0].cpu;
        long double mean_bytes = iterations[0].bytes;

        double coefficient;
        Test current;
        for (int i = 1;  i < current_iteration; i++) {
            coefficient = ((double) (i - 1)) / i;
            mean_time  *= coefficient;
            mean_cpu   *= coefficient;
            mean_bytes *= coefficient;
            mean_time  += iterations[i].duration / i;
            mean_cpu   += iterations[i].cpu      / i;
            mean_bytes += iterations[i].bytes    / i;
        }

        long double seconds = mean_time * 1e-9;
        if (seconds == 0) {
            bytes_per_second = UINTMAX_MAX;
        } else {
            bytes_per_second = mean_bytes / seconds;
        }
        result_time      = mean_time;
        result_cpu       = mean_cpu;

        delete iterations;

        return true;
    }

    std::string getJSON() {
        std::string result = "";
        result += "    {\n";
        result += "      \"name\": \""             + name                             + "\",\n";
        result += "      \"real_time\": "        + std::to_string(result_time)      + ",\n";
        result += "      \"cpu_time\": "         + std::to_string(result_cpu)       + ",\n";
        result += "      \"bytes_per_second\": " + std::to_string(bytes_per_second) + ",\n";
        result += "      \"bm_id\": "            + std::to_string(bm_id)            + "\n";
        result += "    }";
        return result;
    }

    long double getResultTime() const {
        return result_time;
    }

    long double getResultCPU() const {
        return result_cpu;
    }

    long double getBytesPerSecond() const {
        return bytes_per_second;
    }

    uint64_t getBM_ID() const {
        return bm_id;
    }

    const std::string &getName() const {
        return name;
    }

    void setNewBenchmark(const std::string n) {
        iterations = new Test[BENCHMARKS_ITERATIONS_COUNT];
        name = n;
        bm_id = getNowNanoseconds();
        current_iteration = 0;
        skip_iteration = 0;
    }

    void printResultLine() {
        std::cout << "\"" << name << "\" ";
        std::cout << "\tTime="  << std::to_string(result_time);
        std::cout << "\tCPU="   << std::to_string(result_cpu);
        std::cout << "\tb/sec=" << std::to_string(bytes_per_second);
        std::cout << "\tCOMPLETE\n";
    }

};


#endif //BENCHMARK_GRIPPER_BENCHMARK_H
