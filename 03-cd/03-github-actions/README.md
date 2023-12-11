# Github Actions

## Demos starting point

You will find the needed code for the demos in [.start-code](./.start-code) folder.

## What is Github Actions?

GitHub Actions is a continuous integration and continuous delivery (CI/CD) platform that allows you to automate your build, test, and deployment pipeline. You can create workflows that build and test every pull request to your repository, or deploy merged pull requests to production.

GitHub provides Linux, Windows, and macOS virtual machines to run your workflows, or you can host your own self-hosted runners in your own data center or cloud infrastructure.

### Components

- **Workflows**: a workflow is a configurable automated process that will run one or more jobs. Workflows are defined by a YAML file stored in the `.github/workflows` directory in a repository. It will run when triggered by an event in your repository, or they can be triggered manually, or at a defined schedule.
- **Events**: an event is a specific activity in a repositoru that triggers a workflow run. For example, when someone creates a PR, opens an issue or pushes a commit.
- **Jobs**: a job is a set of steps in a workflow that is executed on the same runner. Each step is either a shell script that will be executed or an action that will be run. Jobs may have dependencies with other jobs (or not) and run in parallel with others.
- **Actions**: an action is a custom application for the GitHub Actions platform that performs a complex but frequently repeated task. It helps you to reduce repetitive code in your workflow files. An action can pull your git repository from GitHub or set up the authentication to your cloud provider. You can write your own actions, or you can find actions to use in your workflows in the GitHub Marketplace.
- **Runners**: a runner is a server that runs your workflows when they're triggered. Each runner can run a single job at a time. GitHub provides Ubuntu Linux, Microsoft Windows, and macOS runners to run your workflows.

## An example workflow

```yaml
# Optional - The name of the workflow as it will appear in the "Actions" tab of the GitHub repository. If this field is omitted, the name of the workflow file will be used instead.
name: CI

# Specifies the trigger for this workflow. In this case, the workflow will be trigger when a PR is opened to main or when commits are pushed into main.
on:
  push:
    branches:
      - "main"
  pull_request:
    branches: [ main ]

# Groups together all the jobs that run in this workflow.
jobs:
  # Defines a job named 'audit'
  audit:
    # Configures the job to run on the latest version of an Ubuntu Linux runner. Jobs can be run in self-hosted runners too.
    runs-on: ubuntu-latest

    # Groups together all the steps that run in the 'audit' job. Each item nested under this section is a separate action (uses) or shell script (run).
    steps:
      - name: Checkout 
        uses: actions/checkout@v4
      - name: Inspect machine
        run: | # This '|' symbol allows to write several commands
          ls -al
          whoami
          pwd
          node -v
```

## About billing for GitHub Actions

GitHub Actions is free for public repositories. For private repositories, each GitHub account receives a certain amount of free minutes and storage for use with GitHub-hosted runners, depending on the account's plan.

### Included storage and minutes

| **Plan**         | **Storage** | **Minutes (per month)** |
|------------------|-------------|-------------------------|
| Free             | 500 MB      | 2000                    |
| Pro              | 1 GB        | 3000                    |
| Team             | 2 GB        | 3000                    |
| Enterprise Cloud | 50 GB       | 50000                   |

Jobs that run on Windows and macOS runners that GitHub hosts consume minutes at 2 and 10 times the rate that jobs on Linux runners consume. For example, using 1,000 Windows minutes would consume 2,000 of the minutes included in your account. Using 1,000 macOS minutes, would consume 10,000 minutes included in your account.

### Per-minute rates

| **vCPUs (on Linux machine)** | **Per-minute rate (USD)** |
|------------------------------|---------------------------|
| 2                            | $0.008                    |
| 4                            | $0.016                    |
| 8                            | $0.032                    |
| 16                           | $0.064                    |
| 32                           | $0.128                    |
| 64                           | $0.256                    |

### Usage limits

There are some limits whe using GitHub-hosted runners.

| **Plan**         | **Total concurrent jobs** | **Maximum concurrent macOs jobs** |
|------------------|---------------------------|-----------------------------------|
| Free             | 20                        | 5                                 |
| Pro              | 40                        | 5                                 |
| Team             | 60                        | 5                                 |
| Enterprise Cloud | 1000                      | 50                                |

## References

- [Understanding Github Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions)
- [Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [About self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)
- [About billing for GitHub Actions](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions)
- [Pricing calculator for GitHub Actions](https://github.com/pricing/calculator?feature=actions)
