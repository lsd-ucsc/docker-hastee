# docker-hastee
Modified version of HasTEE to work in docker container

## Instructions
1. Make sure you have Docker installed
2. Clone this repo
3. docker build -t "name" .
4. docker run -it -dp 127.0.0.1:3000:3000 "name"
5. docker attach "gifted_lovelace"
6. docker exec -it gifted_lovelace /bin/bash

## SGX Specific Instructions
1. Once in the docker terminal navigate to the docker-hastee directory
2. cabal install --project-file=cabal-nosgx.project happy
3. cabal install --project-file=cabal-nosgx.project alex
4. apt-get update
5. apt-get install python3-sphinx
6. cd ..
7. git clone --recursive https://github.com/Abhiroop/ghc-trusted.git
8. cd ghc-trusted
9. git submodule update --init --recursive
10. apt-get install autoconf
11. ./boot
12. ./configure
13. Navigate into the mk directory for ghc-trusted and create a file called build.mk
15. in build.mk add the flags "BUILD_SPHINX_HTML = NO" and "BUILD_SPHINX_PDF = NO" without the quotes on separate lines
14. make
15. refer to https://gitlab.haskell.org/ghc/ghc/-/wikis/building/using

## Building and Running the HasTEE Enclave/Client
- Refer to https://github.com/Abhiroop/HasTEE/tree/master
- Users will have to modify the cabal.project file to include the path to their ghc-trusted binary mentioned above.