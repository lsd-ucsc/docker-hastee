# docker-hastee
Modified version of HasTEE to work in docker container

## Instructions
1. Make sure you have Docker installed
2. Clone this repo
3. docker build -t "name" .
4. docker run -it -dp 127.0.0.1:3000:3000 "name"
5. docker attach "gifted_lovelace"
6. docker exec -it gifted_lovelace /bin/bash
