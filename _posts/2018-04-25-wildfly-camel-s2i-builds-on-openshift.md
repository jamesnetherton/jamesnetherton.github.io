---
layout:     post
title: "WildFly Camel Source To Image Builds"
tags: [WildFly, Camel, OpenShift]
---

The WildFly Camel project provides a container image which is capable of performing [Source To Image (S2I)](https://github.com/openshift/source-to-image#source-to-image-s2i) builds.

## S2I basics

First some preamble on what S2I is and how it works. It enables you to produce repeatable builds of docker images from source code.

An S2I builder image contains the required toolchain for building your project. For Java, that's usually Maven or Gradle. For Ruby apps a builder image
might contain bundler to install Ruby Gems etc, and a Golang app builder image would contain the Go compiler.

For a Java builder image, if it sees that the provided source code contains a pom.xml file, it can assume that it's possible to run a Maven build to package the application. For WildFly, this usually means producing a JAR, WAR or EAR. When the Maven build completes successfully, the builder image copies any built artifacts across to the WildFly deployments directory.

Here are some ways in which you can create and deploy Camel projects using the S2I builder image.

## Local directory S2I build

To start with, grab the S2I client binary from the project [releases](https://github.com/openshift/source-to-image/releases) page. Then switch to a Maven project directory for any deployable JAR or WAR project and run:

{% highlight bash %}
s2i build . wildflyext/wildfly-camel my-awesome-application
{% endhighlight %}

You can also run an S2I build on a directory containing pre-assembled artifacts. In this case there is no need for the builder image to run a Maven build.

When the S2I build is complete, you can run your application with docker:

{% highlight bash %}
docker run -ti wildflyext/wildfly-camel my-awesome-application
{% endhighlight %}

## Remote S2I build

You can also perform S2I builds using the URL to a git repository.

{% highlight bash %}
s2i build https://github.com/wildfly-extras/wildfly-camel-examples.git \
    -r 8.0.0 \
    --context-dir camel-cdi \
    wildflyext/wildfly-camel:8.0.0 wildfly-camel-example-cdi
{% endhighlight %}

## OpenShift S2I template build

The WildFly Camel project provides an OpenShift [ImageStream](https://docs.okd.io/latest/architecture/core_concepts/builds_and_image_streams.html#image-streams). You can add it to your cluster as follows:

{% highlight bash %}
oc apply -f http://wildfly-extras.github.io/wildfly-camel/sources/wildfly-camel-imagestream.json
{% endhighlight %}

Next install the WildFly Camel S2I application template:

{% highlight bash %}
oc apply -f http://wildfly-extras.github.io/wildfly-camel/sources/wildfly-camel-application-template.json
{% endhighlight %}

Now browse to the OpenShift web console, choose from an existing project or create a new one. Click 'Browse Catalog'. You should see an option to select named 'WildFly Camel':

![WildFly Camel S2I](/images/wfc-openshift.png)

Fill out the template parameters and click finish to start the S2I build.

![WildFly Camel S2I Build](/images/wfc-build-openshift.png)

When the build completes successfully you will see a running pod.

![WildFly Camel S2I Running Pod](/images/wfc-pod-openshift.png)

## Conclusion

Hopefully this is a good introduction to S2I with WildFly Camel. If you want to learn more, check out some of these links:

* [WildFly Camel S2I Documentation](http://wildfly-extras.github.io/wildfly-camel/#_source_to_image)
* [OKD Documentation](https://docs.okd.io/latest)
* [Source To Image Project](https://github.com/openshift/source-to-image)
* [WildFly S2I base image project](https://github.com/openshift-s2i/s2i-wildfly)
* [Red Hat Fuse on OpenShift](https://access.redhat.com/documentation/en-us/red_hat_fuse/7.1/html/fuse_on_openshift_guide/)
