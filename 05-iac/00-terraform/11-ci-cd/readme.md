# Building a CI/CD Workflow

## Creating GitHub Repository

Primero, crearemos un repositorio de GitHub para almacenar nuestro código. Puedes hacer esto directamente en el sitio web de GitHub, pero en su lugar usaremos Terraform. Los archivos de Terraform para crear el repositorio de GitHub se encuentran en el directorio `github_config`.

Una cosa que necesitaremos para crear este repositorio de GitHub son las credenciales para hablar con nuestra cuenta de GitHub, y lo haremos obteniendo un token de acceso personal. Puede crear un token de acceso personal a través de la configuración de su cuenta en GitHub. Vayamos a GitHub y repasemos este proceso.

[Demo: Creating GitHub Repository](./01-creating-github-repository/readme.md)

## Initializing Git

[Demo: Initializing Git](./02-initializing-git/readme.md)

## Terraform Automation Considerations

### Automation Considerations

Cuando utiliza `source control` y ejecuta la automatización en Terraform, hay algunas cosas que debe tener en cuenta.

`.gitignore` El predeterminado de GitHub incluye cosas como ignorar el directorio `.terraform` y el estado `terraform.tf`, entre algunas otras cosas. Es posible que desee agregar `terraform.tfs` o cualquier otro archivo que contenga información confidencial a esa lista.

Another file to consider is the provider lock file, also known as `.terraform.lock.hcl`, which contains the version of provider plugins used when Terraform was initialized. When the repository is cloned and Terraform is initialized, it will use the versions specified in that file, giving a consistent experience across all users and build servers. You can choose to omit the file from source control, but then you'll have to deal with versioning of plugins yourself.

Speaking of Terraform initializing itself, Terraform will download provider plugins from a remote location each time you initialize a new configuration. If you're using a build server with persistent storage, it might be worth caching plugins locally to speed up the initialization process. You can do this by setting the `TF_PLUGIN_CACHE_DIR` environment variable to a directory on the build server.

When you're running Terraform in automation, it still needs credentials to be able to access remote state and each provider in your configuration. How you choose to provide those credentials will depend on the build system. Generally, dynamic credentials or a machine identity is preferred. Although in our scenario, we'll be using static credentials for AWS.

Another thing to think about is terminal output control. Terraform can be pretty chatty. I'm sure you've noticed as we've run, plan, apply, and initialization, it produces a decent amount of output. And for the most part, that's fine. But sometimes that can mess up scripting, so there's an environment variable called `TF_IN_AUTOMATION` that can help you reduce the amount of output and chattiness of Terraform by letting it know that there isn't going to be a human being watching the output.

Next, we need to consider the deployment pattern to follow when using automation. Our pattern so far has mostly been to initialize, plan, and apply. There are a couple of things to consider when it comes to automation. Do you save the execution plan in a file or run a new execution plan with the apply command? Once a plan is successfully generated, do you want someone to manually review that plan before it's applied in the environment? In production, I'd say you probably do. In development, maybe not. So you may make the decision to enable continuous deployment.

The last thing is error handling. How do you want to handle things if the process errors out? Is that the end of the pipeline or does it continue on? And if there is an error, how are you going to log it appropriately? Terraform Cloud and GitHub Actions are pretty good about capturing the error output and logging it, but other automation platforms might not be as good at doing that, and you may want to store those logs somewhere else. You can control logging level and destination with environment variables. In fact, let's talk about some of the environment variables that Terraform offers to help you with the automation process.

- Files to exclude from source control
  - .gitignore
- Provider lock file
  - .terraform.lock.hcl
- Plugin caching
  - TF_PLUGIN_CACHE_DIR
- Backend and provider credentials
- Terminal output control
  - TF_IN_AUTOMATION
- Deployment process
  - Save execution plan?
  - Enable continous deployment?
- Error handling
  - Continue or cancel
  - Log storage
  - Log level

## Environment Variables in Terraform

### Automation Environment Variables

When you're kicking off an automation, it is fairly common to express desired settings and values with environment variables, as we'll see with GitHub Actions. Terraform supports a vast number of environment variables, and sometimes it can get a little bit confusing. Some of them are specific to automation, and I wanted to highlight those now.

The first one I already mentioned, it's called `TF_IN_AUTOMATION`. And if it's set to any value, it doesn't have to be the string TRUE. If you set it to any value, it lets Terraform know it's working in an automation context.

Another thing you're probably going to want to configure is the logging level of Terraform to something like information or possibly even higher. Because if something does go wrong, you're not there to see it. The levels include `ERROR`, `WARN`, `INFO`, `DEBUG`, and `TRACE`. `TRACE` is the highest and should really be reserved for Terraform binary bug troubleshooting.

Along with `TF_LOG` is `TF_LOG_PROVIDER`, which controls the logging level of the provider plugin separately from core Terraform. If you suspect there's an issue with the Terraform binary and not a provider, you could set `TF_LOG` to `TRACE` and `TF_LOG_PROVIDER` to `ERROR` to reduce the noise in the logs.

