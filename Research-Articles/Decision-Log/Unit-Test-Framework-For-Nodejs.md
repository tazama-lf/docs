<!-- SPDX-License-Identifier: Apache-2.0 -->

# Unit Test Framework For NodeJS

Add your comments directly to the page. Include links to any relevant research, data, or feedback.

**UNIT TESTING** is a level of software testing where individual units/ components of the software are tested. The purpose is to validate that each unit of the software performs as designed.

- Find bugs!
- Guard against future bug regressions.
- Document the expected functionality or behaviour of the software.
- Improve the design, quality, and maintainability of software.
- Refactor code with confidence.

|              |                                                                     |
| ------------ | ------------------------------------------------------------------- |
| Status       | DONE                                                                |
| Impact       | HIGH                                                                |
| Driver       | Joey Goksu                                                          |
| Approver     | Johan Foley Aarón Reynoza Jonty Esterhuizen Jaco Bornman Joey Goksu |
| Contributors |                                                                     |
| Informed     | Rob Reeve, Justus Ortlepp                                           |
| Due date     | 23 Feb 2021                                                         |
| Outcome      | Jest                                                                |

## Background

#### Test Tools Types

Test tools can be divided into the following functionalities. Some provide us with only one functionality, and some provide us with a combination.

To achieve the most flexible set functionality, it’s common to use a combination of several tools.

