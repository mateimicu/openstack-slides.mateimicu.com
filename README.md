# OpenStack
OpenStack overview

# Speaker Notes

## What is it?
OpenStack is a open-source software that lets you create your own data center on commodity software

### How to build a data center?
Usually, you need to buy specialized hardware (most of the time the configurations must match between servers).
And Vitalization software (vSphere from VMWare for example).

But this option is quite expensive on the software side (licenses are giver per CPU/server).

Also, you are locked in VMWare word.

### What can OpenStack do?

In a typical scenario, you have multiple types of compute hardware. We will imagine the following scenario :

 - a Server that you might have (maybe a NAS, old pc ...) running Linux CentOS
 - a desktop PC running Windows 10
 - and a laptop running Linux Mint

All of them connected to a router (the laptop wireless and the others with cable).

Let's assume we want to use all of these resources simultaneously (if I want to create a new VM somewhere I should not care where it is).

#### Let's install OpenStack:
##### Install the Hypervisor
We already know the role a hypervisor has, but we don't have the money for vSphere and our bare-metal machines are not compatible with each other.
We install KVM, Hyper-V and VMWare, a separate hypervisor on each of them. But they can't communicate with each other and can't coordinate when running VM's

Also, if I manually create two VM's on different hypervisors they can't communicate easily.

##### Setup Networking
We will install Neutron that will handle networking for us, this means that if we want to create a new "interface" on one Compute Node that will communicate with another interface, the Neutron agent will take care of that.

##### Setup Nova
Nova will interact with each hypervisor (it has drivers for each of them) and will provide a common interface for them (I can issue the same request to Nova and it will handle
hypervisor specific complexity)

Now I can issue the following request to Nova:
```
Run a new VM with this settings (flavour), take the OS image from /images/ubuntu.iso or C:/images/ubuntu.iso
I also want this instances to be on the same network. (This will use the neutron agent to create interfaces on each instance that will communicate over the provided connection).
```


##### Setup Glance
The problem with the "local" OS images is that we have to copy them in the same place on every compute node.

Glance helps us with that. We upload images in Glance and when we instruct nova to run a new instance, it will get the image from Glance.


##### Setup Horizon
We are all programmers and can issue HTTP requests, but a usual cloud has a portal that will let you manage resources, this is what Horizon is, basically a website that interacts with all
of the OpenStack components, it can talk to Nova to create new instances, it can talk to glance to upload new images, it can talk to neutron to create new networks/security groups.


But because we can talk to the Horizon or the every service API, we need some kind of authentication and authorization. I don't want a new account for each service and I don't want every
service to reinvent the authentication/authorization middleware.

##### Setup KeyStone
KeyStone offers authentication when we interact with Nova, in the back Nova will ask KeyStone if the provided credentials are valid and IF the action I want to perform is allowed (authorization)

##### Let's try our OpenStack
Opening Horizon in a browser looks like this:

We can launch a new instance and specify a few settings:

