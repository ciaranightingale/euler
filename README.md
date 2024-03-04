## Euler Finance $197 Hack Analysis - Proof of Concept

This repository serves as a PoC demonstrating the steps taken to perform the hack which lost Euler Finance ~$197M.

This PoC is supplementary to the following article that gives a breakdown of the hack, the vulnerabilities which allowed the hack to occur and how to avoid similar hacks: [Euler Finance Hack Analysis](https://www.cyfrin.io/blog/how-did-the-euler-finance-hack-happen-hack-analysis)

## Documentation

https://book.getfoundry.sh/

## Usage

To use this proof of concept, first clone the repository.

```shell
$ git clone https://github.com/ciaranightingale/euler.git
```

Then, install the dependencies:

```shell
$ forge install
```

### Build

```shell
$ forge build
```

### Test (with state variable output)

```shell
$ forge test -vvv
```