Many of the automation platforms capture all the output from the terminal level, but you can also instruct Terraform to log to a specific path using `TF_LOG_PATH`. The environment variable needs to be set to an actual file and not a directory, so you'll need some other utility to manage and archive log files.

The next one is an environment variable called `TF_INPUT`. If that's set to FALSE, Terraform will not prompt the end user for input. Instead, it will just error out. For instance, if you're running terraform plan with a missing variable value, instead of just sitting and waiting for you to provide the missing values in the terminal, Terraform will simply error out.

Another useful one, and this is not specific to automation, though I do think it's helpful, is if you create an environment variable named `TF_VAR_`, the name of the variable in the Terraform configuration, Terraform will see that, and use that value in the configuration. So it's a really easy way to pass a variable value without adding it to the command line.

`TF_CLI_ARGS` is used to define command line arguments you want to be expressed every time you run Terraform. This is good for options like no color, which is sometimes required on systems that don't do well with color‑coded output.

```bash
TF_IN_AUTOMATION = TRUE

TF_LOG = "INFO"

TF_LOG_PROVIDER = "ERROR"

TF_LOG_PATH = "FILE_PATH"

TF_INPUT = FALSE

TF_VAR_name = "VALUE"

TF_CLI_ARGS = "COMMAND_FLAGS"
```

With all that in mind, let's move on to the first automation piece we're trying to add, GitHub Actions for continuous integration.

## GitHub Actions

GitHub Actions are workflows that are triggered by events in GitHub. They can be triggered by things like a pull request, a commit being pushed to a branch, or a new release being created. The actions are defined in a YAML file that lives in the `.github/workflows` directory of your repository. Actions can include things like running a script, executing Terraform commands, or building a Docker image.

We are going to copy the GitHub Actions defined in the m5 GitHub Actions directory into our repository, and then we'll push those changes up to GitHub. Now what would we want to check when code is pushed into GitHub?

Well, we probably want to make sure that the code is valid and maybe that it has been formatted properly. Terraform has the validate and fmt commands that can help us out with that.

And one problem is that in order to run terraform validate, we have to first initialize Terraform. And since we have our backend set to Terraform Cloud, the GitHub Action would need to be able to authenticate to Terraform Cloud.

That seems unnecessary to just validate the code. And, in fact, we won't need that backend file anymore once we set up the CD process, so we're going to remove it. Now let's head back to Visual Studio Code and create our GitHub Action.

- Triggered on event schedule
- Included with repository
- Library of actions available
- What to check?
  - Formatting and validity
- Need to initialize Terraform

## Creating and Using GitHub Actions

[Demo: Creating and Using GitHub Actions](./03-creating-github-actions/readme.md)

## Terraform Cloud Integration

[Demo: Terraform Cloud Integration](./04-cloud-integration/)

## Putting it All Together

We've added a lot of moving pieces, so let's step back for a moment to see how they all work together to apply a potential change to our code. 

Globomantics has some changes they'd like to make to the existing environment. They'd like to add a third public subnet, and they'd like to add a tag to all network resources, a billing code. We're going to make some adjustments to the code and to Terraform Cloud to support this change. 

- Requested changes
  - Add a third public subnet
  - Add tag for billing code

> TODO: Add picture

First, let's walk through the process, and the process starts by creating a new branch in our local repository. We'll call it `add‑third‑subnet`. Then we'll make changes to the code. We can add the billing code tag by creating a new variable called billing code and adding the tag to the local common tags. We'll assign the billing code variable value at the workspace level in Terraform Cloud. And while we're there, we can add a third subnet by changing the value for the public‑subnets variable. The next step is to commit our changes to our branch and push them to the remote repository. 

This will create a new branch there and also trigger our GitHub CI Action to check for formatting and validity. Assuming those checks pass, **we can create a pull request to merge the changes into the default branch**. This **will trigger a speculative plan in Terraform Cloud**, which will show us what changes will be made if we merge the pull request. 

If we're not happy with what we see, we can make changes locally, commit and push them to the remote branch, and the GitHub Actions and speculative plan will be run again. Assuming we're happy with the change, we can merge the change into the default branch. This will trigger a `plan` and `apply` run in Terraform Cloud. Now since we picked a manual apply, it will pause after the plan is done and wait for us to approve the plan. Once we approve it, Terraform will apply the changes to the networking environment. Lastly, we will pull the merge changes down to our local repository and delete the feature branch. That's the overall workflow. Now let's see it in action.

## Updating the Code

[Demo: Updating the Code](./05-updating-code/readme.md)

## Creating a Pull Request

[Demo: Creating a Pull Request](./06-creating-pull-request/readme.md)

## Summary

In this module, we took the next step in our Terraform journey by making the process truly collaborative and removing the single point of failure that was our local workstation. 

We started by creating a repository in GitHub and moving our code there. 

Then we added a GitHub Actions workflow to check formatting and validate the code. 

Next, we took our existing workspace in Terraform Cloud and connected it to the repository. That set up a workflow that would run a speculative plan on a pull request and a plan and apply on a merge. The process we just set up is fantastic for a single environment. 

But how do you handle multiple environments? In the next module, we're going to cover a few different options and implement them using GitHub and Terraform Cloud.
