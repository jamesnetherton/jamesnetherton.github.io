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

Camel Quarkus provides Quarkus [extensions](https://quarkus.io/guides/writing-extensions) for many of the Camel components. At present around 180 components have extensions with more planned in the future.

Camel Quarkus also takes advantage of the many performance improvements made in Camel 3, which results in a lower memory footprint, less reliance on reflection (which is good for native application support) and faster startup times. 

You can define Camel routes using the Java DSL, XML & Kotlin.

## Features

### Fast startup & low RSS memory

Taking advantage of the build time and ahead-of-time compilation (AOT) tricks that Quarkus gives us, much of the Camel application can be pre-configured at build time resulting in fast startup times.

### Application generator

Camel Quarkus is part of the wider Quarkus universe and thus its component extensions are available to select from [code.quarkus.io](https://code.quarkus.io/).

### Native executable support

Quarkus provides the means to [build native executables](https://quarkus.io/guides/building-native-image) with [GraalVM](https://www.graalvm.org/). Camel Quarkus extensions provide all of the necessary plumbing that enable Camel components to work well natively.

### Highly configurable

All of the important aspects of a Camel Quarkus application can be set up programatically with CDI or via configuration properties. By default, a `CamelContext` is configured and automatically started for you.

Check out the [bootstrap & configuration guide](https://camel.apache.org/camel-quarkus/latest/user-guide/bootstrap.html) for more information on the different ways to bootstrap & configure an application.

Some extensions can automagically configure various aspects of Camel for you (a bit like Spring Boot auto configuration). For example, the MongoDB extension ensures a Mongo client bean is added to the registry for the Mongo component to use. 

### Integrates with existing Quarkus extensions

Quarkus provides extensions for libraries and frameworks that are used by some camel components, so it makes sense to reuse these and inherit the native support and configuration options.

### Observability

#### Health & liveness checks

Health & liveness checks can be configured via the [Camel Health](https://camel.apache.org/manual/latest/health-check.html) API or via [Quarkus MicroProfile Health](https://quarkus.io/guides/microprofile-health).

All configured checks are available on the standard MicroProfile Health endpoint URLs:

[http://localhost:8080/health](http://localhost:8080/health)

[http://localhost:8080/health/live](http://localhost:8080/health/live)

[http://localhost:8080/health/ready](http://localhost:8080/health/ready)

There's an example project which demonstrates health checks:

[https://github.com/apache/camel-quarkus/tree/master/examples/health](https://github.com/apache/camel-quarkus/tree/master/examples/health)

#### Metrics

Camel provides a [MicroProfile Metrics component](https://camel.apache.org/components/latest/microprofile-metrics-component.html) which is used to integrate with [Quarkus MicroProfile Metrics](https://quarkus.io/guides/microprofile-metrics). Some basic Camel metrics are provided for you out of the box, and these can be supplemented by configuring additional metrics in your routes.

Metrics are available on the standard MicroProfile metrics endpoint:

[http://localhost:8080/metrics](http://localhost:8080/metrics)

#### Tracing

Camel Quarkus integrates with the Quarkus [OpenTracing extension](https://quarkus.io/guides/opentracing). All you need to do is set up the required [configuration](https://quarkus.io/guides/opentracing#create-the-configuration) properties and an `OpenTracingTracer` will get automatically added to the registry for Camel to use.

There's an example project demonstrating the above features here:

[https://github.com/apache/camel-quarkus/tree/master/examples/observability](https://github.com/apache/camel-quarkus/tree/master/examples/observability)

## What if there's no extension for my favourite Camel component?

Fear not! Most Camel components if added manually to your project should run without any issues in JVM mode. However, some components may not work out of the box in native mode. In this case, feel free to raise an [issue](https://github.com/apache/camel-quarkus/issues) requesting an extension for the camel component.

If you're feeling brave, why not take a stab at creating the extension and provide a [pull request](https://github.com/apache/camel-quarkus/pulls). The Camel Quarkus contributors guide outlines the process for [creating extensions](https://camel.apache.org/camel-quarkus/latest/contributor-guide/create-new-extension.html).

## Example

Here's a very basic example of quickly bootstrapping a Camel Quarkus application that uses the timer and log component extensions. We'll also use [Camel Main](https://camel.apache.org/camel-quarkus/latest/user-guide/bootstrap.html#_camel_main) as our preferred bootstrap method.

First generate the project skeleton. We'll use Maven, but you could also use [code.quarkus.io](https://code.quarkus.io/).

{% highlight bash %}
mvn io.quarkus:quarkus-maven-plugin:1.7.0.Final:create \
    -DprojectGroupId=org.test \
    -DprojectArtifactId=timer-to-log-test \
    -DprojectVersion=1.0-SNAPSHOT \
    -Dextensions=camel-quarkus-timer,camel-quarkus-log,camel-quarkus-main
{% endhighlight %}

This creates a new project in the directory `timer-to-log-test`. In the generated `pom.xml` you'll see that the requested Camel component extensions have been added:

{% highlight xml %}
<dependency>
    <groupId>org.apache.camel.quarkus</groupId>
    <artifactId>camel-quarkus-log</artifactId>
</dependency>
<dependency>
    <groupId>org.apache.camel.quarkus</groupId>
    <artifactId>camel-quarkus-main</artifactId>
</dependency>
<dependency>
    <groupId>org.apache.camel.quarkus</groupId>
    <artifactId>camel-quarkus-timer</artifactId>
</dependency>
{% endhighlight %}


Next we'll add a simple route that prints a log message generated from a timer endpoint:

{% highlight java %}
public class TimerToLogRoute extends RouteBuilder() {

    @Override
    public void configure() throws Exception {
        from("timer:test?period={% raw %}{{timer.period}}{% endraw %}")
            .setBody().constant("Camel Quarkus Rocks!")
            .to("log:example");
    }
}
{% endhighlight %}


Notice we used a placeholder value for the `period` on the timer endpoint. To demonstrate integration with Quarkus configuration, lets add an option to `src/main/resources/application.properties`. We'll also add some configuration for the log component:

{% highlight properties %}
timer.period=5000

camel.component.log.exchange-formatter = #class:org.apache.camel.support.processor.DefaultExchangeFormatter
camel.component.log.exchange-formatter.show-all = true
{% endhighlight %}


### Development mode

To run the application in development mode do:

{% highlight bash %}
mvn quarkus:dev
{% endhighlight %}


Every 5 seconds you'll see a log message output to the console:

{% highlight bash %}
INFO  [example] (Camel (camel-3) thread #0 - timer://test) Exchange[ExchangePattern: InOnly, BodyType: String, Body: Camel Quarkus Rocks!]
{% endhighlight %}


To demonstrate the hot reload feature of Quarkus, adjust the exchange body like:

{% highlight java %}
.setBody().constant("Camel Quarkus Rocks Again!")
{% endhighlight %}

Save the changes & the application will reload and print the new message.

{% highlight bash %}
INFO  [example] (Camel (camel-3) thread #0 - timer://test) Exchange[ExchangePattern: InOnly, BodyType: String, Body: Camel Quarkus Rocks Again!]
{% endhighlight %}

### Native executable

Before generating a native executable for the application, make sure you have fulfilled the prerequisites outlined in the [Quarkus documentation](https://quarkus.io/guides/building-native-image). Then do:

{% highlight bash %}
mvn package -Dnative
{% endhighlight %}

When the process has finished you can run:

{% highlight bash %}
target/timer-to-log-test-1.0-SNAPSHOT-runner
{% endhighlight %}

### Next steps

We only scratched the surface of what's possible with Camel Quarkus. Some other topics to explore and experiment with are:

* Creating a [container image](https://quarkus.io/guides/building-native-image#creating-a-container) for your application
* Deploying to Kubernetes or OpenShift with the [Quarkus Kubernetes extension](https://quarkus.io/guides/kubernetes)
* Testing with [Quarkus JUnit](https://quarkus.io/guides/getting-started-testing). Also check out the Camel Quarkus [integration tests](https://github.com/apache/camel-quarkus/tree/master/integration-tests).
* Try out some of the Camel Quarkus [example projects](https://github.com/apache/camel-quarkus/tree/master/examples)

## Conclusion

Hopefully that was a nice overview of what Camel Quarkus has to offer. More component extensions & features will be added in future releases.

If you have feedback or you'd like to contribute, check out the contributors guide:

[https://camel.apache.org/camel-quarkus/latest/contributor-guide/index.html](https://camel.apache.org/camel-quarkus/latest/contributor-guide/index.html)

The source code is available on GitHub:

[https://github.com/apache/camel-quarkus](https://github.com/apache/camel-quarkus)

The Camel Quarkus team is on Gitter for chat:

[https://gitter.im/apache/camel-quarkus](https://gitter.im/apache/camel-quarkus)

We also lurk in the Quarkus Zulip room:

[https://quarkusio.zulipchat.com](https://quarkusio.zulipchat.com)

There's also the Camel mailing lists:

[https://camel.apache.org/manual/latest/mailing-lists.html](https://camel.apache.org/manual/latest/mailing-lists.html)

Happy coding!
