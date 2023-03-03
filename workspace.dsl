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
            oAuthServer = container "OAuth Server" {
                description ""
                technology "Keycloak"
                tags "Keycloak"
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
            singlePageApplication -> oAuthServer "requests OAuth token"
            mobileApplication -> apiApplication "makes API calls to" "JSON/HTTPS"
            mobileApplication -> oAuthServer "requests OAuth token"
            apiApplication -> oAuthServer "verifies OAuth token" "HTTPS"
            apiApplication -> database "stores and retrieves data in" "JPA"
        }

        # People
        user = person "User" {
            description "A registered user of the system"
            this -> webApplication "visits storeman.net using" "HTTPS"
            this -> singlePageApplication "interacts with user interface"
            this -> mobileApplication "interacts with user interface"
            this -> oAuthServer "provides authentication credentials to" "OAuth/HTTPS"
        }
        systemAdministrator = person "System Administrator" {
            description "Manages users and other configurations of the system."
            this -> storeMan "manages users and configurations in"
        }
        registrationOfficial = person "Registration Official" {
            description "Registers new property items in the system."
            this -> storeMan "registers property items in"
        }
        storageOfficial = person "Storage Official" {
            description "Stores property items in storage locations and hands over property items from a storage location."
            this -> storeMan "stores and hands over property items in"
        }
        storageLocationAdministrator = person "Storage Location Administrator" {
            description "Manages storage locations and assigns them to Storage Officials"
            this -> storeMan "manages storage locations in"
        }
        requestor = person "Requestor" {
            description "Creates requests for property items to use property item for a purpose"
            this -> storeMan "requests and receives property items in"
        }
        requestApprover = person "Request Approver" {
            description "Approves or declines requests for property items"
            this -> storeMan "approves requests in"
        }
    }

    views {
        systemContext storeMan "Context" {
            include *
            exclude "User"
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
        }

        theme default
    }

}