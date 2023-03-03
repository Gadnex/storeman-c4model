# StoreMan

> StoreMan is not a real computer system and it is not intended to develop the StoreMan system. The goal of this project is to show an example of how system/software architecture can be documented using the C4 Model concepts using Structurizr DSL as a modelling notation and markdown for textual documentation.

## System Context
StoreMan is a computer system designed for the registration and storage of property items in order to keep track of the items in terms of their current location. This location will either be a storage location where it is currently stored or a system user who checked the item out of storage for some purpose.

In order to remove an item from storage, a request needs to be logged and approved by a supervisor before it can be handed over to the user.

After the handover the user will perform the required actions according to the request and record the results of the request when they are done.

After request results are recorded, an item needs to be stored again, which is handled through the same request procedure. Any user in possession of an item can store the item in one of their registered storage locations.

When the organisation has no further use for the item, it needs to be disposed. Disposals are also handled through the request procedure.

StoreMan can be used in a wide array of environments ranging from simple examples like an informal library to complex environments like a Police crime scene exhibit store.

![System Context](embed:Context)

### People
#### User
A user refers to any registered user of the StoreMan system, which interacts with the system using either the
Single-Page Web Application or the Mobile Application.

Users can have multiple roles that filters the actions that users can perform on the system. These roles include:
- **Storage Location Administrator** - Manages storage locations and assigns them to Storage Officials.
- **Registration Official** - Registers new property items in the system.
- **Storage Official** - Stores property items in storage locations and hands over property items from a storage location.
- **Requestor** - Creates requests for property items to use property item for a purpose.
- **Request Approver** - Approves or declines requests for property items.

#### System Administrator
Manages users and other configurations of the system.

### Software Systems
#### StoreMan
StoreMan refers to the system under discussion in this document.
#### Keycloak
Keycloak has been selected as the OAuth2 and OpenId connect compliant single sign-on aouthorization server.