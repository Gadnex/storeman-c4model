workspace "StoreMan" "C4 Model of the StoreMan system" {
    !docs docs

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

                    webApplication -> this "delivers to the user's web browser"
                }
                mobileApplication = container "Mobile Application" {
                    description "Provides a limited subset of the StoreMan functionality via an Android or iOS mobile device."
                    technology "React Native"
                    tags "React Native"
                }
            }
            group "Back End" {
                apiApplication = container "API Application" {
                    description  "Provides the StoreMan functionality via a JSON/HTTPS API"
                    technology "Spring Boot"
                    tags "Spring"

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

                        registrationApi -> this "send email using" "avro/kafka"
                        requestApi -> this "send email using" "avro/kafka"
                    }
                    actuatorComponent = component "Spring Actuator" {
                        description "Expose a management API for Spring Boot application"
                        technology "spring-boot-starter-actuator"
                        tags "Spring"
                    }
                }
                database = container "Database Schema" {
                    description "Stores all of the StoreMan data"
                    technology "Postgress"
                    tags "Postgress"

                    apiApplication -> this "stores and retrieves data in" "JPA"
                }
            }
        }

        oAuthServer = softwareSystem "Keycloak" {
            description "OAuth2 and OpenId Connect compliant server"
            tags "Keycloak"

            singlePageApplication -> this "requests OAuth token" "HTTPS"
            mobileApplication -> this "requests OAuth token" "HTTPS"
            apiApplication -> this "verifies OAuth token" "HTTPS"
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
            this -> oAuthServer "provides authentication credentials to" "OAuth/HTTPS"
        }
        systemAdministrator = person "System Administrator" {
            description "Manages users and other configurations of the system."
            this -> oAuthServer "manages users and configurations in"
        }
    }

    views {
        systemContext storeMan "Context" {
            include * systemAdministrator fluentd elasticSearch kibana prometheus grafana
        }

        container storeMan "ContainerStoreMan" {
            include *
        }

        component apiApplication "ComponentApiApplication" {
            include *
        }

        !include styles.dsl
    }

}