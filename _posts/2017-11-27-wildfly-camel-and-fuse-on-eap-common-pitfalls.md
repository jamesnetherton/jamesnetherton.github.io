---
layout:     post
title: "WildFly Camel and Fuse on EAP - Common Pitfalls"
tags: [WildFly,Camel,JBoss Fuse,EAP]
---

This post aims to address some common pitfalls and points of confusion that I regularly see people encounter when they build and deploy applications with [WildFly Camel](https://github.com/wildfly-extras/wildfly-camel) 
or [JBoss Fuse on EAP](https://access.redhat.com/documentation/en-us/red_hat_jboss_fuse/).

## 1. I need to package Camel dependencies into my WAR

TL;DR Try to avoid doing this. These dependencies are already provided for you by the container.

A more comprehensive answer as to why, is as follows.

First, a quick refresher on WildFly / EAP class loading fundamentals. The container leverages [JBoss Modules](https://github.com/jboss-modules/jboss-modules). Modules can have dependencies on other modules, import specific package paths from other modules and apply restrictions to paths exported (or re-exported) from itself. Modules have their own class loader and the classes that are visible to it are governed by its module XML definition.

The Camel subsystem organizes Camel functionality into individual modules. In fact, there's a module for each supported Camel component. 

When you deploy a 'fat' WAR Camel application into the container, classes from libraries within `WEB-INF/lib` are loaded by the deployment class loader. If your deployment happens to activate the Camel subsystem, it will [automatically](https://github.com/wildfly-extras/wildfly-camel/blob/4.9.0/subsystem/core/src/main/java/org/wildfly/extension/camel/deployment/CamelDependenciesProcessor.java) expose Camel (and many other other) packages to the deployment class loader.

As things turn out, the container does a pretty good job in preventing class loading issues which can result from this scenario. But, there's still no guarantee that your application will function 100% correctly.

In short, you're better off scoping any Camel related dependencies as 'provided'. If for some reason you need access to specific classes within any of the Camel component modules, you can always add module dependencies to your deployment with `jboss-deployment-structure.xml` or via the `Dependencies:` manifest header.

There's more information about that here:

[https://docs.jboss.org/author/display/WFLY10/Class+Loading+in+WildFly](https://docs.jboss.org/author/display/WFLY10/Class+Loading+in+WildFly)

From a support and maintenance perspective, making use of the container provided dependencies is better because you only need to upgrade & patch the container, instead of rebuilding and redeploying all of your Camel applications. 

If for some reason you really must bundle your application dependencies into the WAR, then consider [disabling](http://wildfly-extras.github.io/wildfly-camel/#_configuration) the Camel subsystem for your deployment.

## 2. I need spring-web to bootstrap my Camel Spring application

Nope! 

One of the nice features of the Camel subsystem is that it takes care of bootstrapping Spring for you.

All you need to do is to have appropriately named XML file(s) somewhere within your deployment. More on that here:

[http://wildfly-extras.github.io/wildfly-camel/#_features](http://wildfly-extras.github.io/wildfly-camel/#_features)

`web.xml` or the Spring `ContextLoaderListener` is not mandatory at all.

In fact, you can drop an XML file containing a `<CamelContext>` definition into the container deployments directory and it will attempt to bootstrap your Camel application.

## 3. I can't add extra Camel components

You can!

If you want to work with a component that's not provided by the Camel Subsystem, you can add it yourself by the following methods.

#### 1. Custom component module

You can add to the collection of Camel component modules by following this guide. This is the preferred option.

[http://wildfly-extras.github.io/wildfly-camel/#_adding_components](http://wildfly-extras.github.io/wildfly-camel/#_adding_components)

#### 2. Module dependencies

Another option is to use a combination of module dependencies and libraries within `WEB-INF/lib`. Here's an example application which uses this approach to add the camel-jetty component.

[https://github.com/jamesnetherton/examples/tree/master/wildfly-camel/add-unsupported-component](https://github.com/jamesnetherton/examples/tree/master/wildfly-camel/add-unsupported-component)

If you follow any of the above, ensure the component libraries you add match up with the Camel version provided by the container.

## 4. I need to use CDI or Spring beans to configure everything

You can wire up your own beans for things like JDBC `DataSource`, JMS `ConnectionFactory`, Java Mail `MailSession`, connection pools etc. But this can be quite laborious. 

You can simplify your application by configuring these things as managed container resources and have them injected into your app. Or you can look them up via JNDI.

When using camel-cdi you can use the `@Produces` annotation to help discover container managed resources. For example:

{% highlight java %}
public class DatasourceProducer {
    @Resource(name = "java:jboss/datasources/ExampleDS")
    DataSource dataSource;

    @Produces
    @Named("wildFlyExampleDS")
    public DataSource getDataSource() {
        return dataSource;
    }
}
{% endhighlight %}

Then camel can reference the bean:
{% highlight xml %}
from("sql:select name from information_schema.users?dataSource=wildFlyExampleDS")
{% endhighlight %}
In Spring XML, you can use the `JndiObjectFactoryBean` or the shortened 'jee' namespace:
{% highlight xml %}
<jee:jndi-lookup id="datasource" jndi-name="java:jboss/datasources/ExampleDS"/>

<from uri="sql:select name from information_schema.users?datasource=#datasource>
{% endhighlight %}

## 5. Testing

One common pattern for testing that I see, is to write unit tests in the traditional way with JUnit and maybe some of the helper classes provided by Camel and Spring.

This is all good, but often it leads to tests being executed on a 'flat' class path. Remember from point 1, this is not how the WildFly / EAP runtime works. Within the container we run in a _modular_ class loading environment.

If you run your WildFly / EAP Camel application tests exclusively on a flat class path, they're not really proving that your app will behave properly when deployed into the container.

To help with this, I recommend using [Arquillian](http://arquillian.org/) with the [Arquillian WildFly adapter](http://arquillian.org/modules/wildfly-arquillian-wildfly-managed-container-adapter/). The WildFly Camel project has [many](https://github.com/wildfly-extras/wildfly-camel/tree/master/itests/standalone/basic/src/test/java/org/wildfly/camel/test) integration tests which demonstrate how to test & deploy Camel applications.

## Conclusion

Hopefully this post helps to clarify some misconceptions about the Camel subsystem. Following the above advice should help you avoid some common problems & mistakes.


