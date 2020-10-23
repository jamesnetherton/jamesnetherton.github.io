---
layout:     post
title: "Camel Quarkus Observability Support"
summary: "How to add support for metrics, health checks and tracing to a Camel Quarkus application"
tags: [Camel, Quarkus]
---

Camel Quarkus 0.3.0 includes support for adding observability capabilities such as application metrics, health checks and distributed tracing. This post gives a brief explanation of how to configure and use these features.

## Metrics

Camel Quarkus provides an extension which builds on top of [Quarkus metrics](https://quarkus.io/guides/metrics-guide) so that Camel applications can produce metrics and have them processed by tools such as Prometheus.

To start working with metrics, add the `camel-quarkus-microprofile-metrics` extension

{% highlight xml %}
<dependency>
    <groupId>org.apache.quarkus</groupId>
    <artifactId>camel-quarkus-microprofile-metrics</artifactId>
</dependency>
{% endhighlight %}

> **NOTE:**  There's no version specified. It's assumed that the project parent is `camel-quarkus-bom`. Refer to the Camel Quarkus [getting started guide](https://camel.apache.org/camel-quarkus/latest/user-guide.html#_step_by_step_with_the_rest_json_example).


### Provided metrics

When the extension is included, it automatically begins to collect Camel related metrics. Such as: 

* The number of completed, failed or inflight exchanges
* The mean, minimum and maximum processing processing times for exchanges through each route
* The Camel context uptime

There's a more comprehensive list of metrics in the [extension documentation](https://camel.apache.org/camel-quarkus/latest/extensions/microprofile-metrics.html#_usage).

Each metric is tagged with the name of the Camel context and where appropriate, the Camel route id. 

You can review the generated metrics by executing `curl -H"Accept: application/json" localhost:8080/metrics/application`. To view the output in the OpenMetrics format, remove the 
`-H"Accept: application/json"` argument. The example output should look something like this.

{% highlight json %}
{
  "camel.route.exchanges.completed.total;camelContext=camel-quarkus-observability;routeId=route1": 4,
  "camel.route.exchanges.completed.total;camelContext=camel-quarkus-observability;routeId=route2": 4,
  "camel.context.uptime;camelContext=camel-quarkus-observability": 39799,
  "camel.context.exchanges.completed.total;camelContext=camel-quarkus-observability": 8,
  "camel.route.externalRedeliveries.total;camelContext=camel-quarkus-observability;routeId=route2": 0,
  "camel.context.exchanges.total;camelContext=camel-quarkus-observability": 8,
  "camel.exchange.processing": {
    "max;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 4760254484,
    "p75;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 3905296516,
    "stddev;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 1190768315.9025462,
    "min;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 1884000000,
    "p95;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 4760254484,
    "p50;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 1968567546,
    "p99;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 4760254484,
    "p98;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 4760254484,
    "mean;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 2941856018.3989124,
    "p999;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 4760254484,
    "meanRate;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 0.2068157217537497,
    "fiveMinRate;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 0.38112608423917144,
    "count;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 8,
    "oneMinRate;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 0.32458314691034595,
    "fifteenMinRate;camelContext=camel-quarkus-observability;endpointName=timer://greeting?period=10s;eventType=ExchangeCreatedEvent": 0.3934614333270665,
  },
  "camel.route.externalRedeliveries.total;camelContext=camel-quarkus-observability;routeId=route1": 0,
  "camel.route.exchanges.inflight.count;camelContext=camel-quarkus-observability;routeId=route2": 0,
  "camel.route.count;camelContext=camel-quarkus-observability": 2,
  "camel.context.exchanges.inflight.count;camelContext=camel-quarkus-observability": 0,
  "camel.route.exchanges.failed.total;camelContext=camel-quarkus-observability;routeId=route1": 0,
  "camel.route.exchanges.failed.total;camelContext=camel-quarkus-observability;routeId=route2": 0,
  "camel.context.failuresHandled.total;camelContext=camel-quarkus-observability": 0,
  "camel.context.exchanges.failed.total;camelContext=camel-quarkus-observability": 0,
  "camel.route.running.count;camelContext=camel-quarkus-observability": 2,
  "camel.route.exchanges.total;camelContext=camel-quarkus-observability;routeId=route2": 4,
  "camel.route.exchanges.total;camelContext=camel-quarkus-observability;routeId=route1": 4,
  "camel.route.failuresHandled.total;camelContext=camel-quarkus-observability;routeId=route2": 0,
  "camel.route.failuresHandled.total;camelContext=camel-quarkus-observability;routeId=route1": 0,
  "camel.context.externalRedeliveries.total;camelContext=camel-quarkus-observability": 0,
  "camel.route.processing": {
    "p999;camelContext=camel-quarkus-observability;routeId=route1": 4759773844,
    "p95;camelContext=camel-quarkus-observability;routeId=route1": 4759773844,
    "max;camelContext=camel-quarkus-observability;routeId=route1": 4759773844,
    "p50;camelContext=camel-quarkus-observability;routeId=route1": 1966499655,
    "p99;camelContext=camel-quarkus-observability;routeId=route1": 4759773844,
    "p75;camelContext=camel-quarkus-observability;routeId=route1": 3903591192,
    "min;camelContext=camel-quarkus-observability;routeId=route1": 1887061052,
    "mean;camelContext=camel-quarkus-observability;routeId=route1": 2957773658.2611957,
    "p98;camelContext=camel-quarkus-observability;routeId=route1": 4759773844,
    "stddev;camelContext=camel-quarkus-observability;routeId=route1": 1212814015.7063947,
    "oneMinRate;camelContext=camel-quarkus-observability;routeId=route1": 0.16229157345517298,
    "meanRate;camelContext=camel-quarkus-observability;routeId=route1": 0.1033277281226765,
    "count;camelContext=camel-quarkus-observability;routeId=route1": 4,
    "fifteenMinRate;camelContext=camel-quarkus-observability;routeId=route1": 0.19673071666353326,
    "fiveMinRate;camelContext=camel-quarkus-observability;routeId=route1": 0.19056304211958572
  },
  "camel.context.status;camelContext=camel-quarkus-observability": 1
}
{% endhighlight %}

### Custom metrics

You can generate your own custom metrics by configuring microprofile-metrics endpoints in your Camel routes. For example, to increment a counter metric every 10 seconds:

{% highlight java %}
from("timer:incrementMetric?period=10s")
  .to("microprofile-metrics:counter:simple.counter")
{% endhighlight %}

To see the full set of available endpoint options, refer to the [Camel MicroProfile Metrics documentation](https://camel.apache.org/components/latest/microprofile-metrics-component.html). 

Alternatively, you can leverage the MicroProfile metrics API in your code. Refer to the [Quarkus metrics documentation](https://quarkus.io/guides/metrics-guide) for more information about that.

## Health

Support for health checks with Camel Quarkus is provided by the `camel-quarkus-microprofile-health` extension. It builds on top of [Quarkus health](https://quarkus.io/guides/health-guide).

To start working with health checks add the `camel-quarkus-microprofile-health` extension

{% highlight xml %}
<dependency>
    <groupId>org.apache.quarkus</groupId>
    <artifactId>camel-quarkus-microprofile-health</artifactId>
</dependency>
{% endhighlight %}

### Provided health checks

Camel provides some simple liveness and readiness checks out of the box. To see these in action, execute `curl localhost:8080/health/live` and `curl localhost:8080/health/ready`. You should see an output similar to below.

{% highlight json %}
{
  "status": "UP",
  "checks": [
    {
      "name": "camel",
      "status": "UP",
      "data": {
        "contextStatus": "Started",
        "name": "camel-quarkus-observability"
      }
    }
  ]
}
{% endhighlight %}

The first status field indicates that the overall liveness or readiness of the application is "UP". The checks field contains a summary of all of the configured liveness or readiness checks. 

In this case there is a check named 'camel' which verifies whether the Camel context status is 'Started'. In this case this condition is true so the health check status is reported as "UP". You'd see it as "DOWN" if the context status was any other value.

### Custom health checks

You can write your application health checks using the Camel Health API. There are two convenience classes that can be extended: 

* `AbstractCamelMicroProfileLivenessCheck` 
* `AbstractCamelMicroProfileReadinessCheck`

For example:

{% highlight java %}
public class CustomLivenessCheck extends AbstractCamelMicroProfileLivenessCheck {

    public CustomLivenessCheck() {
        super("my-liveness-check-name");
        getConfiguration().setEnabled(true);
    }

    @Override
    protected void doCall(HealthCheckResultBuilder builder, Map<String, Object> options) {
        if (someSuccessCondition) {
            builder.up();
        } else {
            builder.down();
        }
    }
}
{% endhighlight %}

Alternatively you can leverage MicroProfile Health APIs as outlined in the [Quarkus health guide](https://quarkus.io/guides/health-guide).

## Tracing

Support for tracing with Camel Quarkus is provided by the `camel-quarkus-opentracing` extension.

To enable tracing support, add the `camel-quarkus-opentracing` extension

{% highlight xml %}
<dependency>
    <groupId>org.apache.quarkus</groupId>
    <artifactId>camel-quarkus-opentracing</artifactId>
</dependency>
{% endhighlight %}

The extension uses the [Camel OpenTracing](https://camel.apache.org/components/latest/opentracing.html) component and automatically configures it in order to start tracing your routes.

Traces can be sent to a tracing server by adding some configuration options to `application.properties`.

{% highlight txt %}
quarkus.jaeger.service-name = awesome-service
quarkus.jaeger.sampler-type = const
quarkus.jaeger.sampler-param = 1
quarkus.jaeger.endpoint = http://localhost:14268/api/traces
{% endhighlight %}

For local development you can start a local tracing server with Docker.

{% highlight txt %}
docker run -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 -p 5775:5775/udp -p 6831:6831/udp -p 6832:6832/udp -p 5778:5778 -p 16686:16686 -p 14268:14268 -p 9411:9411 jaegertracing/all-in-one:latest
{% endhighlight %}


## Example application

There's an example application featuring all of the extensions mentioned in this post [here](https://github.com/apache/camel-quarkus/tree/master/examples/observability).

## Conclusion

Hopefully this post was a useful introduction to the observability features of Camel Quarkus. As ever, feedback and contributions are welcome. Feel free to file an [issue](https://github.com/apache/camel-quarkus/issues) for any improvements.
