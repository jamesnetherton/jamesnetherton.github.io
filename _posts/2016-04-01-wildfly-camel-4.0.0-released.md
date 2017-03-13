---
layout:     post
title: "WildFly Camel 4.0.0 released"
summary: "An overview of improved CXF support in WildFly Camel 4.0.0"
tags: [WildFly, Camel]
---

[WildFly Camel](https://github.com/wildfly-extras/wildfly-camel) [4.4.0](https://github.com/wildfly-extras/wildfly-camel/releases/tag/4.0.0) has been relased. This release is quite small compared to previous ones, but it does contain an interesting enhancement that is worthy of further explanation.

### The state of WildFly Camel and Camel CXF

Thus far, the WildFly Camel subsystem has been compromised on its Camel CXF integration. Previously, there has been no support for
CXF-RS or CXF-WS consumers. Instead, the suggested workaround was to use the Camel Proxy idiom.

The reason for this, is that ideally we want the Camel CXF component to integrate with the WildFly Undertow HTTP engine, instead of starting its own HTTP engine. This
problem has been solved in the 4.0.0 release and thus Camel CXF integration is now greatly improved.

Camel CXF can now leverage the WildFly Undertow HTTP engine, together with its security and graceful showdown capabilities. Also, the Camel subsystem can utilise the
existing WildFly CXF modules that are used in the WildFly webservice JAX-WS subsystem.

### Example

#### Camel CXF-WS consumer

To demonstrate the CXF-WS consumer, I'll be using Spring to specify the Camel route configuration.

{% highlight xml %}
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:cxf="http://camel.apache.org/schema/cxf"
       xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://camel.apache.org/schema/cxf http://camel.apache.org/schema/cxf/camel-cxf.xsd
        http://camel.apache.org/schema/spring http://camel.apache.org/schema/spring/camel-spring.xsd">

    <cxf:cxfEndpoint id="cxfConsumer"
                     address="http://localhost:8080/webservices/greeting"
                     serviceClass="org.wildfly.camel.examples.cxf.jaxws.GreetingService" />

    <bean id="greetingsProcessor" class="org.wildfly.camel.examples.cxf.jaxws.GreetingsProcessor" />

    <camelContext id="cxfws-camel-context" xmlns="http://camel.apache.org/schema/spring">
        <route>
            <from uri="cxf:bean:cxfConsumer" />
            <process ref="greetingsProcessor" />
        </route>
    </camelContext>

</beans>
{% endhighlight %}

When the application is deployed, it will expose a JAX-WS endpoint at [http://localhost:8080/webservices/greeting](http://localhost:8080/webservices/greeting). You
can verify that the expoint is available by viewing the endpoint WSDL. Open the following URL in a web browser:

[http://localhost:8080/webservices/greeting?wsdl](http://localhost:8080/webservices/greeting?wsdl)

The GreetingService interface looks like:

{% highlight java %}
@WebService(name = "greeting")
public interface GreetingService {
    @WebMethod(operationName = "greet", action = "urn:greet")
    String greet(@WebParam(name = "message") String message, @WebParam(name = "name") String name);
}
{% endhighlight %}

Finally a simple processor handles the WebParm inputs passed to the web service invocation:

{% highlight java %}
public class GreetingsProcessor implements Processor {
    @Override
    public void process(Exchange exchange) throws Exception {
        Object[] args = exchange.getIn().getBody(Object[].class);
        exchange.getOut().setBody(args[0] + " " + args[1]);
    }
}
{% endhighlight %}


#### Camel CXF-WS producer

The producer configuration is similar to the consumer:

{% highlight xml %}
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:cxf="http://camel.apache.org/schema/cxf"
       xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://camel.apache.org/schema/cxf http://camel.apache.org/schema/cxf/camel-cxf.xsd
        http://camel.apache.org/schema/spring http://camel.apache.org/schema/spring/camel-spring.xsd">

    <cxf:cxfEndpoint id="cxfProducer"
                     address="http://localhost:8080/webservices/greeting"
                     serviceClass="org.wildfly.camel.examples.cxf.jaxws.GreetingService" />

    <camelContext id="cxfws-camel-context" xmlns="http://camel.apache.org/schema/spring">
        <route>
            <from uri="direct:start" />
            <to uri="cxf:bean:cxfProducer" />
        </route>
    </camelContext>

</beans>
{% endhighlight %}

#### Camel CXF-RS consumer

The Spring configuration for a CXF-RS consumer looks like:

{% highlight xml %}
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:cxf="http://camel.apache.org/schema/cxf"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://camel.apache.org/schema/cxf http://camel.apache.org/schema/cxf/camel-cxf.xsd
        http://camel.apache.org/schema/spring http://camel.apache.org/schema/spring/camel-spring.xsd">

    <cxf:rsServer id="cxfConsumer"
                  address="http://localhost:8080/rest"
                  serviceClass="org.wildfly.camel.examples.cxf.jaxrs.GreetingService" />

    <bean id="greetingsProcessor" class="org.wildfly.camel.examples.cxf.jaxrs.GreetingsProcessor" />

    <camelContext id="cxfrs-camel-context" xmlns="http://camel.apache.org/schema/spring">
        <route>
            <from uri="cxfrs:bean:cxfConsumer" />
            <process ref="greetingsProcessor" />
        </route>
    </camelContext>
{% endhighlight %}

The GreetingsProcessor interface looks like:

{% highlight java %}
@Path("/greet")
public interface GreetingService {
    @GET
    @Path("/hello/{name}")
    @Produces(MediaType.APPLICATION_JSON)
    Response greet(@PathParam("name") String name);
}
{% endhighlight %}

Finally the processor class that handles the PathParm variables:

{% highlight java %}
public class GreetingsProcessor implements Processor {
    @Override
    public void process(Exchange exchange) throws Exception {
        String hostAddress = InetAddress.getLocalHost().getHostAddress();
        Object[] args = exchange.getIn().getBody(Object[].class);
        exchange.getOut().setBody("Hello " + args[0] + " from " + hostAddress);
    }
}
{% endhighlight %}

When the application is deployed, you can browse to [http://localhost:8080/rest/greet/hello/James](http://localhost:8080/rest/greet/hello/James) and
you should see a message output as "Hello James".


#### Camel CXF-RS producer

The producer configuration is similar to the consumer:

{% highlight xml %}
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:cxf="http://camel.apache.org/schema/cxf"
       xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://camel.apache.org/schema/cxf http://camel.apache.org/schema/cxf/camel-cxf.xsd
        http://camel.apache.org/schema/spring http://camel.apache.org/schema/spring/camel-spring.xsd">

    <cxf:cxfEndpoint id="cxfProducer"
                     address="http://localhost:8080/webservices/greeting"
                     serviceClass="org.wildfly.camel.examples.cxf.jaxws.GreetingService" />

    <camelContext id="cxfws-camel-context" xmlns="http://camel.apache.org/schema/spring">
        <route>
            <from uri="direct:start" />
            <to uri="cxf:bean:cxfProducer" />
        </route>
    </camelContext>

</beans>
{% endhighlight %}

### Conclusion

This improved CXF integration will make the Camel CXF user experience much nicer on WildFly Camel Subsystem. Almost any example that you find for standalone Camel
CXF should work perfectly well with WildFly Camel. Hopefully you'll agree that this is a great improvement over the CXF integration that was present before.
