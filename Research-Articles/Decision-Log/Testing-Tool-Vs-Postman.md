<!-- SPDX-License-Identifier: Apache-2.0 -->

# testing tool vs postman

|     | Option 1: postman | Option 2: Testing tool |
| --- | --- | --- |
| Description | postman uses a script `pm` | Custom written Nest js app similar to the mojaloop testing toolkit |
| Pros and cons | **Dashboard** \- Has a nice dashboard<br><br>![plus](../../images/plus_32.png) **Integration** - Jenkins integration<br><br>![plus](../../images/plus_32.png) **Testing Methode** - Uses pm scripts to do tests<br><br>![plus](../../images/plus_32.png) Cant receive json<br><br>![(minus)](../../images/minus_32.png) Cant use grpc calls<br><br>![plus](../../images/plus_32.png) Request timeouts<br><br>![plus](../../images/plus_32.png) saving of local variables to be passed in to next request/test<br><br>![plus](../../images/plus_32.png) can check status codes received from api<br><br>![plus](../../images/plus_32.png) check responce time | **Dasboard** - Uses jenkins blue ocean as dash board<br><br>![plus](../../images/plus_32.png) **Configuration -** Easy to configure<br><br>![plus](../../images/plus_32.png) **Configuration -** Accepts dynamic json data  <br>![plus](../../images/plus_32.png) **Execution TIme -** Runs faster (1-2minutes)<br><br>![plus](../../images/plus_32.png) can do grpc calls<br><br>![(minus)](../../images/minus_32.png) If any changes are needed code needs to be written |
| Estimated cost | free | free |

## what can we do with this information

we currently have a testing tool that works and can do the basis of all our testing we need

but it will need a lot of modification to be able to do testing that is coming up as it was mainly build to test GRPC

that will take a lot of work to do as to where we can shift over to using postman collections to do all of the testings we need

as a QA I am suggesting we use postman to do our tests and if we can’t test a scenario using postman we can do it using the testing tool eg. with GRPC or if we need a test to do something that postman just cant do
