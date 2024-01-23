# Initializing Git

Just like Terraform, preparing a Git repository for use starts with the git init command. In fact, feels like Terraform kind of stole its terminology from tools like Git. The init command initializes a Git repository in the current directory. Before you run the git init command, make sure that you're in the `network_config` directory. 

```bash
cd ./.lab/network_config
```


I'm already in there, so I'll copy and paste this command down below. 

```bash
git init --initial-branch=main
```

We're specifying an additional flag here, which is initial‑branch=main. That will set the default branch for this repository. Now before we add files to our repository, we first want to ignore some of the files that we have in this working directory. Stuff like what's in the .terraform directory. We don't want to commit that. I have an example gitignore file that's in the m5 directory that ignores those types of files, so we are going to copy that example file into the `network_config` directory with the file name .gitignore. 

Create `./.lab/network_config/.gitignore`

```ini
#  Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# .tfvars files
*.tfvars

# .tfplan files
*.tfplan

# .pem files
*.pem
```

Now we're ready to add files to the Git repository, and we do this with the git add command, with a space and then a period at the end, which gets all of the files and directories in the current working directory. I'll go ahead and run that now. 

```bash
git add .
```

If you're working on a Windows machine, you may get a warning about the carriage return line feed versus line feed. It is safe to ignore that error. Next, we are going to commit our files to the Git repository by running git commit with ‑m, which is the message to associate with the commit, and set it to Initial commit. 

> NOTE: You need to set up your Git user config

```bash
git config --global user.email "jaime.salas@lemoncode.net"
git config --global user.name "Jaime Salas"
```

```bash
git commit -m "Initial commit"
```

At this point, we've committed our files, and the last thing to do is push those files up to the remote repository. 

We'll use the git remote add origin command and specify the ORIGIN_URL of the GitHub repository that we recently created. If you didn't copy that URL from earlier, you can go back to the github_config directory and run `terraform output` to see what the remote URL is. 

```bash
git remote add origin "https://github.com/JaimeSalas/globo-networking.git"
```

Now that we've created the link between our local repository and the remote or origin repository, we are going to use git fetch to fetch the information about that remote repository. 

```bash
git fetch
```

Now that Git knows about our remote or origin repository and the branches it contains, we can set our local main branch to track the origin main branch up in the GitHub repository. 

```bash
git branch --set-upstream-to=origin/main main
```

And finally, we are going to force push our code up to GitHub. Because there's already some code up there, some initialization files, we need to overwrite everything that's there, and that's why the ‑‑force flag is added. 

```bash
git push origin --force
```

At this point, you might be prompted for your GitHub username and personal access token if you haven't set up the Git CLI before. You may be also prompted to set your username and email address. There's a link in the exercise resources that will walk you through that process. And that's it. If we head over to GitHub, we can see the new repository with our code in it. I'll click on my account and select repositories from the list. And because it's sorted by most recent commit, globo‑networking should come up as the first repository. Clicking into the repository, there are all the files that we pushed from our local workstation. Now we can create our GitHub Action to run our CI process. But first, we need to take a moment to review some considerations when using Terraform in a version‑controlled setting that leverages automation.