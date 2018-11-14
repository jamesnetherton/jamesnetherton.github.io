---
layout:     post
title: "Hawtio with Spring Boot"
summary: "How to embed Hawtio within a Spring Boot application"
tags: [Hawtio, Spring Boot]
---

The recent [Hawtio 2.3.0 release](https://github.com/hawtio/hawtio/releases/tag/hawtio-2.3.0) added support for Spring Boot 2. What follows is a demonstration of how to embed Hawtio into your Spring Boot applications.

## Getting started

Assuming you have an existing Spring Boot application, simply add the `hawtio-springboot` dependency.

{% highlight xml %}
<dependency>
    <groupId>io.hawt</groupId>
    <artifactId>hawtio-springboot</artifactId>
    <version>2.3.0</version>
</dependency>
{% endhighlight %}

Hawtio runs as a Spring Boot management endpoint. Therefore, we need to enable it along with Jolokia in the application configuration.

To keep things simple, we'll also disable Hawtio authentication.

{% highlight properties %}
management.endpoints.web.exposure.include=hawtio,jolokia
hawtio.authenticationEnabled=false
{% endhighlight %}

Or if you prefer YAML.

{% highlight yaml %}
management:
  endpoints:
    web:
      exposure:
        include: "hawtio,jolokia"
hawtio:
    authenticationEnabled: false
{% endhighlight %}

Now run the application.

{% highlight bash %}
mvn spring-boot:run
{% endhighlight %}

Open a browser to [http://localhost:8080/actuator/hawtio](http://localhost:8080/actuator/hawtio) and you should see the Hawtio web console.

### Hawtio Spring Boot Plugin

The Hawtio Spring Boot plugin provides functionality to interact with some of the Spring Boot actuator endpoints via JMX.

#### Health

Displays the current health status of the application together with details returned from any Spring Boot health checks.

![Spring Boot Health](/images/spring-boot-health.png)

#### Loggers

Lists all of the available loggers in the application. You can modify the level of a logger and the changes will take effect immediately.

![Spring Boot Loggers](/images/spring-boot-loggers.png)

#### Trace

Lists any HTTP traces for your application and lets you view information about the request / response such as headers, time taken etc.

![Spring Boot HTTP Traces](/images/spring-boot-trace.png)


### Additional Configuration

There are a few ways to customize Hawtio on Spring Boot.

##### Custom Hawtio Endpoint Path

You can use some of the following properties to customize the Hawtio endpoint path.

{% highlight properties %}
# Sets the context path for the application
server.servlet.context-path=/context-path

# Sets the context path for management endpoints
# Note: Requires a custom management.server.port
management.server.servlet.context-path=/management-context-path

# Sets the actuator base path
management.endpoints.web.base-path=/base-path

# Sets the Hawtio endpoint base path
management.endpoints.web.path-mapping.hawtio=/hawtio/console
{% endhighlight %}

##### Customize Jolokia Access

By placing a [jolokia-access.xml](https://jolokia.org/reference/html/security.html) file in `src/main/resources` you can add restrictions on how hosts interact with the Jolokia endpoint.


### Spring Boot 1 Support

If you need support for Spring Boot 1, the setup process is mostly identical. The hawtio-springboot dependency should be changed to hawtio-springboot-1.

{% highlight xml %}
<dependency>
    <groupId>io.hawt</groupId>
    <artifactId>hawtio-springboot-1</artifactId>
    <version>2.3.0</version>
</dependency>
{% endhighlight %}

Some of the Spring Boot configuration property names will be different. Refer to the [Spring Boot 1 documentation](https://docs.spring.io/spring-boot/docs/1.5.x/reference/html/) for more information.

### Example Applications

The Hawtio project has some example Spring Boot applications which demonstrate how to configure authentication and how to integrate with other frameworks like Apache Camel.

[https://github.com/hawtio/hawtio/tree/master/examples](https://github.com/hawtio/hawtio/tree/master/examples)


## Conclusion

Hopefully this was a good introduction of how Spring Boot integration works in Hawtio. If you have feedback, we'd love to hear about it! Feel free to open an [issue](https://github.com/hawtio/hawtio/issues) or raise a [pull request](https://github.com/hawtio/hawtio/pulls) if you'd like to contribute.

