workspace "StoreMan" "C4 Model of the StoreMan system" {

    model {
        storeMan = softwareSystem "StoreMan" "Registration and storage of property items in order to keep track of item locations." {
            !docs docs

            webApplication = container "Web Application" {
                description "Delivers static content and the StoreMan single page application."
                technology "Spring Boot"
                tags "Spring Boot"
            }
            singlePageApplication = container "Single-Page Application" {
                description "Provides all of the StoreMan functionality via the web browser."
                technology "Angular"
                tags "Angular"
            }
            mobileApplication = container "Mobile Application" {
                description "Provides a limited subset of the StoreMan functionality via an Android or iOS mobile device."
                technology "React Native"
                tags "React Native"
            }
            apiApplication = container "API Application" {
                description  "Provides the StoreMan functionality via a JSON/HTTPS API"
                technology "Spring Boot"
                tags "Spring Boot"
            }
            database = container "Database" {
                description "Stores all of the StoreMan data"
                technology "Postgress"
                tags "Postgress"
            }

            webApplication -> singlePageApplication "delivers to the user's web browser"
            singlePageApplication -> apiApplication "makes API calls to" "JSON/HTTPS"
            mobileApplication -> apiApplication "makes API calls to" "JSON/HTTPS"
            apiApplication -> database "stores and retrieves data in" "JPA"
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

        # People
        user = person "User" {
            description "A registered user of the system"
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

        !include styles.dsl
    }

}