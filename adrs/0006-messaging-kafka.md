# Messaging using Apache Kafka

Date: 2022-10-15

## Status

Accepted

## Context

We need to select a messaging solution to asyncronously send messages from one Spring Boot microservice to another.

## Decision

We will use the Java Messaging Service (JMS) from our Java Spring Boot applications to publish and subscribe to queues and topics on an Apache ActiveMQ server.

## Consequences
We need to install and maintain an Apache ActiveMQ server for each environment.