#using alpine cause its light
FROM alpine:latest

RUN apk add --no-cache \
        g++ \
        make \
        cmake \
        bash \
        coreutils \
        gtest \
        gtest-dev

RUN adduser -D -u 1000 runner

WORKDIR /workspace

USER runner