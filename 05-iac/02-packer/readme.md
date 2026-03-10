# Creating Basic Images

## Packer Basics

So, how does Packer work? Well, Packer uses these files called `templates`, which let you _define what your immutable infrastructure will be like_. They're written in a language called `HCL2`, or _HashiCorp Configuration Language 2_. If you've ever worked with Terraform, the syntax is very similar. Let's have a look at each part of this template.

```ini
source "type" "name" {

}

build {
    sources = ["source.type.name"]

    provisioner "name" {
    }

    post-processor "name" {

    }
}
```

First off, you have _sources_. You can define any number of these. They set up all the configuration necessary to tell Packer where to build the image, for example, on an EC2 instance via EBS or in a VirtualBox VM.

Then, you have one or more build blocks. You can think of these like units of execution for Packer. When you run Packer to create images, you tell it which build it needs to run. The build either refers to one or more sources, or it can have those sources defined in line. This is how we link the Packer command you run to the location where the image should be built.

Then we have any number of provisioners. We'll get into this later in the course, but these are your entry points that allow you to provide configuration to your image, for example, via `Ansible` or a shell script.

Finally, we have post‑processors. You can think of these as transformers for your final image, for example, to zip up a VirtualBox OVA or to calculate a checksum. Let's have a look at a more detailed example of each of these basic parts.

### Sources/"Builders"

```ini
source "amazon-ebs" "ubuntu-ami" {
    access_key = ""
    secret_key = ""
    subnet_id = ""
    region = "us-east-1"
    ami_name = "my_ami"
    instance_type = "t2.micro"
    source_ami = "ami-0dea0044"
    communicator = "ssh"
    ssh_username = "ubuntu"
}
```

- Where should image be created?
- Configuration specific to locaction
- Communicator - how does Packer talk to build process?

First, sources often referred to in Packer's documentation as builders. As I said before, sources define where you want the image to be built. The first line has two arguments. The first is the type, which in this case is amazon‑ebs. This is telling Packer that we want to build an Amazon machine image using the Elastic Block Store‑backed option. There are numerous types documented on Packer's website that cover pretty much every image‑based build location you can think of. 

The second argument is the name. In HCL2, to you can use this name to refer to the source in other places such as the build configuration. Now sources will always contain configuration that is specific to your build location. 

In this case, we need to provide Packer with data like the access key and secret key to talk to AWS, what region we should build the AMI in, what size of instance we should build with, and so forth. Other source types will have their own necessary configuration. For instance, VirtualBox requires information about what source ISO should be loaded to build the image from. 

One mandatory part of every source definition is the `communicator`. This tells Packer how it should be accessing the image that is created in order to do things like run your provisioners and properly clean an image before it's captured. If you're creating a Linux image, as we are here, most of the time, this will just be set to `SSH`, which is the default. As a result, we also need to know the SSH username to connect as. Packer deals with setting up secure keys for communicating with the box automatically, so you don't need to worry about that. If you are building a Windows image, there's an option to use WinRM for a communicator as well. 

### Build

```ini
build {
    name = "mybuild"
    sources = ["source.amazon-ebs.ubuntu-ami"]
    provisioner "type" {
    }
    post-processor "type" {
    }
}
```

- Combine sources with provisioning/post-processing
- Multiple sources == multiple images output at once!
- Named - separate builds if needed

Now let's look at the build block. Build blocks are just containers that bring together one or more sources, provisioners, and post‑processors into a single unit of execution for Packer, as I mentioned. You can refer to sources you've already created, as I show here, using the HCL2 syntax `source.type.name`. 

Each build block can have multiple sources if you want, which lets you generate multiple images at the same time with the same configuration applied to them via your provisioners and post‑processors. 

You can also set a name for each build. When you're running Packer, you can specify that you'd like to run only builds with a certain name or all builds except a certain name. This can come in handy if, for example, you need to build different images with different configuration at different times like building your application's production image once a week, but building the development image every day. 

### Provisioners

```ini
provisioner "shell" {
    script = "server.sh"
    only = ["amazon-ebs.ubuntu-ami"]
}
```

