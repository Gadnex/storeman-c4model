# OAuth2 and OICD with Keycloak

Date: 2023-03-22

## Status

Proposed

## Context

We need to decide how we are going to secure our Single-Page Application, Mobile Application and back-end APIs.

## Decision

We will use the OAuth2 and OICD protocols to secure our front-end UI applications and back-end APIs.
For a OAuth2 and OICD compliant Authorization Server we have decided to use Keycloak initially due to the fact that we have existing Keycloak experience within the team.
When we go to production we could decide if we want to invest in the commercial paid version of Keycloak called RedHat SSO (Single Sign On).

![Containers](embed:ContainerStoreMan{perspective=Security})

## Consequences
We will need to set up a Keycloak server and mainytain it in production.