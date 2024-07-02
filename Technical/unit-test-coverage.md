<!-- SPDX-License-Identifier: Apache-2.0 -->

# Unit Test Coverage

As per [Unit Test Framework For NodeJS](/Research-Articles/Decision-Log/Unit-Test-Framework-For-Nodejs.md) the decision has been made to make use of Jest for unit tests in our NodeJS applications. The unit tests serve to test every line of code and every decision branch in the code, to ensure that the code is doing what it is supposed to, and to make sure that any changes to the code, leaves the code doing what it was originally intended to do. 

## Coverage

To achieve the stated goal, we have configured Jest across all of the platform code, to have a 95%* coverage of branches, functions, lines, statements:

![Unit test coverage](/images/unit-test-coverage.png)

Here is an explanation of what the different thresholds mean:

1. **branches**: This threshold represents the percentage of branches (conditional statements, like if/else) that have been executed in your code. It checks if your tests have covered different decision paths within your code. For example, if you have an if-else statement, both the true and false branches should be covered for this threshold to pass.

2. **functions**: This threshold is about the percentage of functions in your code that have been executed by your tests. It checks if all functions have been called and tested.

3. **lines**: This threshold measures the percentage of lines of code that have been executed. It checks if every line of your code has been run at least once during your tests.

4. **statements**: Similar to lines, this threshold checks the percentage of statements in your code that have been executed. Statements can be simple lines of code or blocks enclosed by curly braces (e.g., loops or if statements).

If any of these thresholds are not met during testing, Jest will report a failure, causing the unit test not to pass.

### Exceptions - branches

For branch coverage, we've allowed an exception where APM is involved. The APM service and spans are undefined when APM is disabled (which is a configuration option). This means when targeting 95% "branch coverage" you'd have to mock the whole APM library - which is quite an annoying task. So we allow the branch coverage to be dropped to exclude specifically any APM null checks. In the code coverage report (generated when Unit Tests are run), it highlights all the branches not covered. In layman's terms, only APM related lines are allowed to be yellow:

![Unit test exceptions-1](/images/unit-test-exceptions-1.png)
![Unit test exceptions-2](/images/unit-test-exceptions-2.png)

## Good vs Bad unit tests

Not all 95% code coverage unit tests are equal. Sometimes you can get good coverage, without explicitly testing the outcome you are expecting. 

Consider the following scenario: In the TADP, we are expecting a channel to send its result to TADP, upon when the TADP will loop through all typology results, mark any that exceeds its configured threshold as fraudulent, then marking the parent channel for review. 

A bad unit test for this scenario could be to test whether a provided channel can return an outcome. If we do this, along with other tests, we can get up to 100% line, statement and function coverage, but miss the one important line: `channelRes.status = review ? 'Review' : 'None';` . This line is meant to be picked up by branch coverage tests, but since the exception above, it's very simple to miss a single in-line if-statement that flags a channel to be Fraudulent. For example:

![Unit test bad example](/images/unit-test-bad-example.png)

### Bad test

In the above test, there's a couple of bad things:

There's a condition whether the test should even run or not `if (res?.report?.status) {` - this means that the entire test will run, making sure that we get all the coverages, since those lines of code actually ran, but then the test part `expect(result).toBeDefined();` will be skipped. So if someone were to change the code that causes this test to fail, the `if` statement would cause the test not to break, meaning we'll get test coverage, but we've introduced a bug in the code. RIP. 

The expect statement is only testing to see if the result object exists. Meaning, this unit test says check that the code doesn't break. It would be significantly better to test everything you expect the code to do specifically. In this scenario, a good test would check that:

The transaction status is `ALRT` 

The channel status is `Review`

The transaction.review is `true`

The Test relies on previous tests for data to be in the correct format. For example - if a specific test changes the global Mock data, and the following tests relies on it to pass. This will cause issues if the previous test is removed, altered - and prevents debugging a test with the focus command, as they won't pass without the previous test passing.

Even though the above test would achieve the 95% + code coverage, it leaves a small back-door open where an error could sneak in. 

A good test for this scenario, would instead be to check if provided with a fraudulent typology, the channel and subsequently, the transaction is marked for Fraud, instead of as in the case with the "bad unit test", trusting that 95% coverage indicates that some test somewhere will surely test exactly this case. 

### Good test

A good test would test everything that we expect the code to change of the outcome object. In this example, we can see the test catches the actual response that is generated by the TADP, checks for all the flags + objects that the TADP actually populates, and if the response object from the test is null, the test doesn't just carry on and report success, it throws an exception, which will cause the unit test to break, indicating failure. A test like this would stop any bugs where the responses change based on code changes.

![Unit test good example](/images/unit-test-good-example.png)

When changing a global mock value for a specific use case, such as error paths - use single implementation such as 

![Unit test mock implementation once](/images/unit-test-mock-once.png)

instead of: 

![Unit test mock implementation](/images/unit-test-mock-2.png)

so that other tests aren't impacted.
