# Adding tests to Jenkins

- [Adding tests to Jenkins](#adding-tests-to-jenkins)
  - [URLs you need](#urls-you-need)
  - [Steps](#steps)
    - [Clone the git repo](#clone-the-git-repo)
    - [Open postman](#open-postman)
    - [Import the postman collections](#import-the-postman-collections)
    - [Exporting postman collection](#exporting-postman-collection)
    - [Save under cloned git repo location](#save-under-cloned-git-repo-location)
    - [Go to Jenkins](#go-to-jenkins)

## URLs you need

Jenkins - [https://frmjenkins.sybrin.com/](https://frmjenkins.sybrin.com/)

The location to the postman files - [https://github.com/frmscoe/postman](https://github.com/frmscoe/postman)

## Steps

### Clone the git repo

Pull the postman collection locally to test the different processors and rules.

![](../../Images/image-20220909-135711.png)

### Open postman

### Import the postman collections

Create requests in postman collection with required tests

![](../../Images/image-20220909-140105.png)

**Before exporting the postman collection make sure that all URLs are using internal routing**

![](../../Images/image-20211019-100656.png)

### Exporting postman collection

![](../../Images/image-20211019-100601.png)

**Use collection v2.1**

![](../../Images/image-20211019-100810.png)

### Save under cloned git repo location

**Create new git branch and commit changes into that branch**

**Create a new pull request**

![](../../Images/image-20211019-101005.png)

### Go to Jenkins

In the dashboard click on testing folder

![](../../Images/image-20211019-101114.png)

click on new item

![](../../Images/image-20211019-101151.png)

fill in name and freestyle project

![](../../Images/image-20211019-101241.png)

scroll down click [ok]

toggle source code [git]

and add git creds

add a branch or use */main

![](../../Images/image-20211019-101618.png)

in

scroll down and in the build environment

toggle provide node & npm bin/ folder

Click on Cache location

click on local to the workspace

![](../../Images/image-20211019-101747.png)

Click add build step

click shell command

add the following command

newman run “yourtest.json“
