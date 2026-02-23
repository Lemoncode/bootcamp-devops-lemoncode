# Using Terraform Cloud for State

Let's go back to Visual Studio Code and update our state configuration to use Terraform Cloud. In the m4 directory is a backend.tf file. We're going to copy that file to the network_config directory and update some properties. Let's do that now. 

Create `network_config/backend.tf`

```ini
## Move this backend file to your network config when migrating state
terraform {
  cloud {
    # Organization ID
    organization = "ORGANIZATION_NAME"
    # Workspace ID
    workspaces {
      name = "web-network-dev"
    }
  }
}
```

I'll copy the command to copy the file and paste it down below, and run it. Now that the file is copied over, we are going to update the organization name to the organization created earlier. I'll expand out network_config and open up the backend.tf file. My organization name is deep‑dive‑globo. Go ahead and update yours based on the one you created. For the workspace name, we will leave it as web‑network‑dev. That'll do it for the updated backend configuration. 

Update `network_config/backend.tf`

```diff
terraform {
  cloud {
    # Organization ID
-   organization = "ORGANIZATION_NAME"
+   organization = "bootcamp-jsz"
    # Workspace ID
    workspaces {
      name = "web-network-dev"
    }
  }
}
```

Each workspace in Terraform Cloud maps a configuration to a target environment, and the state data of each workspace is separate from all other workspaces, so you can have a workspace for each environment you want to manage. We'll talk more about workspaces later in the course when we deal with supporting multiple environments. Now how do we migrate our state data to Terraform Cloud? That's incredibly easy.