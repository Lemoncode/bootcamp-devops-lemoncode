# Create User

When we sign up to AWS for the first time a new root user is created. This root user, is a kind of God inside our account. The recommendation, it's avoid its use unless under extraordinary circunstacnces. So the first thing that we're going to do is create a new user, with fully administartor rights to deal with AWS.

## Create a User Group

> TODO: Create a user group with administrato access

## Accessing to IAM and Creating a User

From AWS console, search for `IAM` services

[IAM access](./.resources/01-iam.png)

Now that we're on `Identity and Access Management` service, select users:

[users selection](./.resources/02-users.png)

Click on `Create user`

Let's create a new user:

1. As name we're going to use `devops-reviewer`
2. Ensure that we grant access to AWS console.
3. Select `I want to create an IAM user`

[creaete user 1](./.resources/03-create-user-1.png)

As long as we're creating a new user with console access we need to provide a `password`. On real life, you will want that this is a one shot time password, but we're on demo time so check `Custom password` and deselect `User must create a new password at next sign-in`

[creaete user 1](./.resources/04-create-user-2.png)

Click on `Next`

Now we need to set up the permissions for the new user, in our case we're going to select `Add user to group` and check `admins`:

[user group](./.resources/05-user-group.png)

Click on `Next`

Lets have a look and check that everything looks good:

[review](./.resources/06-review.png)

Click on `Create user`. For last a summary page is shown to us, where we can see all our settings.
