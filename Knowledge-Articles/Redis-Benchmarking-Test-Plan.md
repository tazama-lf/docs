<!-- SPDX-License-Identifier: Apache-2.0 -->

# Redis Benchmarking Test Plan

- [Redis Benchmarking Test Plan](#redis-benchmarking-test-plan)
  - [Objective](#objective)
  - [Pre-Test Setup](#pre-test-setup)
  - [Vertical Scaling on VMs](#vertical-scaling-on-vms)
    - [Vertical Scaling on 3 VMs](#vertical-scaling-on-3-vms)
      - [Test Case 1: 8 Redis Instances](#test-case-1-8-redis-instances)
      - [Test Case 2: 16 Redis Instances](#test-case-2-16-redis-instances)
      - [Test Case 3: 24 Redis Instances](#test-case-3-24-redis-instances)
      - [Test Case 4: 36 Redis Instances](#test-case-4-36-redis-instances)
      - [Test Case 5: 48 Redis Instances](#test-case-5-48-redis-instances)
      - [Test Case 6: 64 Redis Instances](#test-case-6-64-redis-instances)
      - [Test Case 7: 84 Redis Instances](#test-case-7-84-redis-instances)
    - [Vertical Scaling on 4 VMs](#vertical-scaling-on-4-vms)
      - [Test Case 1: 8 Redis Instances](#test-case-1-8-redis-instances-1)
      - [Test Case 2: 16 Redis Instances](#test-case-2-16-redis-instances-1)
      - [Test Case 3: 24 Redis Instances](#test-case-3-24-redis-instances-1)
      - [Test Case 4: 36 Redis Instances](#test-case-4-36-redis-instances-1)
      - [Test Case 5: 48 Redis Instances](#test-case-5-48-redis-instances-1)
      - [Test Case 6: 64 Redis Instances](#test-case-6-64-redis-instances-1)
      - [Test Case 7: 84 Redis Instances](#test-case-7-84-redis-instances-1)
    - [Vertical Scaling on 5 VMs](#vertical-scaling-on-5-vms)
      - [Test Case 1: 8 Redis Instances](#test-case-1-8-redis-instances-2)
      - [Test Case 2: 16 Redis Instances](#test-case-2-16-redis-instances-2)
      - [Test Case 3: 24 Redis Instances](#test-case-3-24-redis-instances-2)
      - [Test Case 4: 36 Redis Instances](#test-case-4-36-redis-instances-2)
      - [Test Case 5: 48 Redis Instances](#test-case-5-48-redis-instances-2)
      - [Test Case 6: 64 Redis Instances](#test-case-6-64-redis-instances-2)
      - [Test Case 7: 84 Redis Instances](#test-case-7-84-redis-instances-2)
    - [Vertical Scaling on 6 VMs](#vertical-scaling-on-6-vms)
      - [Test Case 1: 8 Redis Instances](#test-case-1-8-redis-instances-3)
      - [Test Case 2: 16 Redis Instances](#test-case-2-16-redis-instances-3)
      - [Test Case 3: 24 Redis Instances](#test-case-3-24-redis-instances-3)
      - [Test Case 4: 36 Redis Instances](#test-case-4-36-redis-instances-3)
      - [Test Case 5: 48 Redis Instances](#test-case-5-48-redis-instances-3)
      - [Test Case 6: 64 Redis Instances](#test-case-6-64-redis-instances-3)
      - [Test Case 7: 84 Redis Instances](#test-case-7-84-redis-instances-3)
  - [Monitoring Network Performance](#monitoring-network-performance)
    - [Network Bandwidth and Latency](#network-bandwidth-and-latency)
  - [Additional Monitoring](#additional-monitoring)
    - [CPU and Memory Utilization](#cpu-and-memory-utilization)
    - [Disk I/O](#disk-io)
    - [Analysis](#analysis)
    - [Reporting](#reporting)
  - [Conclusion](#conclusion)

## Objective

To evaluate the performance impact of vertical scaling on Redis instances across different virtual machine (VM) configurations on Azure Kubernetes Service (AKS).

## Pre-Test Setup

- **Key Size Specification**: **cached and removed once processed (binary)**

  - pacs002 = 314 bytes
  - pacs008 = 833 bytes
  - TP = 1098 bytes  

- **Benchmarking Tool**: Utilize `redis-benchmark` for performance testing.

- **Monitoring Tools**: Implement Azure Monitor and Network Watcher for network performance monitoring.

## Vertical Scaling on VMs

### Vertical Scaling on 3 VMs

Execute the following test cases with an increasing number of Redis instances across three VMs:

#### Test Case 1: 8 Redis Instances

1. **Setup**: Configure 8 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 2: 16 Redis Instances

1. **Setup**: Configure 8 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 3: 24 Redis Instances

1. **Setup**: Configure 24 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 4: 36 Redis Instances

1. **Setup**: Configure 36 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 5: 48 Redis Instances

1. **Setup**: Configure 48 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 6: 64 Redis Instances

1. **Setup**: Configure 64 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 7: 84 Redis Instances

1. **Setup**: Configure 84 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

### Vertical Scaling on 4 VMs

Execute the following test cases with an increasing number of Redis instances across four VMs:

#### Test Case 1: 8 Redis Instances

1. **Setup**: Configure 8 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 2: 16 Redis Instances

1. **Setup**: Configure 8 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 3: 24 Redis Instances

1. **Setup**: Configure 24 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 4: 36 Redis Instances

1. **Setup**: Configure 36 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 5: 48 Redis Instances

1. **Setup**: Configure 48 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 6: 64 Redis Instances

1. **Setup**: Configure 64 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 7: 84 Redis Instances

1. **Setup**: Configure 84 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

### Vertical Scaling on 5 VMs

Execute the following test cases with an increasing number of Redis instances across five VMs:

#### Test Case 1: 8 Redis Instances

1. **Setup**: Configure 8 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 2: 16 Redis Instances

1. **Setup**: Configure 8 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 3: 24 Redis Instances

1. **Setup**: Configure 24 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 4: 36 Redis Instances

1. **Setup**: Configure 36 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 5: 48 Redis Instances

1. **Setup**: Configure 48 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 6: 64 Redis Instances

1. **Setup**: Configure 64 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 7: 84 Redis Instances

1. **Setup**: Configure 84 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

### Vertical Scaling on 6 VMs

Execute the following test cases with an increasing number of Redis instances across six VMs:

#### Test Case 1: 8 Redis Instances

1. **Setup**: Configure 8 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 2: 16 Redis Instances

1. **Setup**: Configure 8 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 3: 24 Redis Instances

1. **Setup**: Configure 24 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 4: 36 Redis Instances

1. **Setup**: Configure 36 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 5: 48 Redis Instances

1. **Setup**: Configure 48 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 6: 64 Redis Instances

1. **Setup**: Configure 64 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

#### Test Case 7: 84 Redis Instances

1. **Setup**: Configure 84 Redis instances with 1 master and 1 replica.

2. **Benchmark Command**:

```bash
#!/bin/bash

# Define an array of data sizes
data_sizes=(314 833 1098)

# Loop through each data size and run the benchmark
for size in "${data_sizes[@]}"; do
    echo "Running benchmark for data size: $size"
    redis-benchmark -h hostname -p 6379 -c 50 -n 100000 -d "$size" > "benchmark_$size.txt" &
done

wait
echo "All benchmarks completed."
```

3. **Recorded Results**:

## Monitoring Network Performance

### Network Bandwidth and Latency

Utilize Azure Network Watcher to observe network performance metrics:

1. **Enable Network Watcher**: See if this exisits

2. **Monitor Metrics**: dashboardresults

## Additional Monitoring
  
### CPU and Memory Utilization 

Leverage Azure Monitor for real-time metrics:

 ```bash
az monitor metrics list --resource [resource_id] --metric "Percentage CPU" --aggregation  [aggregation_type\ ]
az monitor metrics  list --resource [resource_id] --metric "Memory percentage" --aggregation [aggregation_type]```
```

### Disk I/O

Track disk read/write operations using Azure Monitor:

```bash
az monitor metrics list --resource [resource_id] --metric "Disk Read Bytes" --aggregation [aggregation_type]
az monitor metrics list --resource [resource_id] --metric "Disk Write Bytes" --aggregation [aggregation_type]
```

### Analysis

collect my info from monitoring

### Reporting

scaling recommendations

## Conclusion

This test plan aims to systematically assess the performance of a Redis cluster across various scaling scenarios on Azure VMs. By following this plan, you will obtain a clear understanding of the relationship between vertical scaling and Redis performance, helping you to optimize your deployment for high transaction rates.
