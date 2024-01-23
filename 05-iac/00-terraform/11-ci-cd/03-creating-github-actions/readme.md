# Creating GitHub Actions

The first thing we need to do is create a directory called .github in the root of our repository, and then we'll create a directory called workflows inside of that directory. GitHub looks for that specific folder and any actions defined inside of it. Next, we'll copy the GitHub Action defined in the m5 directory into the workflow directory. In this case, it's a single file called `terraform.yml` or YAML. 

Create `network_config/.github/workflows/terraform.yml`

Let's take a look at the contents of the file to see what GitHub Actions is going to be doing. 

```yml
name: 'Terraform'

on: push

env:
  TF_LOG: INFO
  TF_INPUT: false

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest

    # Use the Bash shell regardless whether the GitHub Actions runner is 
    # ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash

    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v3

    # Install the preferred version of Terraform CLI 
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2

    # Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.
    - name: Terraform Init
      id: init
      run: terraform init

    # Run a terraform fmt for push
    - name: Terraform Format
      id: fmt
      run: terraform fmt -check

    # Run a terraform validate
    # Run even if formatting fails
    - name: Terraform Validate
      id: validate
      if: (success() || failure())
      run: terraform validate
```

Starting at the top of the file, we identify the name of the action and the event that will trigger it. In our case, we're going to run the action whenever a push event occurs. Under the env section, we can set environment variables for the action.

We'll set TF_LOG to INFO to get more detailed output from Terraform, and we can set TF_INPUT to FALSE to prevent Terraform from prompting us for input. That would be bad in an automation context. 

Next, we have our jobs section. This is where we define the jobs that will be run as part of the action. In this case, we have a single job called Terraform. The job runs on the latest version of Ubuntu, and we're setting the bash shell as the default shell for this run. 

Under the steps section, we first clone the repository to the runner machine. Then we install the Terraform action using the latest version of Terraform. Then we initialize Terraform using the terraform init command, followed by running the terraform fmt command with the ‑check flag, which will return a non‑0 exit code if the code is not formatted properly. This will cause the GitHub Action to fail. 

Now we don't want it to fail immediately because we also want to run the validate command even if our formatting is bad, so we will include the if statement in our validate step and set it to success or failure. Meaning that this step will run regardless of the exit code of the previous step. Then we'll run the validate command. And if the code is valid and the formatting is good, the entire action will be successful. That'll do it for the GitHub Action. 

And next, as I mentioned earlier, we're going to remove the `backend.tf` file from the remote repository. We'll do that by first renaming it to `backend_local.tf`. As far as Git is concerned, the backend.tf file no longer exists. We'll add backend_local.tf to our gitignore file. 

```bash
mv backend.tf backend_local.tf
```

Update `.gitignore`

```diff
+backend_local.tf
```

That way we can still test things locally, but we won't have to worry about `terraform init` failing in the GitHub Action. I'll add backend_local.tf to the bottom of the gitignore file, and then I'll stage the files by running git add . 

```bash
git add .
```

Next, I'll commit the changes by running git commit with the message Add CI workflow. And if we look at the output here, we can see that a new file is being created, `terraform.yaml`, and the `backend.tf` file is being deleted from the repository. 

```bash
git commit -m "CI workflow"
```

Lastly, we'll push these changes up to the GitHub repository by running git push. 

```bash
git push
```

And once that's done, it will automatically kick off the GitHub Action. Let's go take a look and see how it's doing. Uh oh, looks like the action failed. And if we go into the action, we can see all the steps that were defined in our job, and the step that it failed on was Terraform Format. Looks like we need to fix some of the formatting. And we can do that locally, commit the changes, and push them back up. Let's head back to VS Code. Locally, I'll run terraform fmt and it looks like we had a formatting error in our variables.tf file. 

```bash
terraform fmt
```

Now we can stage the files with git add, commit them locally and add the message Fix formatting, and then lastly push those changes up to the repository. I'll copy all those commands and paste them down below. And it looks like our push has finished, so let's go back to the repository and see what happened to GitHub Actions. 

Back in the repository, I'll click on Actions to see the status of the action, and it looks like our Action is still running. I'll click on it to view the process and click on the specific job. And by the time I get there, it has finished all the checks, and it has completed successfully. Our code is formatted properly, and it is valid. Now we can move on to the next step, which is to get Terraform Cloud integrated with this whole process.