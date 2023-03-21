# Document architecture using C4 Model and Structurizr

Date: 2021-06-07

## Status

Accepted

## Context

We need to document the architecture of the StoreMan system in a structured way.
Documentation should be in a textual format that can be committed to a Git repository and version controlled.

## Decision

We will use the [C4 Model](https://c4model.com/) to document the architecture of our system.
In terms of tooling we will make use of the [Structurizr](https://structurizr.com/) to create our C4 models.
We will use the [Structurizr DSL](https://github.com/structurizr/dsl) (Domain Specific Language) to document our architecture in a textual format that will be committed to a Git repository and version controlled.
In order to view and edit the Structurizr documentation locally, we will make use of [Structurizr Lite](https://github.com/structurizr/lite) on the architect and developer machines.
At a later stage we could consider moving to the Structurizr cloud or on premise solutions to publish our C4 models and documentation.

## Consequences
Our architecture documentation will be in a Git repository and not in Confluence with the rest of our project documentation.
