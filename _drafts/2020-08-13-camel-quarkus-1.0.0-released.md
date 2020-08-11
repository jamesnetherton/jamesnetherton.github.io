---
layout:     post
title: "Camel Quarkus 1.0.0 Released"
summary: "A short overview the Camel Quarkus 1.0.0 release"
tags: [Camel, Quarkus]
---

[Apache Camel Quarkus](https://camel.apache.org/camel-quarkus/latest/) 1.0.0 has been [announced](https://camel.apache.org/blog/2020/08/camel-quarkus-release-1.0.0/) as GA.

Since I've been contributing to the project for the past months, I thought it'd be a good time to write a post that explores the rationale behind the project and some its core features.

## Camel Quarkus Project

The Camel Quarkus project aims to bring the awesome integration capabilities of [Apache Camel](https://camel.apache.org) and it's vast component library to the [Quarkus](https://quarkus.io/) runtime.

This enables users to take advantage of the performance benefits, [developer joy](https://quarkus.io/vision/developer-joy) and the [container first ethos](https://quarkus.io/vision/container-first) that Quarkus provides.

Camel Quarkus provides Quarkus [extensions](https://quarkus.io/guides/writing-extensions) for many of the Camel components. Currently XXX components have extensions with more planned in the future.

Camel Quarkus also takes advantage of the many performance improvements made in Camel 3, which results in a lower memory footprint, less reliance on reflection (which is good for native application support) and faster startup times. 

This makes the project perfect for use in the serverless world. [Camel K](https://camel.apache.org/camel-k/latest) will use Camel Quarkus as its default runtime.

## Features

### Fast startup & low RSS memory

Taking advantage of the build time and ahead-of-time compilation (AOT) tricks that Quarkus gives us, much of the Camel application can be pre-configured at build time resulting in fast startup times.

### Application generation

Camel Quarkus is part of the wider Quarkus universe and thus its component extensions are available to select from [code.quarkus.io](https://code.quarkus.io/).

### Native executable support

Quarkus provides the means to [build native executables](https://quarkus.io/guides/building-native-image) with [GraalVM](https://www.graalvm.org/). Camel Quarkus extensions provide all of the necessary plumbing that enable Camel components to work well natively.

### Highly configurable

All of the important aspects of a Camel Quarkus application can be controlled programatically with CDI or via configuration properties.

Check out the [configuration guide](https://camel.apache.org/camel-quarkus/latest/user-guide/bootstrap.html) for more information for the different ways to bootstrap & configure an application.

Some extensions can automagically configure various aspects of Camel for you. For example, the MongoDB extension ensures a Mongo client bean is added to the registry for the Mongo component to use. 

### Observability

Camel Quarkus integrates with many of the existing features provided by Quarkus. Observability is no exception.

There's an example project demonstrating the features mentioned below here:

[https://github.com/apache/camel-quarkus/tree/master/examples/observability](https://github.com/apache/camel-quarkus/tree/master/examples/observability)

#### Health & liveness checks

Health & liveness checks can be configured via the [Camel Health](https://camel.apache.org/manual/latest/health-check.html) API or via [Quarkus MicroProfile Health](https://quarkus.io/guides/microprofile-health).

All configured checks are available on the standard MicroProfile Health endpoint URLs:

[http://localhost:8080/health](http://localhost:8080/health)

[http://localhost:8080/health/live](http://localhost:8080/health/live)

[http://localhost:8080/health/ready](http://localhost:8080/health/ready)

There's an example project which demonstrates health checks:

[https://github.com/apache/camel-quarkus/tree/master/examples/health](https://github.com/apache/camel-quarkus/tree/master/examples/health)

#### Metrics

Camel provides a [MicroProfile Metrics component](https://camel.apache.org/components/latest/microprofile-metrics-component.html) which integrates with [Quarkus MicroProfile Metrics](https://quarkus.io/guides/microprofile-metrics). Some basic Camel metrics are provided for you out of the box and you can supplement these with configuring additional metrics in your routes.

All of the metrics are available on the standard MicroProfile metrics endpoint:

[http://localhost:8080/metrics](http://localhost:8080/metrics)

#### Tracing

Camel Quarkus integrates with the Quarkus [OpenTracing extension](https://quarkus.io/guides/opentracing). All you need to do is set up the required [configuration](https://quarkus.io/guides/opentracing#create-the-configuration) properties and Camel Quarkus will automatically wire up an `OpenTracingTracer` for your application to use. 

## Try Camel Quarkus

Check out the [user guide](https://camel.apache.org/camel-quarkus/latest/user-guide/index.html) for getting started with Camel Quarkus.

There are a set of example projects covering various use cases in the project repository for you to try:

[https://github.com/apache/camel-quarkus/tree/master/examples](https://github.com/apache/camel-quarkus/tree/master/examples)

You can also generate a basic project via [code.quarkus.io](https://code.quarkus.io/). 

## What if there's no extension for my favourite Camel component?

Fear not! Most Camel components if added manually to your project should run without any issues in JVM mode. However, some components may not work out of the box in native mode. In this case, feel free to raise an [issue](https://github.com/apache/camel-quarkus/issues) requesting an extension for the camel component.

If you're feeling brave, why not take a stab at creating the extension and provide a [pull request](https://github.com/apache/camel-quarkus/pulls). The Camel Quarkus contributors guide outlines the process for [creating extensions](https://camel.apache.org/camel-quarkus/latest/contributor-guide/create-new-extension.html).

## Conclusion

Hopefully that was a nice overview of what Camel Quarkus has to offer. More component extensions & features will be added in future releases.

If you'd like to contribute, check out the source code:

[https://github.com/apache/camel-quarkus](https://github.com/apache/camel-quarkus)

The Camel Quarkus team is on Gitter for chat:

[https://gitter.im/apache/camel-quarkus](https://gitter.im/apache/camel-quarkus)

We also lurk in the Quarkus Zulip room:

[https://quarkusio.zulipchat.com](https://quarkusio.zulipchat.com)

Or there are the mailing lists:

[https://camel.apache.org/manual/latest/mailing-lists.html](https://camel.apache.org/manual/latest/mailing-lists.html)

Happy coding!