- Customize your image
- Scripts or configuration management
- Can be source-specific

Provisioners are where the meat of the setup of your infrastructure goes. They're how you customize your image, making sure that your application is deployed there and running in an immutable state with everything it needs. 

This is generally done via scripts or some form of configuration management like `Ansible`, Puppet, Chef or Salt. The type of provisioner you'll use is the first argument in the provisioner's definition. In this case, we're using the shell‑type provisioner, which runs the script present on our image. We likely would've used a file‑type provisioner to upload that script onto the image, first. 

Each provisioner in your build is run sequentially in the order that they're written in your file. These provisioners can be made source‑specific with the only argument. Usually, you do this to prevent some sort of configuration that is specific to the place you're building your image being applied everywhere. For example, you might have a script that retrieved some instance metadata from the EC2 metadata endpoint. There would be no use in running that on VirtualBox as a source, as the metadata endpoint doesn't even exist there. 

### Post-processors

```ini
post-processor "checksum" {
    checksum_types = ["md5", "sha512"]

    keep_input_artifact = true
}

post-processor "amazon-import" {

}
```

- Transform build outputs
- Integration with other services
- Can be cahined together via post-processors block


Finally, post‑processors. You use these to put the finishing touches on your image, for example, calculating a checksum for future verification of that image, compressing the image or sending it somewhere. In general, you use them to transform your build outputs into something else. 

In this case, you can see that we've got two post processors. The first one calculates the checksum of our image and crucially sets `keep_input_artifact` to true, which tells Packer that you don't just want to calculate a checksum and delete the original image, you also want to keep that image. This is definitely something to be aware of. 

The second post‑processor imports the image into AWS as an AMI. You can do this from an OVA file for VirtualBlock, for example. As you saw, post‑processors also let you integrate with other services, for example, the AMI import shown there or converting an image to a vagrant box or tagging and uploading Docker images. 

These post‑processors can be chained together if you want via post‑processors block, allowing you to serialize their execution and pass the output from one post‑processor into another. For example, you might use a post‑processor to compress the image and then a second one to calculate the checksum of the resulting compressed file. It can get pretty advanced and a bit confusing if you want it to. 

### Using Packer

So once you've got this file together, how do you actually use Packer? 

```bash
packer fmt template.pkr.hcl

packer validate template.pkr.hcl

packer build template.pkr.hcl

packer build -debug

packer build -var
packer build -only
packer build -on-error
```

Well, it's a command line tool, so let's go over the most common commands that you'll be running. First off is `packer fmt`, or `packer format`. `HCL2` has an extremely well‑defined rule set for formatting, and running this command will change your files such that it's formatted according to those rules. I personally love this functionality when working in a team setting, as it makes any arguments about line breaks, tabs, other formatting things, and so on completely irrelevant. According to HashiCorp, there's exactly one way to write HCL2. 

Next up is `packer validate`. You can think of this like a linting operation if you were developing code in Python or the like. Packer will check over your template to ensure the syntax is valid and that the configuration generally makes sense as far as Packer can tell. It's not smart enough to tell you, for example, that the AMI you set as your source AMI doesn't exist anymore, but if you forget to include any sources with your builder, for example, it will speak up. Running this command in the CI pipeline is a great way to make sure nothing is broken before you commit to building an image, which can sometimes take a little while. 

Finally, we've got what's really the main command for Packer, and that is `packer build`. This is how you kick off the creation of the image that you've so carefully defined in your template. There are a number of useful flags to this command, and one I wanted to highlight right off the bat is the `‑debug` flag. This flag makes Packer pause after every step of the image build process. That includes pausing after each provision runs and after each post‑processor runs. On top of that, when you run build with this flag, Packer will drop the SSH key that it created to access the image into the directory where you ran the command. The end result, you can `SSH` into your image while it's being built to check that everything is working correctly. We'll be using this flag a bunch when we start building an image here. 

There are a bunch of other very useful flags for packer build, but we'll get into those later on.

## Demo: Installing Packer

[Demo: Installing Packer](./01-installing-packer/readme.md)
