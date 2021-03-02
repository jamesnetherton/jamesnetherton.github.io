---
layout:     post
title: "Camel Quarkus Configuration Options"
summary: "A short overview of some different Camel Quarkus Application configuration options"
tags: [Camel, Quarkus]
---

Having reread my old [blog post](/2020/08/12/camel-quarkus-1.0.0-released/) about the Camel Quarkus 1.0.0 release from last year, I realised that in the code examples I casually mentioned things like 'bootstrap' and 'Camel Main', but never covered those terms in any detail.

Here follows a brief overview of how Camel Quarkus applications are bootstrapped and some different ways in which a Camel Quarkus application can written.

# Bootstrap

Similar to Camel on Spring Boot, Camel Quarkus automatically creates a `CamelContext`, discovers any `RouteBuilder` implementations and loads any XML based `CamelContext` definitions. The major difference in Camel Quarkus, is that there's a lot of work happening at _build time_, instead of in a traditional application where most things happen at _run time_.

There are some obvious [benefits](https://quarkus.io/guides/writing-extensions#favor-build-time-work-over-runtime-work) to doing 'heavy duty' configuration work at build time, rather than runtime. Many of the Camel Quarkus component extensions do work at build time to configure some aspect of the application. Such as configuring components, adding beans to the Camel registry and other tasks that help to make the user experience and performance better.

Once the build time configuration steps are completed, a lightweight Camel runtime is assembled as is executed as part of the 'Runtime Init' [Quarkus bootstrap phase](https://quarkus.io/guides/writing-extensions#bootstrap-three-phases).

# Application configuration

There are a few ways to build and configure Camel Quarkus applications. I won't delve into the specifics of how configuration properties work, as [Alexandre Gallice](https://twitter.com/AlexGallice) covered this recently in his blog post, [Camel Quarkus Configuration Tips](https://camel.apache.org/blog/2021/01/camel-quarkus-configuration-tips/).

Instead, I'll focus on the choices available for wiring together a Camel Quarkus application and how they differ with regards to configuration options.

## Configuration with Camel Quarkus Main

[Camel Quarkus Main](https://camel.apache.org/camel-quarkus/latest/reference/extensions/main.html) leverages [Camel Main](https://camel.apache.org/components/latest/others/main.html) to provide a range of auto configuration capabilities and other useful facilities.

### Component configuration options

With Camel Main, you can configure component and endpoint properties like this.

{% highlight properties %}
camel.component.aws-s3.access-key=some-access-key
camel.component.aws-s3.secret-key=some-secret-key
camel.component.aws-s3.region=ap-east-1
{% endhighlight %}

Each Camel Quarkus component extension documentation page lists and links to all of the supported configuration options. 

### Autowiring

Camel Main has a feature where it can automatically discover beans that are in the Camel registry and wire them into the corresponding types on any component or endpoint properties.

For example, the log component has the option for providing a custom `ExchangeFormatter`. To do that, we define a CDI bean [producer method](https://quarkus.io/guides/cdi-reference#simplified-producer-method-declaration) as follows.

{% highlight java %}
@ApplicationScoped
public ExchangeFormatter exchangeFormatter() {
    return new ExchangeFormatter() {
        @Override
        public String format(Exchange exchange) {
            return "Custom formatter: " + exchange.toString();
        }
    };
}
{% endhighlight %}

With this code in place, the following is reported during application startup indicating Camel Main autowired the `ExchangeFormatter` into the component:

{% highlight log %}
Autowired property: exchangeFormatter on component: log
{% endhighlight %}

### Custom main class

With Camel Main, it is possible to take advantage of Quarkus command line style applications and write a custom main method where you can choose when the Camel runtime is started. You can also leverage Quarkus command line support. [Peter Palaga](https://twitter.com/ppalaga) previously covered this in a [Blog Post](https://camel.apache.org/blog/2020/07/command-line-utility-with-camel-quarkus/).

### Configuration without Camel Main

Without Camel Main, you can leverage [CDI](https://quarkus.io/guides/cdi-reference) to do any required custom configuration. For example, to configure a component.

{% highlight java %}
@ApplicationScoped
@Named("direct")
public DirectComponent directComponent() {
    DirectComponent component = new DirectComponent();
    component.setBlock(false);
    return component;
}
{% endhighlight %}

Note the use of `@Named` is quite important in this instance. It determines the URI scheme that is used to reference the component in a route. If we had used `@Named("foo")`, then our route would look like `from("foo:start")`.

Something else to note is that manually creating components in this way replaces and overrides any pre-configuration and optimisation that was done at build time by the related component extension. For example, the Vert.x component extension sets up the component at build time like this.

{% highlight java %}
VertxComponent component = new VertxComponent();
component.setVertx(quarkusVertx);
{% endhighlight %}

If you were to configure the component manually with CDI, the work done at build time would effectively be ignored.

You can preserve the pre-configuration via an observer method to catch when the component is added to the `CamelContext` like this.

{% highlight java %}
public void onComponentAdd(@Observes ComponentAddEvent event) {
    if (event.getComponent() instanceof VertxComponent) {
        VertxComponent component = (VertxComponent) event.getComponent();
        // Do something useful with VertxComponent...
    }
}
{% endhighlight %}

#### A note on 'unused' beans

A potential pitfall when configuring CDI beans for Camel to use, is that Quarkus will attempt to remove what it deems to be 'unused' beans. There's more information about this in the [Quarkus documentation](https://quarkus.io/guides/cdi-reference#remove_unused_beans).

Consider the following example for the Camel JMS component. Camel can auto discover a `ConnectionFactory` from the registry, so we attempt to take advantage of this by doing the following.

{% highlight java %}
@ApplicationScoped
public ConnectionFactory connectionFactory() {
    ConnectionFactory factory = new SomeVendorConnectionFactory();
    // Configure the ConnectionFactory...
    return factory;
}
{% endhighlight %}

Since the ConnectionFactory bean is neither `@Name`d or `@Inject`ed anywhere in application, Quarkus considers it a candidate for removal. When Camel attempts to look up the bean in the registry, it wont find anything.

The solution is to annotate the producer method with `@Unremovable` or `@Named`. Or you can disable bean removal entirely.

### Configuration with XML

It's possible to create routes using [XML](https://camel.apache.org/camel-quarkus/latest/user-guide/bootstrap.html#_xml_configuration) like this. If you need to reference beans or processors, then you can use CDI to create them and refer to their name in the route XML.

{% highlight java %}
@ApplicationScoped
@Named("greetingProcessor")
public Processor customProcessor() {
    return exchange -> exchange.getMessage().setBody("Hello World!");
}
{% endhighlight %}


{% highlight xml %}
<routes xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns="http://camel.apache.org/schema/spring"
        xsi:schemaLocation="
            http://camel.apache.org/schema/spring
            http://camel.apache.org/schema/spring/camel-spring.xsd">

    <route id="greeting-route">
        <from uri="timer:greet?period=5s"/>
        <process ref="greetingProcessor"/>
        <log message="${body}"/>
    </route>
</routes>
{% endhighlight %}

### Spring

There's also some limited support for Spring provided via the Quarkus Spring extensions. Note this is not a full replacement for camel-spring or camel-spring-boot. But it provides the capability to write a Camel application using Spring, within the confines of what Quarkus [supports](https://quarkus.io/guides/spring-di). E.g there is no Spring XML support in Quarkus, so Camel Spring XML context definitions cannot be used.

{% highlight java %}
@Component
public class Routes extends RouteBuilder {

@Autowired
GreetingService service;

@Override
public void configure() throws Exception {
    from("timer:greet?period=5s")
            .setBody(exchange -> service.greet())
            .to("log:example?showExchangePattern=false&showBodyType=false");
    }
}
{% endhighlight %}

### Kotlin

If kotlin is your thing then routes can be defined and configured with [Quarkus Kotlin](https://quarkus.io/guides/kotlin). 

{% highlight java %}
@ApplicationScoped
class Routes {
    @Produces
    fun configure() = routes {
        from("timer:greet?period=5s")
                .process { e: Exchange -> e.message.body = "Hello World!" }
                .log("\${body}")
    }
}
{% endhighlight %}

# Conclusion

Hopefully that short excursion into the world of Camel Quarkus application bootstrapping and configuration was useful in explaining the different choices available to build applications.

If you have ideas or feedback for Camel Quarkus, feel free to open an [issue](https://github.com/apache/camel-quarkus/issues) on GitHub. There's also the [mailing list](https://camel.apache.org/manual/latest/mailing-lists.html) and [Zulip chat room](https://camel.zulipchat.com/).

Happy Camel quarking!
