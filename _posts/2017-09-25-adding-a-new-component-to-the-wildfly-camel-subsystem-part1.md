---
layout:     post
title: "Adding a new Camel component to the WildFly Camel subsystem. Part 1"
tags: [WildFly,Camel]
---

I wanted to explain the process of adding a new Camel component to the [WildFly Camel](https://github.com/wildfly-extras/wildfly-camel) project, as it's often the source of confusion for first time contributors.

Part 1 shows how to add a new component module XML descriptor to the project. [part 2](/2017/09/25/adding-a-new-component-to-the-wildfly-camel-subsystem-part2) covers integration testing.

### Prerequisites

First, some obvious prerequisites to get started. You'll need:

* Java / Maven installed
* Git installed so that you can fork / clone the [WildFly Camel](https://github.com/wildfly-extras/wildfly-camel) project
* An issue created via the project [issue tracker](https://github.com/wildfly-extras/wildfly-camel/issues) which you can reference later in your commit comment

### 1. Adding the new Camel component dependency

With the project cloned, edit `feature/modules/pom.xml` and add a new dependency for the component you want to integrate. 

Note the order of dependencies is in alphabetical order. This should be preserved unless there's a good reason not to.

### 2. Creating a Camel component module definition

Next we need to create a JBoss Modules XML descriptor for the new component. We use the [Smartics JBoss Modules Maven Plugin](https://github.com/smartics/smartics-jboss-modules-maven-plugin) to help with this.

Open `feature/modules/etc/smartics/camel-modules.xml` and create a module descriptor for the new component module.

For example, the definition for the geocoder component looks like this:

{% highlight xml %}
<module name="org.apache.camel.component.geocoder">
    <include artifact="com.google.code.geocoder-java:geocoder-java" />
    <include artifact="org.apache.camel:camel-geocoder" />
    <apply-to-dependencies skip="true">
        <include module="org.apache.camel.apt" />
        <include module="org.springframework.boot" />
    </apply-to-dependencies>
    <dependencies>
        <module name="org.slf4j" />
    </dependencies>
    <exports>
        <include path="com/google/code/geocoder/model" />
        <exclude path="com/google**" />
    </exports>
</module>
{% endhighlight %}

Here's a quick breakdown of what this all means.

##### Module name

The unique name assigned to the module. This also determines the directory structure on the filesystem. E.g `org.apache.camel.component.geocoder` is translated to a path of `org/apache/camel/component/geocoder/main`.

##### Include artifact

The resources that should be part of the module. There can be 0 or more of these. The artifact attribute is a Maven coordinate in the form `groupId:artifactId`.

Expressions are also allowed. E.g to include all dependencies matching `camel-` you could do:

{% highlight xml %}
<include artifact="org.apache.camel:camel-(.*)"/>
{% endhighlight %}

Sometimes it makes sense to bundle resource dependencies withing the same module as the camel component JAR. Otherwise, it's best to define new module definitions for resources in `feature/modules/etc/smartics/other-modules.xml`. If possible, try to group resources into logical units.

##### apply-to-dependencies

This is a block operation to apply to each module dependency. In our example we skip the dependencies defined in this block. Dependencies for `org.apache.camel.apt` and `org.springframework.boot` are skipped for all Camel component modules as they are not required by the Camel subsystem.

##### dependencies

Other modules on which the module depends on. In our example we only need to define a dependency on `org.slf4j`. Sometimes you will need to define others. The Smartics Maven plugin does a good job of determining dependencies for you at build time, so you can avoid explicitly listing all of them manually.

Note, `org.slf4j` is a mandatory dependency for all Camel component modules.

##### imports / exports

Sometimes you need to control what is exported onto the classpath. In our example we include a package path which users will need access to, but also exclude others which are not required.

### 3. Registering the component

The final task is to ensure that the WildFly Camel subsystem has access to the new component module. To do this edit `feature/modules/etc/managed/wildfly/modules/system/layers/fuse/org/apache/camel/component/main/module.xml`.

### 4. Finishing up

With the module definition created, we can generate the JBoss Modules `module.xml` file by running the build.

{% highlight bash %}
$ mvn clean install
{% endhighlight %}

When the build completes it will have generated your `module.xml` file and will have synchronized its directory structure back into the project tree at `feature/pack/src/main/resources/modules/system/layers/fuse`.

In [part 2](/2017/09/25/adding-a-new-component-to-the-wildfly-camel-subsystem-part2) we'll discover how to write an integration test for our new component module.