1. **Test launchers** are used to launch your tests in the browser or Node.js with user-config. ([Karma](https://karma-runner.github.io/), [Jasmine](http://jasmine.github.io/), [Jest](https://facebook.github.io/jest/), [TestCafe](https://github.com/DevExpress/testcafe), [Cypress](https://www.cypress.io/), [webdriverio](https://webdriver.io/))
2. **Testing structure** **providers** help you arrange your tests in a readable and scalable way. ([Mocha](https://mochajs.org/), [Jasmine](http://jasmine.github.io/), [Jest](https://facebook.github.io/jest/), [Cucumber](https://github.com/cucumber/cucumber-js), [TestCafe](https://github.com/DevExpress/testcafe), [Cypress](https://www.cypress.io/))
3. **Assertion functions** are used to check if a test returns what you expect it to return and if its’t it throws a clear exception. ([Chai](http://chaijs.com/), [Jasmine](http://jasmine.github.io/), [Jest](https://facebook.github.io/jest/), [Unexpected](http://unexpected.js.org/), [TestCafe](https://github.com/DevExpress/testcafe), [Cypress](https://www.cypress.io/))
4. **Generate and display test progress and summary.** ([Mocha](https://mochajs.org/), [Jasmine](http://jasmine.github.io/), [Jest](https://facebook.github.io/jest/), [Karma](https://karma-runner.github.io/), [TestCafe](https://github.com/DevExpress/testcafe), [Cypress](https://www.cypress.io/))
5. **Mocks, spies, and stubs** to simulate tests scenarios, isolate the tested part of the software from other parts, and attach to processes to see they work as expected. ([Sinon](http://sinonjs.org/), [Jasmine](http://jasmine.github.io/), [enzyme](http://airbnb.io/enzyme/docs/api/), [Jest](https://facebook.github.io/jest/), [testdouble](https://testdouble.com/))
6. **Generate and compare snapshots** to make sure changes to data structures from previous test runs are intended by the user’s code changes. ([Jest](https://facebook.github.io/jest/), [Ava](https://github.com/avajs/ava))
7. **Generate code coverage** reports of how much of your code is covered by tests. ([Istanbul](https://gotwarlost.github.io/istanbul/), [Jest](https://facebook.github.io/jest/), [Blanket](http://blanketjs.org/))
8. **Browser Controllers** simulate user actions for Functional Tests. ([Nightwatch](http://nightwatchjs.org/), [Nightmare](http://www.nightmarejs.org/), [Phantom](http://phantomjs.org/)**,** [Puppeteer](https://github.com/GoogleChrome/puppeteer), [TestCafe](https://github.com/DevExpress/testcafe), [Cypress](https://www.cypress.io/))
9. **Visual Regression** **Tools** are used to compare your site to its previous versions visually by using image comparison techniques.  
    ([Applitools](https://applitools.com/), [Percy](https://percy.io/), [Wraith](http://bbc-news.github.io/wraith/), [WebdriverCSS](https://github.com/webdriverio-boneyard/webdrivercss))

## Options considered

|     | Option 1: **Jest** | Option 2: **Mocha** + ***Chai*** | Option 3: **Jasmine** |
| --- | --- | --- | --- |
| **Description** | [Jest](https://jestjs.io/) is a testing framework developed by Facebook. Originally designed to make UI testing easier for React developers, it’s now a full standalone suite of tools for any type of JavaScript project (including Node.js) and includes features such as a built-in assertion library, code coverage, and mocking. Jest also runs multiple test suites concurrently, which can speed up the overall testing process. The downside of parallel execution is it can make debugging tests more difficult. | [Mocha](https://mochajs.org/) is one of the oldest and most well-known testing frameworks for Node.js. It’s evolved with Node.js and the JavaScript language over the years, such as supporting callbacks, promises, and `async`/`await`. It has also picked up a few tricks inspired by other test runners.<br><br>*Chai is a BDD / TDD assertion library for node and the browser that can be delightfully paired with any javascript testing framework.* | Jasmine is a behaviour-driven development framework for testing JavaScript code. It does not depend on any other JavaScript frameworks. It does not require a DOM. And it has a clean, obvious syntax so that you can easily write tests. It’s built to be easy to set up and use in almost any scenario.  It requires a runner, such as Karma or Chutzpah, in most scenarios, but some distros (like the jasmine-node npm) have one baked in. It’s pretty nice for most scenarios you could want, asynchronous code being the main problem area. |
| Pros and cons | ![plus](../../images/plus_32.png) Open source<br><br>![plus](../../images/plus_32.png) It works with projects using: Babel, TypeScript, Node, React, Angular, Vue and more!<br><br>![plus](../../images/plus_32.png) zero config: Jest aims to work out of the box, config free, on most JavaScript projects.<br><br>![plus](../../images/plus_32.png) snapshots: Make tests which keep track of large objects with ease. Snapshots live either alongside your tests, or embedded inline.<br><br>![plus](../../images/plus_32.png) isolated: Tests are parallelized by running them in their own processes to maximize performance.<br><br>![plus](../../images/plus_32.png) great api: From it to expect - Jest has the entire toolkit in one place. Well documented, well maintained, well good.<br><br>![plus](../../images/plus_32.png) code coverage: Generate code coverage by adding the flag --coverage. No additional setup needed<br><br>![plus](../../images/plus_32.png) Easy Mocking: Jest uses a custom resolver for imports in your tests, making it simple to mock any object outside of your test’s scope. | ![plus](../../images/plus_32.png) Open source<br><br>![plus](../../images/plus_32.png) Clear, Simple API<br><br>![plus](../../images/plus_32.png) Headless running out of the box<br><br>![plus](../../images/plus_32.png) Allows use of any assertion library that will throw exceptions on failure, such as Chai<br><br>![plus](../../images/plus_32.png) Supported by some CI servers<br><br>![plus](../../images/plus_32.png) Has aliases for functions to be more BDD-oriented or TDD-oriented<br><br>![plus](../../images/plus_32.png) Highly extensible<br><br>![plus](../../images/plus_32.png) Asynchronous testing is very simple<br><br>![(minus)](../../images/minus_32.png) Mocha needs to pair with Chai (3rd party)<br><br>![(minus)](../../images/minus_32.png) Tests cannot run in random order.<br><br>![(minus)](../../images/minus_32.png) No auto mocking or snapshot testing | ![plus](../../images/plus_32.png) Open source<br><br>![plus](../../images/plus_32.png) Simple setup for node through jasmine-node<br><br>![plus](../../images/plus_32.png) Headless running out of the box<br><br>![plus](../../images/plus_32.png) Nice fluent syntax for assertions built-in<br><br>![plus](../../images/plus_32.png) Supported by many CI servers<br><br>![plus](../../images/plus_32.png) Descriptive syntax for BDD paradigm(which is a big plus for us)<br><br>![(minus)](../../images/minus_32.png) Asynchronous testing can be a bit of a headache<br><br>![(minus)](../../images/minus_32.png) Expects a specific suffix to all test files (\*spec.js by default) |
| Estimated cost | SMALL | MEDIUM | MEDIUM |

## Implement Scenarios

- Unit test for login service on the action of checking the user has a valid userId.

### *Mocha*

```typescript
import { expect, should } from 'chai';
import loginService from './loginService';

describe('loginService', () => {
    it('should return true if valid user id', () => {
        expect(loginService.isValidUserId('abc123')).to.be.true;
    });
};
```

### *Jest*

```typescript
import loginService from './loginService';

describe('loginService', () => {
    it('should return true if valid user id', () => {
        expect(loginService.isValidUserId('abc123')).toBeTruthy();
    });
};
```

### *Jasmine (Diff Example)*

```typescript
describe(“A suite is just a function”, function() {
var a;
it(“and so is a spec”, function() {
a = true;
expect(a).toBe(true);
  });
});
```

### Helpful Links:

Jest: [https://jestjs.io/en/](https://jestjs.io/en/)

Mocha: [https://mochajs.org/](https://mochajs.org/)

Chai: [https://www.chaijs.com/](https://www.chaijs.com/)

## Action items

- Review all options
- Offer another suggestion if you have
- Agree on an approach (in the meeting)

## Outcome
