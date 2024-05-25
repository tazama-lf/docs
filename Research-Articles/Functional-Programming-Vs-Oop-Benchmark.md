# Functional Programming vs OOP Benchmark

Currently, we have implemented a Functional programming approach to designing our services, typologies and rules. I have raised the concern that there are numerous re-usable data structures, services, and functions that should be placed in a common library to ensure consistency and reusability.  
  
I am proposing a hybrid approach where we have classes, interfaces, and enums to define data structures. In addition, I am proposing a service-driven approach to building and containing functions that relate to one another. In essence, behaving like conventional functional programming but contained within a service object. This will ensure that we keep the applications stateless but having them nicely organized. The classes, interfaces, and enums are merely to dictate structure and readability.

Most of the team has agreed with this approach pending a bentch mark on the memory footprint and average request. For these tests, I have used the Predicate Builder Service which already supports the hybrid approach, and adapted it to run as purely functional with no classes and objects being used. I have removed the Kafka integrations from both of the services as the overhead would remain unchanged for either. The two tests were run. The first on a locally running node server (not in k8s) and then deployed as an OpenFaas function. The load tests were ran using JMeter using 10 threads with 1x10^n requests being sent. N is defined by the test run.

Before every individual test, the server/pods were terminated and restarted to ensure that the values are not influenced by previous runs.

> :exclamation: Please note a few acronyms and keywords used in the table below
> **LT:** Load Test  
> **MF:** Memory Footprint in megabytes (MB)  
> **Idle:** 30 seconds after either startup or after load test, when the garbage collector has already run  
> **Idle\*:** 30 seconds was not enough time for the garbage collector to finish so additional 30 seconds was provided for cleanup  
> **Avg. Request Time:** The average time the requests took to resolve their results in milliseconds (MS)

### Results

**Test Case 1 - Local NodeJs server**

|     | **OOP Hybrid** |     |     |     |     | **Pure Functional Programming** |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **LT Total Requests** | **Startup MF** | **Startup Idle MF** | **LT Finished MF** | **LT Finished Idle MF** | **Avg. Request Time** | **Startup MF** | **Startup Idle MF** | **LT Finished MF** | **LT Finished Idle MF** | **Avg. Request Time** |
| 100 | 82.14 | 77.18 | 79.04 | 78.08 | 1   | 89.48 | 77.15 | 86.6 | 77.32 | 1   |
| 1 000 | 82.3 | 77.19 | 81.12 | 76.86 | 1   | 89.3 | 77  | 95.95 | 77.41 | 1   |
| 10 000 | 82.19 | 77.2 | 104.12 | 76.11 | 3   | 89.46 | 76.99 | 121.98 | 76.01 | 3   |
| 100 000 | 82.39 | 77.19 | 273.14 | 76.07 | 3   | 89.34 | 76.99 | 273.79 | 76.03 | 3   |

**Test Case 2 - OpenFaas Function**

|     | **OOP Hybrid** |     |     |     |     | **Pure Functional Programming** |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **LT Total Requests** | **Startup MF** | **Startup Idle MF** | **LT Finished MF** | **LT Finished Idle MF** | **Avg. Request Time** | **Startup MF** | **Startup Idle MF** | **LT Finished MF** | **LT Finished Idle* MF** | **Avg. Request Time** |
| 100 | 4.82 | 5.2 | 4.99 | 5.36 | 7   | 4.53 | 4.59 | 5.58 | 5.59 | 7   |
| 1 000 | 4.6 | 4.86 | 6.07 | 5.78 | 7   | 4.54 | 4.59 | 6.53 | 6.27 | 6   |
| 10 000 | 4.57 | 4.89 | 7.82 | 6.81 | 9   | 4.54 | 4.8 | 10.16 | 9   | 9   |
| 100 000 | 4.6 | 4.88 | 13.09 | 6.66 | 9   | 4.56 | 4.68 | 14.66 | 10  | 9   |

## Conclusion

After analyzing the results I have noted that there is little to no overhead added to the request processing times if we chose to go with either and in addition, the change in memory footprint is minimal, and when back to an idle state both have similar memory usage.
