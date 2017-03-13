---
layout:     post
title: "Camel on WildFly Swarm"
summary: "Building Camel applications on WildFly Swarm"
tags: [WildFly, Camel, Microservices, WildFly Swarm]
---

Nobody working in software development will have escaped the buzz around [Microservices](https://en.wikipedia.org/wiki/Microservices) in the last 12 - 18 months.
Various frameworks have appeared for Java, one of the most popular being [Spring Boot](https://projects.spring.io/spring-boot/).

Spring Boot takes an approach of enabling developers to pick and choose which components they need for their app via 'starter' dependencies, and then packaging everthing
into a runnable 'fat' JAR (or WAR if need be). This is advantagous for build and deployment via CI / CD pipelines into containerised platforms.

So what tools exist to achieve similar things with JavaEE? Enter [WildFly Swarm](https://github.com/wildfly-swarm/wildfly-swarm/). WildFly Swarm builds on top of the WildFly
container and lets you 'rightsize' your JavaEE apps by giving you the option to pick and choose what components of the app server you want to include. In a classic WildFly JavaEE app server installation you'll have the some (or more) of following subsystems available:

* CDI
* EJB
* JAX-RS
* JAX-WS
* Mail
* Messaging

In a Microservice, you may not need all of these services, so it makes little sense to include them within the packaged application. WildFly Swarm deals with this problem
via [fractions](https://wildfly-swarm.gitbooks.io/wildfly-swarm-users-guide/content/v/8cca257df347646706d7967e93f0588bc75681a9/getting-started/concepts.html). So if I need
Jolokia, I simply include the Jolokia fraction dependency. If I need to use REST via JAX-RS, then I include the Swarm JAX-RS fraction. WildFly broken down into small
discrete functional pieces!

### WildFly Swarm Camel applications

Recently, the [WildFly Camel subsystem](https://github.com/wildfly-extras/wildfly-camel) has been incorporated into WildFly Swarm via its own set of fractions. Thus far
the following fractions are available:

* camel-core
* camel-cdi
* camel-cxf
* camel-ejb
* camel-jms
* camel-jmx
* camel-jpa
* camel-mail
* camel-other
* camel-undertow

camel-other is an unforntuately named 'catch all' bucket for components that are not featured in the above list. Over time the plan is to have individual fractions for each supported Camel component.

### Example Camel WildFly Swarm application

This example demonstrates using the Camel CDI and Undertow compoments on WildFly Swarm.

#### WildFly Swarm generator

Let's start by making life easy for ourselves and auto-generate a basic project structure.
Head over to [http://wildfly-swarm.io/generator/](http://wildfly-swarm.io/generator/) and fill in your group / artifact IDs. Next, select the Camel
fractions that you want to work with - for this demo choose Camel CDI and Camel Undertow. Click the 'Generate Project' button to generate and import the skeleton project
into your IDE.

#### Camel RouteBuilder

Next we add a camel RouteBuilder class:

{% highlight java %}
@ApplicationScoped
@ContextName("cdi-context")
public class CdiRouteBuilder extends RouteBuilder {

    @Override
    public void configure() throws Exception {
        from("undertow:http://localhost/hello")
        .transform(simple("Hello ${in.header.name}"));
    }
}
{% endhighlight %}

#### Package and run

Now package the application:

{% highlight bash %}
mvn clean package
{% endhighlight %}

Check the target directory and you should see a JAR file named with a '-swarm' suffix. This is the runnable 'fat' JAR.

{% highlight bash %}
ls -l target

-rw-rw-r--. 1 james james 104658142 Mar 13 12:05 demo-swarm.jar
-rw-rw-r--. 1 james james      2294 Mar 13 12:05 demo.war
-rw-rw-r--. 1 james james  32025373 Mar 13 12:05 demo.war.original
{% endhighlight %}

Now run the application:

{% highlight bash %}
java -jar target/demo-swarm.jar
{% endhighlight %}

Alternatively, you can use the WildFly Swarm Maven plugin:

{% highlight bash %}
mvn wildfly-swarm:run
{% endhighlight %}

Now you can open a web browser and navigate to [http://127.0.0.1:8080/hello?name=James](http://127.0.0.1:8080/hello?name=James). You should see a response output as 'Hello James'.

### Conclusion

WildFly Swarm makes it easy to develop and run JavaEE Microservice applications. Camel is already well placed to take advantage of Microservice architectures via
its comprehensive component library. This will get better and better over time.

I've only scratched the surface of what WildFly Swarm has to offer in this post. If you want to learn more, then check out the following links:

* [WildFly Swarm Project](http://wildfly-swarm.io/)
* [WildFly Swarm Examples](https://github.com/wildfly-swarm/wildfly-swarm-examples)
* [WildFly Swarm Documentation](http://wildfly-swarm.io/documentation)
* [WildFly Swarm Twitter](http://twitter.com/wildflyswarm)
* [WildFly Swarm Mailing List](http://twitter.com/wildflyswarm)
* [\#wildfly-swarm IRC at Freenode](http://webchat.freenode.net/?channels=wildfly-swarm)
