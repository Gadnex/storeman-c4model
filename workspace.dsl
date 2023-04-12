workspace "StoreMan" "C4 Model of the StoreMan system" {
    !docs docs
    !adrs adrs

    model {
        storeMan = softwareSystem "StoreMan" "Registration and storage of property items in order to keep track of item locations." {

            group "Front End" {
                webApplication = container "Web Application" {
                    description "Delivers static content and the StoreMan single page application."
                    technology "Spring Boot"
                    tags "Spring"
                }
                singlePageApplication = container "Single-Page Application" {
                    description "Provides all of the StoreMan functionality via the web browser."
                    technology "Angular"
                    tags "Angular"
                    perspectives {
                        Security "The Single-Page Application is a public OAuth2 and OICD client using the Authentication Code grant type with PKCE to redirect the user's browser to the Keycloak server. The OAuth2 JWT token is saved in the user's browser and passed to the API Application with every HTTP call."
                    }

                    webApplication -> this "delivers to the user's web browser"
                }
                mobileApplication = container "Mobile Application" {
                    description "Provides a limited subset of the StoreMan functionality via an Android or iOS mobile device."
                    technology "React Native"
                    tags "React Native"
                    perspectives {
                        Security "The Mobile Application is a confidential OAuth2 and OICD client using the Authentication Code grant type to redirect the user's mobile phone browser to the Keycloak server. The OAuth2 JWT token is saved in the Mobile Application and passed to the API Application with every HTTP call."
                    }
                }
            }
            group "Back End" {
                apiApplication = container "API Application" {
                    description  "Provides the StoreMan functionality via a JSON/HTTPS API"
                    technology "Spring Boot"
                    tags "Spring"
                    perspectives {
                        Security "The endpoint of the API is secured using HTTPS. The HTTPS connection is not configured by the Spring Boot application, but by the Docker container management solution. Authentication and Authorisation is implemented by using OAuth2 and OICD. The API Application is an OAuth Resource Server."
                    }

                    singlePageApplication -> this "makes API calls to" "JSON/HTTPS" {
                        perspectives {
                            Security "Connection secured using HTTPS."
                        }
                    }
                    mobileApplication -> this "makes API calls to" "JSON/HTTPS" {
                        perspectives {
                            Security "Connection secured using HTTPS."
                        }
                    }

                    registrationApi = component "Registration API" {
                        description "API to register new property items and approving/verifying registered property items. Also for the configuration of new property item types."
                        technology "Spring/Java"

                        singlePageApplication -> this "makes API calls to" "JSON/HTTPS"
                    }
                    packagingApi = component "Packaging API" {
                        description "API to store package property items and label packages with a barcode and important textual information."
                        technology "Spring/Java"

                        singlePageApplication -> this "makes API calls to" "JSON/HTTPS"
                    }
                    storageLocationApi = component "Storage Location API" {
                        description "API to manage storage locations where property ietms can be stored."
                        technology "Spring/Java"

                        singlePageApplication -> this "makes API calls to" "JSON/HTTPS"
                    }
                    storageApi = component "Storage API" {
                        description "API to store packaged property items in a storage location."
                        technology "Spring/Java"

                        singlePageApplication -> this "makes API calls to" "JSON/HTTPS"
                        mobileApplication -> this "makes API calls to" "JSON/HTTPS"
                    }
                    handOverApi = component "Hand Over API" {
                        description "API to hand over a property item from one user to another, or from a storage location to a user."
                        technology "Spring/Java"

                        singlePageApplication -> this "makes API calls to" "JSON/HTTPS"
                        mobileApplication -> this "makes API calls to" "JSON/HTTPS"
                    }
                    requestApi = component "Request API" {
                        description "API to request property items for a specific purpose and approval of requests. The API also allows configuration of request reasons."
                        technology "Spring/Java"

                        singlePageApplication -> this "makes API calls to" "JSON/HTTPS"
                        mobileApplication -> this "makes API calls to" "JSON/HTTPS"
                    }
                    emailComponent = component "Email Component" {
                        description "Asynchronously render email messages and send them to the recipient"
                        technology "Spring/Java"
                    }
                    actuatorComponent = component "Spring Actuator" {
                        description "Expose a management API for Spring Boot application"
                        technology "spring-boot-starter-actuator"
                        tags "Spring"
                    }
                }
                databaseSchema = container "Database Schema" {
                    description "Stores all of the StoreMan data"
                    technology "PostgreSQL"
                    tags "PostgreSQL"

                    apiApplication -> this "stores and retrieves data in" "JPA"
                    registrationApi -> this "stores and retrieves data in" "JPA"
                    requestApi -> this "stores and retrieves data in" "JPA"
                }
            }
            group "3rd party" {
                keycloak = container "Keycloak" {
                    description "OAuth2 and OpenId Connect compliant server"
                    tags "Keycloak"
                    perspectives {
                        Security "Keycloak is an OAuth2 and OICD compatable Authentication Server and users are managed inside Keycloak."
                    }

                    singlePageApplication -> this "requests OAuth token" "HTTPS" {
                        perspectives {
                            Security "Connection secured using HTTPS. This call is made over the public Internet from the user's web browser."
                        }
                    }
                    mobileApplication -> this "requests OAuth token" "HTTPS" {
                        perspectives {
                            Security "Connection secured using HTTPS. This call is made over the public Internet from the user's mobile phone."
                        }
                    }
                    apiApplication -> this "verifies OAuth token" "HTTPS"  {
                        perspectives {
                            Security "Connection secured using HTTPS. This call is NOT made over the public Internet but over the back channel network."
                        }
                    }
                }

                kafka = container "Kafka" {
                    description "Distributed event streaming platform"
                    tags "Kafka"

                    apiApplication -> this "publish and subscribe to topics on" "Avro/tcp"
                    registrationApi -> this "publish to send-registration-email topic" "Avro/tcp" "Registration"
                    requestApi -> this "publish to send-request-email topic" "Avro/tcp" "Request"
                    emailComponent -> this "subscribe to send-registration-email topic" "Avro/tcp" "Registration"
                    emailComponent -> this "subscribe to send-request-email topic" "Avro/tcp" "Request"
                }
            }
        }

        activeDirectory = softwareSystem "Microsoft Active Directory" {
            description "An LDAP compatible active directory server which stores user credentials, roles and groups"
            tags "Azure Active Directory"

            keycloak -> this "authenticate users using" "LDAP"
        }

        mailServer = softwareSystem "Mail Server" {
            description "An SMTP capable mail server"
            tags "External Software"

            emailComponent -> this "send emails using" "SMTP"
        }

        # People
        user = person "User" {
            description "A registered user of the system. Users can register PIs (property items), store PIs, hand over PIs, request PIs, etc."
            this -> storeMan "uses"
            this -> webApplication "navigate web browser to" "HTTPS"
            this -> singlePageApplication "interacts with user interface"
            this -> mobileApplication "interacts with user interface"
            this -> keycloak "provides authentication credentials to" "OAuth/HTTPS" {
                perspectives {
                    Security "Connection is secured using HTTPS."
                }
            }
        }
        systemAdministrator = person "System Administrator" {
            description "Manages users and other configurations of the system."
            this -> keycloak "manages users and configurations in"
        }

        # Deployment
        production = deploymentEnvironment "Production Environment" {
            deploymentNode "hub-virtual-network" {
                tags "Microsoft Azure - Virtual Networks"

                firewall = infrastructureNode "Corp Firewall" {
                    tags "Microsoft Azure - Firewalls"
                    description "Secure network and prevent illegal incoming traffic"
                }

                gateway = infrastructureNode "Corp application gateway" {
                    tags "Microsoft Azure - Application Gateways"
                    description "Route incoming requests to correct environment"

                    firewall -> gateway "allow requests to" "HTTPS"
                }
            }

            deploymentNode "spoke-virtual-network" {
                tags "Microsoft Azure - Virtual Networks"

                azureSpingApps = deploymentNode "Azure Spring Apps" {
                    tags "Microsoft Azure - Azure Spring Apps"

                    deploymentNode "Service Runtime Subnet" {
                        infrastructureNode "Azure Load Balancer" {
                            tags "Microsoft Azure - Load Balancers"
                            description "Load balance incoming requests over container instances"
                        }

                        infrastructureNode "Config Server" {
                            tags "Spring"
                            description "Manage configuration details for Spring Boot applications"
                        }

                        infrastructureNode "Service Registry" {
                            tags "Spring"
                            description "Spring Boot applications register temselves with the service registry and other apps can look up apps on the service registry"
                        }
                    }

                    deploymentNode "Apps Subnet" {
                        infrastructureNode "Azure Load Balancer" {
                            tags "Microsoft Azure - Load Balancers"
                            description "Load balance incoming requests over container instances"
                        }

                        containerInstance webApplication
                        containerInstance apiApplication
                    }

                    gateway -> azureSpingApps "route request to" "HTTPS"
                }

                deploymentNode "Data Services Subnet" {
                    tags "Microsoft Azure - Subnet"

                    deploymentNode "Azure PostgreSQL DB" {
                        tags "Microsoft Azure - Azure Database PostgreSQL Server"

                        containerInstance databaseSchema
                    }

                }

                deploymentNode "Azure Virtual Machine" {
                    tags "Microsoft Azure - Virtual Machine"
                    instances 3

                    containerInstance keycloak
                }
            }

            deploymentNode "On-premises network" {
                tags "Microsoft Azure - Exchange On Premises Access"

                softwareSystemInstance mailServer
                softwareSystemInstance activeDirectory
            }

            deploymentNode "Confluent Cloud Environment" {
                containerInstance kafka
            }

            deploymentNode "CI/CD Pipelines" {
                azureDevOps = infrastructureNode "Azure DevOps" {
                    tags "Microsoft Azure - Azure DevOps"
                    description "Manage source code and versioning, build and deploy source code."

                    # devLaptop -> azureDevOps "publish source code" "Git/TCP"
                    azureDevOps -> azureSpingApps "deploy Docker containers"
                }
            }

            deploymentNode "Security Infrastructure" {
                azureKeyVault = infrastructureNode "Azure Key Vault" {
                    tags "Microsoft Azure - Key Vaults"
                    description "Manages application secrets and provides them to authorized cloud applications."

                    azureSpingApps -> azureKeyVault "pull secrets from"
                }
            }

            deploymentNode "Monitoring Infrastructure" {
                azureMonitor = infrastructureNode "Azure Monitor" {
                    tags "Microsoft Azure - Monitor"
                    description "Monitor cloud applications and make monitoring data available via a UI."

                    azureMonitor -> azureSpingApps "monitor applications"
                }
            }
        }

        localDevelopment = deploymentEnvironment "Development Environment" {
            deploymentNode "CI/CD Pipelines" {
                azureDevOpsDev = infrastructureNode "Azure DevOps" {
                    tags "Microsoft Azure - Azure DevOps"
                    description "Manage source code and versioning, build and deploy source code."
                }
            }

            devLaptop = deploymentNode "Developer Laptop" {
                deploymentNode "Docker CE (Community Edition)" {
                    tags "Docker"

                    containerInstance keycloak
                    containerInstance kafka
                    softwareSystemInstance mailServer
                }
                deploymentNode "JDK 17 (Java Development Kit)" {
                    tags "Java"

                    containerInstance apiApplication
                    containerInstance webApplication
                }
                deploymentNode "Node.js" {
                    tags "Node.js"

                    containerInstance singlePageApplication
                    containerInstance mobileApplication
                }

                devLaptop -> azureDevOpsDev "pull and push source code" "Git"
            }
        }
    }

    !include views.dsl

}