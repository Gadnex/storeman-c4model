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
                    technology "Postgress"
                    tags "Postgress"

                    apiApplication -> this "stores and retrieves data in" "JPA"
                    registrationApi -> this "stores and retrieves data in" "JPA"
                    requestApi -> this "stores and retrieves data in" "JPA"
                }
            }
        }

        oAuthServer = softwareSystem "Keycloak" {
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

        elasticSearch = softwareSystem "ElasticSearch" {
            description "Distributed JSON-based search and analytics engine."
            tags "ElasticSearch"
        }

        fluentd = softwareSystem "Fluentd" {
            description "Open source data collector for unified logging layer."
            tags "Fluentd"

            this -> storeMan "collect logs from" "File System"
            this -> elasticSearch "persists logs to"
        }

        kibana = softwareSystem "Kibana" {
            description "Visualization and data analysis of log data"
            tags "Kibana"

            this -> elasticSearch "visualize logs from"
        }

        prometheus = softwareSystem "Prometheus" {
            description "Scraping and storage of metrics data"
            tags "Prometheus"

            this -> storeMan "pull metrics data from" "HTTPS"
            this -> webApplication "pull metrics data from" "HTTPS"
            this -> apiApplication "pull metrics data from" "HTTPS"
            this -> actuatorComponent "pull metrics data from" "HTTPS"
        }

        grafana = softwareSystem "Grafana" {
            description "Visualization of metrics data"
            tags "Grafana"

            this -> prometheus "visualize metrics data from"
        }

        kafka = softwareSystem "Kafka" {
            description "Distributed event streaming platform"
            tags "Kafka"

            apiApplication -> this "publish and subscribe to topics on" "Avro/tcp"
            registrationApi -> this "publish to send-registration-email topic" "Avro/tcp" "Registration"
            requestApi -> this "publish to send-request-email topic" "Avro/tcp" "Request"
            emailComponent -> this "subscribe to send-registration-email topic" "Avro/tcp" "Registration"
            emailComponent -> this "subscribe to send-request-email topic" "Avro/tcp" "Request"
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
            this -> oAuthServer "provides authentication credentials to" "OAuth/HTTPS" {
                perspectives {
                    Security "Connection is secured using HTTPS."
                }
            }
        }
        systemAdministrator = person "System Administrator" {
            description "Manages users and other configurations of the system."
            this -> oAuthServer "manages users and configurations in"
        }

        # Deployment
        development = deploymentEnvironment "Development Environment" {
            devLaptop = deploymentNode "Developer Laptop" {
                deploymentNode "Docker CE (Community Edition)" {
                    tags "Docker"

                    softwareSystemInstance oAuthServer
                    softwareSystemInstance kafka
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
            }
            deploymentNode "Amazon Web Services" {
                 tags "Amazon Web Services - Cloud"
                
                deploymentNode "eu-central-1" {
                    tags "Amazon Web Services - Region"
                
                    deploymentNode "Amazon EC2" {
                        tags "Amazon Web Services - EC2"
                        
                        deploymentNode "Kubernetes + Rancher" {
                            tags "Kubernetes"

                            infrastructureNode "Source Control and CI/CD" "Stores Source Code and does continuous integration and continuous deployment" "GitLab" {
                                tags "GitLab"
                                devLaptop -> this "publish source code" "Git/TCP"
                            }
                        }
                    }
                }
            }
        }
    }

    views {
        properties {
            "mermaid.url" "https://mermaid.ink"
            "mermaid.format" "svg"
        }

        systemContext storeMan "Context" {
            include * systemAdministrator fluentd elasticSearch kibana prometheus grafana
        }

        container storeMan "ContainerStoreMan" {
            include *
        }

        component apiApplication "ComponentApiApplication_All" "All of the components for the API Application" {
            include *
            exclude databaseSchema
        }

        component apiApplication "ComponentApiApplication_Registration" "Only the Registration Api component of the API Application" {
            include singlePageApplication registrationApi databaseSchema kafka emailComponent mailServer
            exclude relationship.tag==Request
        }

        component apiApplication "ComponentApiApplication_Request" "Only the Request Api component of the API Application" {
            include singlePageApplication requestApi databaseSchema kafka emailComponent mailServer
            exclude relationship.tag==Registration
        }

        deployment storeMan development "DevelopmentEnvironment" {
            include *
        }

        image storeMan "Drawio" {
            image diagrams/Flowchart.drawio.png
            title "An example Draw.io diagram"
        }

        image storeMan "Mermaid" {
            mermaid diagrams/Flowchart.mmd
            title "An example Mermaid.js diagram"
        }

        !include styles.dsl
    }

}