# Overview of Clinic.js

- [Overview of Clinic.js](#overview-of-clinicjs)
    - [What is Clinic.js](#what-is-clinicjs)
    - [Clinic Doctor](#clinic-doctor)
    - [Clinic Bubbleprof](#clinic-bubbleprof)
    - [Clinic Flame](#clinic-flame)
    - [Using Them in Conjunction](#using-them-in-conjunction)
    - [Installation and Usage Commands](#installation-and-usage-commands)
      - [How to run Doctor, Bubbleprof, and Flame](#how-to-run-doctor-bubbleprof-and-flame)
    - [Potential pitfalls](#potential-pitfalls)

### What is Clinic.js

Clinic.js is a set of profiling and debugging tools specifically designed for Node.js applications. It provides developers with actionable insights into their Node.js applications performance and potential bottlenecks. The main goal is to help optimize applications to be fast and responsive.  
  
Docs: [https://clinicjs.org/documentation/](https://clinicjs.org/documentation/)

### Clinic Doctor

Clinic Doctor helps in diagnosing potential issues in your Node.js application. It offers recommendations after identifying common performance problems, such as event loop delays, CPU bottlenecks, or I/O issues.

**Use Case**: If you notice that your Node.js application occasionally lags or seems unresponsive but you're not sure why, Clinic Doctor can give you high-level recommendations.

**What to Look For**: Look for the generated recommendations and advice on potential bottlenecks or issues detected during the profiling session.  
[*Read more on doctor profiles*](https://clinicjs.org/documentation/doctor/04-reading-a-profile/)

### Clinic Bubbleprof

Clinic Bubbleprof visualizes asynchronous operations and their interactions in your Node.js app. It represents them as "bubbles" that show how async activities are linked and where time is spent.

**Use Case**: If you want to understand how asynchronous operations are affecting your application's performance, especially if you suspect that there's a bottleneck due to callbacks or promises.

**What to Look For**: Look for large bubbles or chains of bubbles which indicate long or cascading async operations. These might be potential areas to optimize for better concurrency or reduced waiting time.  
[*Read more on bubbles*](https://clinicjs.org/documentation/bubbleprof/04-bubbles/)

### Clinic Flame

Clinic Flame provides a flamegraph visualization of your application's performance, highlighting CPU-intensive functions and their call stacks.

**Use Case**: If you suspect that certain functions or operations are consuming excessive CPU resources, you can use Clinic Flame to pinpoint those areas. 

**What to Look For**: Look for tall "flames" in the graph, which represent functions that consume a lot of CPU time. Delve into those areas to see if they can be optimized.  
[*Read more on flamegraphs*](https://clinicjs.org/documentation/flame/04-flamegraphs/)

### Using Them in Conjunction

When optimizing Node.js applications, it's often beneficial to use all the tools in tandem:

1. Start with Clinic Doctor to get a high-level view of potential issues. This will give you general advice on what might be going wrong.
2. Dive into Clinic Bubbleprof if you suspect the issues are due to asynchronous operations. This will help you understand the flow of your async code and where it might be causing performance issues.
3. Employ Clinic Flame if you believe the bottlenecks are due to specific CPU-heavy operations. This will help you drill down to specific functions or operations that are resource intensive.

By using all three tools, you can get a comprehensive understanding of your Node.js application's performance from multiple angles, helping you target and resolve the most critical bottlenecks effectively.

### Installation and Usage Commands

To install the Clinic.js tools globally:

```bash
npm install -g clinic
```

#### How to run Doctor, Bubbleprof, and Flame

**Doctor:**

```bash
clinic doctor -- node app.js
```

**Bubbleprof:**

```bash
clinic bubbleprof -- node app.js
```

**Flame:**

```bash
clinic flame -- node app.js
```

*Note: this will have issues in powershell if running command directly, rather add it as a script in package.json or use cmd, or ensure you use quotes around the ‘--’ double hyphens*

### Potential pitfalls

When profiling an application, it's important to test the application under realistic conditions.

For example.

1. **Little/No Load:** Profiling under almost no load might not show the real bottlenecks or issues. In a real-world scenario, especially with applications that serve multiple users or handle concurrent operations, issues might arise only when the system is under stress or serving multiple requests.
2. **Overloading:** On the other hand, pushing the application beyond its typical operational limits might produce data that's too extreme or not reflective of common use cases. Overloading can show bottlenecks that only appear under extreme conditions and may not be the best areas to optimize for typical use.

**Recommendation:** It's best to profile the application under a realistic load, which closely mirrors the expected usage pattern. Using load testing tools or scripts that simulate actual user behavior can provide a balanced and meaningful profiling session.