- `name` and `count` allow me to have a logical name for my VM and also allow me to spawn multiple VM's with one call
- `Source` a base image to use
- `flavour` how much RAM, vCPU's and Root disk size my VM needs. Here we can note that this information is used by the nova-scheduler to decide where this VM will reside.
- `network` what "virtual" network this instance will be attached to (if I want two VM's to communicate I can attach them to the same network)
- `security groups` functions like a firewall or `iptables`. It describes from what source I accept connections and with what protocols. It manages ingress and egress rules
- `key pairs` if I want to connect to my VM I need to provide a public key that will be copied inside my VM

##### Request to Horizon
When we click `Launch Instance` all that information will get to the back-end of the horizon server

##### Horizon to Nova
Horizon will communicate with Nova and it will give it all the necessary information to spawn the new instance.

##### Nova scheduling
Nova will schedule this on one of the available Hosts based on some filters, scheduler hints  ...

##### Nova boot
Nova agent, from that specific node where the VM was scheduled to run, will get the image from Glance and communicate with the hypervisor in order to fill the request


##### Nova API
We can use the Nova API (from the CLI, nova SDK available in multiple programming languages) that accepts HTTP requests.

The process is the same, the nova master will schedule the VM, that specific nova-agent will get the image and talk with the hypervisor to boot the VM


##### Big Picture
We can image now that multiple compute nodes with this setup on them can be seen as a pool of resources 


## History
How was OpenStack made?

### Nasa Nebula
NASA had a project called Nebula that managed computer resources (a distributed hypervisor)

### RackSpace Swift storage 
RackSpace had just come out Cloud files (distributed storage similar with S3) based on Swift.

### First Release
Because of the architecture of the two projects were so aligned and Nasa already had planned to work
on storage, they started to cooperate.

In 2010 they joined forces and released the first version of OpenStack named **Austin**
NASA's project Nebula was renamed Nova, and it is in charge of Computer.
Rackspace's project Cloud Files was released as Swift in charge of object storage.

### What happened next?

- Canonical joined in 2011.
- Suse in 2011
- RedHat in 2012
- Oracle in 2013
- HP in 2014

## Architecture
How does it work? What is it made of?

### Conceptual View
Multiple components interact with each other over HTTP, they don't need to be on the same machine, they only need network access.

### Nova
It is in charge of compute (it used to handle networking in earlier versions but that functionality was extracted into Neutron)

On a high level it has the following components:

- `nova-api`
  in charge of communicating with the user/other components. This API spec is fixed and compatible with AWS EC2 API
  When a request comes to the `nova-api`, it will validate the identity by making a request to `keystone`

- `nova-compute`
  in charge of communicating with the hypervisor (kvm, hyper-v, etc ...); this is installed on each computer machine.
  It will communicate with `nova-network`

- `nova-network` runes only when the `neutron` project is not used

- `nova-scheduler` the one that decides what instance will run on what compute node 

- `nova-conductor` in charge of tasks that need coordination (downloading images from `glance`, mounting volumes from `cinder`)
  
### Neutron
Manages the networking and implements SDN (software-defined networking)

- `neutron-server` runs the networking API and interacts with the database (where the state is stored)

- `neutron-agent` runs on each compute node and manages the local network

- `neutron-dhcp` runs on the network instances and manages DHCP for every network defined

- `neutron-l3-agent` manages the routing (network layer) on every compute node. It mainly focuses on external access

- `neutron-sdn` can interact with external resources (Cisco routes that support SDN features)

# How is it made?
How is OpenStack developed?

## Open Source
All the code is open-source; it is governed by a foundation (like most big open source software) and a lot of companies are involved.

The foundation responsibility is to set common rules, organize summits and maintain tooling.

### Who is involved?
OpenStack is really flexible and you can change all the components (if the new components respect the API);
some components support drivers and plugging's.
This results in interest from a lot of vendors to add support, anything from:

- hardware producers, even if OpenStack can run on commodity hardware there is an advance to add plug-ins for bare metal hardware/servers
- networking software and hardware; some advanced networking hardware can enchant an OpenStack deployment
- support for a wide variety of operating systems (Ubuntu, RedHat, Suse, Windows)

### OpenStack contributors for the Queens release
We can see the big names in open source, cloud, like RedHat, Suse, IBM, RackSpace but we also see interesting companies like Huawei (they have a vendor-specific OpenStack for Telecom industry).

Another interesting part is `*independent` this are commits from individual people (normal people that contributed to OpenStack for various reasons).

Another good question is:**Why do those companies spend so much time and money on OpenStack, what they have to gain?**.
They have the following business model:

OpenStack is so vast and you can combine so many projects with so many drivers and software (some of the combinations are not tested) that it's too unstable to use in production.
Some companies that have influence on OpenStack, lock down the components and drivers and offer a "vendor specific OpenStack" (like RedHad with Redhat deployment of OpenStack,
like Oracle, IBM, VMWare and others that support their software solutions inside the OpenStack platform)


### How is it developed
Like any open-source project, they use something similar to GitHub (Gerrit from Google).

The flow is quite simple:

- Clone the repository to your local environment 
- Add your fix/feature
- Run unit tests 
- Push it to Gerrit (same as GitHub)
- Where things are complex is with testing. There are two fazes:
    * check - where it is checked for simple things like: does it compile, unit tests, linters and standard stuff
    * gate - only when the code review approved this commit, it goes to a gate check where every company interested in this piece of software adds and maintains testing infrastructure

**Gate testing**
If I'm Microsoft and I added support for Hyper-V in OpenStack I have the interest to keep the support there and make sure that developers don't break my driver, this is why I add to the
`nova gate testing` a faze and add and maintain CI's that ensure that this project will still work with my supervisor.


# How to install?
There are multiple ways to install OpenStack for developers

## DevStack
This is a project that will help you install in a virtual machine all the components.

## RDO (Redhat deployment of OpenStack)
This is a Redhat specific tool and it works on CentOS/RHEL; it usually offers more stability and manages to auto-configure a lot more.

## OpenStack Labs
A python project that will deploy an OpenStack for you the easy way (so you can poke around)

## Conjure-Up
Ubuntu version of Packstack using juju






# Install OpenStack
There are a few great resources that can help you with installing openstack:

- Using [DevStack](https://wiki.openstack.org/wiki/DevStack) you can follow [this video](https://www.youtube.com/watch?v=qgQARDfVrs8&)
- Using [RDO](http://rdoproject.org/) on [VirtualBox](https://www.virtualbox.org/) you can follow [this blog post](http://mateimicu.com/posts/install-openstack-rdo)
- Using [OpenStack Labs](https://github.com/openstack/training-labs) you can follow [this blog post](http://mateimicu.com/posts/install-openstack-labs/)
- Using [Conjure-Up](https://conjure-up.io/) you can follow the [official docs](https://www.ubuntu.com/download/cloud/try-openstack)




# Bibliography

- [OpenStack Wikipedia](https://en.wikipedia.org/wiki/OpenStack)
- [Nebula Wikipedia](https://en.wikipedia.org/wiki/Nebula_(computing_platform))
- [RackSpace Wikipedia](https://en.wikipedia.org/wiki/Rackspacek)
- [Austin Release Nones](https://wiki.openstack.org/wiki/ReleaseNotes/Austin)
- [OpenStack foundations](https://www.openstack.org/foundation/)
- [Stackalitics](stackalytics.com/)
- [OpenStack development](https://docs.openstack.org/infra/manual/developers.html)
