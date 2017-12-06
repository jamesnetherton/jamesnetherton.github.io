---
layout:     post
title: "Using the Camel Undertow component with the WildFly Camel Subsystem"
summary: "How to use Camel Undertow producers and consumers on WildFly"
tags: [WildFly, Camel]
---

A nice addition to the [WildFly Camel Subsystem](https://github.com/wildfly-extras/wildfly-camel) [3.1.0](https://github.com/wildfly-extras/wildfly-camel/releases/tag/3.1.0) release is the [camel-undertow](http://camel.apache.org/undertow.html) component.

This is useful for WildFly because we can leverage the existing Undertow HTTP engine and enable Camel to
configure HTTP Handlers into it. This gives us the capability to produce and consume HTTP messages.

### Standalone Camel Undertow Vs WildFly Camel Undertow

There are some minor differences between configuring Camel Undertow for standalone Camel Vs WildFly Camel in relation
to consumer endpoints.

Standalone Camel Undertow lets you do:

{% highlight java %}
from("undertow://localhost:7766/foo/bar")
{% endhighlight %}

This configuration starts an embedded Undertow server on localhost bound to port 7766.

For WildFly Camel, this would not be allowed. Since WildFly is already running an Undertow HTTP engine,
it makes sense to resuse this, rather than create a new Undertow instance. This has advantages such as being able to take advantage of WildFly's native security mechanisms, graceful shutdown etc.

Therefore, we are restricted to consuming from
the port that has been configured within the WildFly socket-binding configuration (usually 8080).

### Example

#### Undertow consumer

An Undertow HTTP consumer would look like:

{% highlight java %}
public class UndertowConsumerRouteBuilder extends RouteBuilder {

    @Override
    public void configure() throws Exception {
        from("undertow:http://localhost:8080/hello")
        .transform(simple("Hello ${in.header.name}"))
    }
}
{% endhighlight %}

When the Camel application is deployed, you should see a message output to the console logs like:

{% highlight bash %}
Add Camel endpoint: http://127.0.0.1:8080/hello
{% endhighlight %}

Now you can open a web browser and navigate to [http://127.0.0.1:8080/hello?name=James](http://127.0.0.1:8080/hello?name=James). You should see a response output as 'Hello James'.

#### Undertow producer

The producer acts as an HTTP client to make requests to a specified HTTP endpoint. Here's an example that creates your own IP address lookup service by
outputting the response from [ipinfo.io](https://ipinfo.io/).

{% highlight java %}
public class UndertowProducerRouteBuilder extends RouteBuilder {

    @Override
    public void configure() throws Exception {
        from("undertow:http://localhost:8080/whatsmyip")
        .to("undertow:http://ipinfo.io/ip")
    }
}
{% endhighlight %}

Browse to [http://127.0.0.1:8080/whatsmyip](http://127.0.0.1:8080/whatsmyip) and you should see your IP address.


#### Undertow with the Camel REST DSL

The Undertow component can also be used with the [Camel REST DSL](http://camel.apache.org/rest-dsl.html). It's useful to combine this with the camel-swagger-java
dependency for endpoint documentation.

{% highlight java %}
public class RESTRouteBuilder extends RouteBuilder {

    @Override
    public void configure() throws Exception {
      restConfiguration()
        .component("undertow")
        .contextPath("camel/rest")
        .apiContextPath("/api-doc")
        .host("localhost")
        .port(8080);

      rest("/hello")
        .get("/{name}").description("GET name")
          .to("direct:get")
        .post("/{name}").description("POST name")
          .to("direct:post")
        .put("/{name}").description("PUT name")
          .to("direct:put");
        .delete("/{name}").description("DELETE name")
          .to("direct:delete");

      from("direct:get").transform(simple("GET ${header.name}"));
      from("direct:post").transform(simple("POST ${header.name}"));
      from("direct:put").transform(simple("PUT ${header.name}"));
      from("direct:delete").transform(simple("PUT ${header.name}"));
    }
}
{% endhighlight %}

You can then use a HTTP client such as cURL to send requests using each of the HTTP verbs that the above example can handle:

{% highlight bash %}
  curl -v http://localhost:8080/camel/rest/hello/James
  curl -v -X POST http://localhost:8080/camel/rest/hello/James
  curl -v -X PUT http://localhost:8080/camel/rest/hello/James
  curl -v -X DELETE http://localhost:8080/camel/rest/hello/James
{% endhighlight %}

To see the swagger markup you can browse to [http://localhost:8080/camel/rest/api-doc](http://localhost:8080/camel/rest/api-doc).

### Conclusion

Hopefully this has been a good introduction to the Camel Undertow component on the WildFly Camel Subsystem. Doubtless, it'll continue to evolve and improve.

I'd like to see more Camel components use Undertow as their HTTP engine, as it'd enabled them to better integrate with WildFly. Stay tuned for progress in this area.
