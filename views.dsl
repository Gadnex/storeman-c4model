views {
    properties {
        "mermaid.url" "https://mermaid.ink"
        "mermaid.format" "svg"
    }

    systemContext storeMan "Context" {
        include * systemAdministrator
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

    deployment storeMan localDevelopment "DevelopmentEnvironment" {
        include *
    }

    deployment storeMan production "ProductionEnvironment" {
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