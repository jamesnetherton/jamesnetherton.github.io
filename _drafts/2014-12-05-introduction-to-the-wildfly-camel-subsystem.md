---
layout: post
title: "Introduction to the WildFly Camel Subsystem"
excerpt: "Introduction to the WildFly Camel Subsystem"
tags: [WildFly, Camel, Camel subsystem]  
share: true
---

In case you haven't heard yet, the first release of the [Wildfly Camel Subsystem](https://github.com/wildfly-extras/wildfly-camel) has been  [announced](http://camel.465427.n5.nabble.com/Camel-subsystem-on-WildFly-td5759852.html).

This gives you the capability to add Camel routes to your applications from a variety of methods:

* As a Camel Context XML fragment within your WildFly configuration
* As a RouteBuilder implentation within your JEE applications
* As a standard Camel context XML file by writing a META-INF/jboss-camel-context.xml (or any XML file suffixed with camel-context.xml)

So what! I hear you cry. I can already embed Camel into my WildFly applications by adding the required dependencies into my EAR / WAR deployment or by writing my own custom module.

Indeed you can. Although this approach works, it does have some drawbacks:

* Fat WAR / EAR deployments with lots of library dependencies to support Camel and its dependent components
* Hard to maintain a standard version of libraries across all applications
* Classes potentially clash with those already added by the various WildFly subsytems and may not be compatible or approved for use with your app server
* Complicates the management of the JEE container
* Writing custom modules can be a bit of a pain (unless you're using the excellent Maven [config-smartics-jboss-modules](http://www.smartics.de/projects/productivity-a-ware/smartics-jboss-modules) plugin)

The Camel subsystem makes life easier by doing the hard work of modularising Camel and it's dependent components, leaving you free to focus on more interesting things.

Here are some basic examples of how interaction with the subsystem can work.

### Camel routes within WildFly configuration
To define Camel routes within WildFly configuration files, you can define Camel contexts within the Camel subsystem XML configuration.
{% highlight xml %}
<subsystem xmlns="urn:jboss:domain:camel:1.0">
   <camelContext id="system-context-1">
     <![CDATA[
     <route>
       <from uri="file://path/from/input/directory"/>
       <transform>
         <simple>Transformed: #{body}</simple>
       </transform>
       <from uri="file://path/to/output/directory"/>
     </route>
     ]]>
   </camelContext>
</subsystem>
{% endhighlight %}

When the application server starts up, the Camel context will be started and the file endpoint will begin polling for files.

### Camel routes within META-INF/jboss-camel-context.xml
Alternatively you can create a META-INF/jboss-camel-context.xml file and specify your Camel contexts in there. Any file within META-INF matching a suffix of 'camel-context.xml' will be used.

### Camel routes within a RouteBuilder class
Not everyone enjoys working with XML. Some folks prefer to use plain old Java and the Camel Java DSL to configure their Camel contexts. You can accomplish this with the Camel subsystem by writing a RouteBuilder class and using the camel-cdi component.

First I make sure the camel-cdi component dependency is on my classpath. Note that the dependency scope is **provided** since the Camel subsystem will provide this at runtime and therefore there's no need to bundle this with our application.
{% highlight xml %}
<dependency>
    <groupId>org.apache.camel</groupId>
    <artifactId>camel-cdi</artifactId>
    <version>2.14.0</version>
    <scope>provided</scope>
</dependency>
{% endhighlight %}

And here's a simple Camel RouteBuilder class:
{% highlight java %}
@Startup
@ApplicationScoped
@ContextName("my-camel-context")
public class FileTransformingRouteBuilder extends RouteBuilder {

    @Override
    public void configure() throws Exception {
        from("file://path/from/input/directory")
        .transform(simple("Transformed: #{body}"))
        .to("file://path/to/output/directory");
    }
}
{% endhighlight %}

When the application is deployed, the camel context starts up and the file endpoint within our route will begin polling for files.

### Hawtio

The Wildfly Camel Subsystem also includes the [hawtio](http://hawt.io) web console. The Camel plugin lets you browse CamelContexts, routes and endpoints. You can also visualise running routes, route metrics, create endpoints and send messages. If this wasn't enough, additionally you can trace and debug message flows and even do profiling against routes.

### Getting started

#### Documenation

[WildFly Camel GitBook](http://wildflyext.gitbooks.io/wildfly-camel/)

#### GitHub

[Source code on GitHub](https://github.com/wildfly-extras/wildfly-camel). Feedback & contributions are always welcome!

#### IRC channel on Freenode

**#wildfly-camel**

#### WildFly Camel Docker Image

One of the fastest ways to get up and running is with [Docker](http://docker.io) and the [WildFly Camel image](https://registry.hub.docker.com/u/wildflyext/wildfly-camel/). This image comes bundled with WildFly 8.1 and the Camel subsystem already installed.

To start up a container do:

{% highlight bash %}
  docker run -ti -p 8080:8080 --name wildfly-camel wildflyext/wildfly-camel
{% endhighlight %}

To deploy applications you can use the WildFly CLI, the administration web console or create your own Docker image to extend wildflyext/wildfly-camel (E.g using 'FROM' in your Dockerfile).

To access the administration console and hawtio, you'll need to create an admin and application user. You can do this by running the add-user.sh script on a running WildFly container:

{% highlight bash %}
    docker exec -ti wildfly-camel /opt/jboss/wildfly/bin/add-user.sh
{% endhighlight %}

There's more detail on getting started over at the [GitBook site](http://wildflyext.gitbooks.io/wildfly-camel/content/start/README.html).

### Coming soon

Support for additional Camel components and examples of running the Camel subsystem on OpenShift v3.
