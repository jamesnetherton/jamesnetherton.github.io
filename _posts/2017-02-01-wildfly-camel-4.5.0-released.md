---
layout:     post
title: "WildFly Camel 4.5.0 released"
summary: "An overview of what's new in the 4.5.0 release"
tags: [WildFly, Camel, OpenShift, Kubernetes, WildFly Swarm]
---

[WildFly Camel](https://github.com/wildfly-extras/wildfly-camel) [4.5.0](https://github.com/wildfly-extras/wildfly-camel/releases/tag/4.5.0) has been released. I've not
covered any of the significant changes to WildFly Camel since the 4.0.0 release, so it's high time I wrote an article to talk about some of them.

### Project documentation

The project documentation has been migrated from GitBook to Asciidoc format and is now found at:

[http://wildfly-extras.github.io/wildfly-camel](http://wildfly-extras.github.io/wildfly-camel)

### New supported components

Since the 4.0.0 release an additional 45 components are now supported. The aim is to support as many Camel components as is possible. Providing they are not marked as deprecated, use technologies that have reached end of life and do not clash with existing WildFly functionality.

The project now also maintains [roadmaps](https://github.com/wildfly-extras/wildfly-camel/blob/master/catalog/src/main/resources/) for Camel components, dataformats and scripting languages.

### WildFly Camel S2I Docker image for OpenShift

Adoption of development on [Kubernetes](https://kubernetes.io/) and [OpenShift](https://www.openshift.com) continues apace. The WildFly Camel project recently added its own [Source To Image](https://docs.openshift.org/latest/architecture/core_concepts/builds_and_image_streams.html#source-build) (S2I) [Docker image](https://hub.docker.com/r/wildflyext/s2i-wildfly-camel/) to support this.

More details can be found [here](http://wildfly-extras.github.io/wildfly-camel/#_source_to_image).

### Eclipse Che Workspace

A quick way of getting started with WildFly Camel development is via our [Eclipse Che Workspace](https://beta.codenvy.com/f?id=chknwakr0ykhqr1q). Follow the link and you'll be able to work on example projects.

### Camel on WildFly Swarm

We continue to maintain the Camel subsystem integration with the [WildFly Swarm](http://wildfly.org/swarm/) project. The latest example projects can be found [here](https://github.com/wildfly-swarm/wildfly-swarm-examples/tree/master/camel).
