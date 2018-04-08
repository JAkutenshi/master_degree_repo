#include <iostream>     //for using cout
#include <unistd.h>
#include "hayai.hpp"

using namespace std;    //for using cout


BENCHMARK(DeliveryMan, DeliverPackage, 2, 2)
{
   sleep(5);
}
