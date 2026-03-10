# Demo: Installing Packer

Installing Packer is quite an easy process with some differences depending on the operating system you're running. It all starts with heading to [packer.io/downloads](https://developer.hashicorp.com/packer/install). As you can see, the site automatically detects your operating system and shows you the appropriate installation procedure. I'm on Ubuntu, but I could always click on any of the other tabs to see how to install it on other operating systems. 

For Ubuntu, the installation procedure is relatively simple, as you can see. We'll be adding an apt repository for Packer and then installing it via `apt‑get`. Just for reference, let's look at some other common operating systems. 

For macOS, I'd highly suggest installing via `Homebrew`. It makes it much simpler to stay up to date. Packer and most HashiCorp tools change quite frequently, so keeping up is a very good idea. 

For Windows, unfortunately, you'll only have one option, which is to download the binary. Packer doesn't provide, for example, an MSI installer, so you'll have to make sure you put the binary somewhere on your path. 

Let's go back to our operating system. And we're going to bring up a terminal here and just run these commands one by one. 

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer
```

The first one just grabs the public key from Packer's apt repository so that apt can verify the version we'll download of Packer is real and not just some malicious fake. The second one adds the apt repo where Packer is located. And finally, we update our list of packages from the new repository and install Packer. Now if we run a quick packer command, we can see that it's installed. 

```bash
packer --version
```

Perfect! Now we can move on to actually creating an image.