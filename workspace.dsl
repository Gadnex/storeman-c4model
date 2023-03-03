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

        branding {
            logo "images/warehouse.png"
        }

        styles {
            element "Spring Boot" {
                stroke "#77bc1f"
                strokeWidth 10
                background "#dddddd"
                color "#77bc1f"
                icon "images/spring.png"
            }
            element "Keycloak" {
                stroke "#4d4d4d"
                strokeWidth 10
                background "#dddddd"
                color "#4d4d4d"
                icon "images/keycloak2.png"
            }
            element "Angular" {
                shape WebBrowser
                stroke "#c3002f"
                background "#dddddd"
                color "#c3002f"
                icon "images/angular.png"
            }
            element "React Native" {
                shape MobileDeviceLandscape
                stroke "#00d8ff"
                background "#dddddd"
                color "#00d8ff"
                icon "images/react_native.png"
            }
            element "Postgress" {
                shape Cylinder
                stroke "#336892"
                strokeWidth 10
                background "#dddddd"
                color "#336892"
                icon "images/postgresql.png"
            }
            element "Fluentd" {
                stroke "#000000"
                strokeWidth 10
                background "#dddddd"
                color "#000000"
                icon "images/fluentd.png"
            }
            element "ElasticSearch" {
                stroke "#000000"
                strokeWidth 10
                background "#dddddd"
                color "#000000"
                icon "images/elasticsearch.png"
            }
            element "Kibana" {
                stroke "#000000"
                strokeWidth 10
                background "#dddddd"
                color "#000000"
                icon "images/kibana.png"
            }
            element "Prometheus" {
                stroke "#000000"
                strokeWidth 10
                background "#dddddd"
                color "#000000"
                icon "images/prometheus.png"
            }
            element "Grafana" {
                stroke "#000000"
                strokeWidth 10
                background "#dddddd"
                color "#000000"
                icon "images/grafana.png"
            }
            element "Kafka" {
                stroke "#000000"
                strokeWidth 10
                background "#dddddd"
                color "#000000"
                icon "images/kafka.png"
            }
        }

        theme default
    }

}