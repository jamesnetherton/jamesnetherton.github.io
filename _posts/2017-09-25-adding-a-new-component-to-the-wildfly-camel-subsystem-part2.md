---
layout:     post
title: "Adding a new Camel component to the WildFly Camel subsystem. Part 2"
summary: "How to write integration tests for the WildFly Camel subsystem"
tags: [WildFly,Camel]
---

In this post we look at how we create integration tests and component documentation for the WildFly Camel subsystem. In [part 1](/2017/09/25/adding-a-new-component-to-the-wildfly-camel-subsystem-part1) we got to the point where we had successfully created some JBoss Modules XML definitions.

### 1. Adding a new integration test package

Create a new package for your component integration tests within the `itests/standalone/basic` module. Typically the package name follows the name of the Camel component being tested (E.g geocoder for camel-geocoder etc).

### 2. Add a new integration test class

Next add a test class to the new package. Here's an example from the camel-geocoder component tests.

{% highlight java %}
package org.wildfly.camel.test.geocoder;

import java.util.List;

import com.google.code.geocoder.model.GeocodeResponse;
import com.google.code.geocoder.model.GeocoderResult;
import com.google.code.geocoder.model.LatLng;

import org.apache.camel.CamelContext;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.geocoder.http.HttpClientConfigurer;
import org.apache.camel.impl.DefaultCamelContext;
import org.jboss.arquillian.container.test.api.Deployment;
import org.jboss.arquillian.junit.Arquillian;
import org.jboss.arquillian.test.api.ArquillianResource;
import org.jboss.shrinkwrap.api.ShrinkWrap;
import org.jboss.shrinkwrap.api.spec.JavaArchive;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.wildfly.extension.camel.CamelAware;

@CamelAware
@RunWith(Arquillian.class)
public class GeocoderIntegrationTest {

    @Deployment
    public static JavaArchive createDeployment() {
        return ShrinkWrap.create(JavaArchive.class, "camel-geocoder-tests.jar");
    }

    @Test
    public void testGeocoderComponent() throws Exception {

        CamelContext camelctx = new DefaultCamelContext();
        camelctx.addRoutes(new RouteBuilder() {

            @Override
            public void configure() throws Exception {
                from("direct:start")
                .to("geocoder:address:London, England");
            }
        });

        camelctx.start();
        try {
            ProducerTemplate template = camelctx.createProducerTemplate();
            GeocodeResponse result = template.requestBody("direct:start", null, GeocodeResponse.class);
            Assert.assertNotNull("Geocoder response is null", result);

            List<GeocoderResult> results = result.getResults();
            Assert.assertNotNull("Geocoder results is null", result);
            Assert.assertEquals("Expected 1 GeocoderResult to be returned", 1, results.size());

            LatLng location = results.get(0).getGeometry().getLocation();
            Assert.assertEquals("51.5073509", location.getLat().toPlainString());
            Assert.assertEquals("-0.1277583", location.getLng().toPlainString());
        } finally {
            camelctx.stop();
        }
    }
}
{% endhighlight %}

The critical thing is that we always want to execute the test within the WildFly container. Hence we use the Arquillian test runner.

The rest of the test is self explanatory. We create a camel context and then test that a simple route returns the results we expect.

If possible, try to test both the consumer and producer (when available). For data formats, test the marshal and unmarshal scenarios.

The aim of the test is to verify that the module definitions we created are correct and that there are no class loading problems. It's not so important to delve too deeply into testing component functionality.

### 3. Adding component documentation

Each time a new component is added, it should be added to the [user guide](https://wildfly-extras.github.io/wildfly-camel/). The project documentation is written with [AsciiDoc](http://asciidoctor.org/). Create a new `adoc` file within `docs/guide/components`, the file name convention is `camel-<component name>.adoc`. E.g `camel-geocoder.adoc`.

All that's required is a basic sentence explaining what the component does, together with a link to the Apache Camel component documentation page. We usually borrow the component description from the Apache Camel documentation to keep things simple. You can look at the other component `adoc` files for examples.

Finally, add a link to the new camel component `adoc` file within the table of contents in `docs/guide/components/index.adoc`.

### 4. Finishing up

If your tests pass, great! Run the full project test suite to verify that everything still works.

{% highlight bash %}
$ mvn clean install -Dts.all
{% endhighlight %}

Else you may need to adjust your module definitions, rebuild and retest.

When you're done, commit all modified project files and submit a pull request.
