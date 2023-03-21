# Messaging using JMS

Date: 2022-08-15

## Status

Superseded [ADR 6](0006-messaging-kafka.md)

## Context

We need to select a messaging solution to asyncronously send messages from one Spring Boot microservice to another.

## Decision

We will use the Java Messaging Service (JMS) from our Java Spring Boot applications to publish and subscribe to queues and topics on an Apache ActiveMQ server.

## Consequences
We need to install and maintain an Apache ActiveMQ server for each environment.