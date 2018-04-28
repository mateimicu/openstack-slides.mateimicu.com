# OpenStack
OpenStack overview

# Speaker Notes


## History
How was OpenStack made ?

### Nasa Nebula
NASA had a project called Nebula that managed computer resources (a distributed hyper visor)

### RackSpace Swift storage 
RackSpace had just come out Cloud files (distributed storage similar with S3) based on Swift.

### First Release
Because of the architecture of the two projects were so aligned and Nasa already had planned to work
on storage they started to cooperate.

In 2010 they joined forces and released the first version of OpenStack named **Austin**
NASA's project Nebula was renamed Nova, and it is in charge of Computer.
RacksSpace's project Cloud Files was released as Swift in charge of object storage.

### What happened next ?

- Canonical joined in 2011.
- Suse in 2011
- RedHat in 2012
- Oracle in 2013
- HP in 2014

## Architecture
How it works ? What is it made of ?

### Conceptual View
Multiple components interact with each other over HTTP, they don't need to be on the same machine they only need network access.

### Nova
It is in charge of compute (it used to handle networking in earlier versions but that functionality was extracted into Neutron)

On a high level it has the following components:

- `nova-api`
  in charge of communicating with the user/other components. This is the API spec is fixed and compatible with AWS EC2 api
  When request comes to the `nova-api` it will validate the identity making a request `keystone`

- `nova-compute`
  in charge of communicating with the hyper visor (kvm, hyper-v, etc ...) this is installed on each computer machine.
  It will communicate with `nova-network`

- `nova-network` runes only when the `neutron` project is not used

- `nova-scheduler` the one that decides what instance will run on what compute node 

- `nova-conductor` in charge of tasks that need coordination (downloading images from `glance`, mounting volumes from `cinder`)
  
### Neutron
Manages the networking and implements SDN(software define networking)

- `neutron-server` runs the networking API and interacts with the database (where the state is stored)

- `neutron-agent` runs on each compute node and manages the local network

- `neutron-dhcp` runs on the network instances and manages DHCP for every network defines

- `neutron-l3-agent` manages the routing (network layer) on every compute node. It mainly focuses on external access

- `neutron-sdn` can interact with external resources (cisco routes that support SDN features)







# Bibliography

- [OpenStack Wikipedia](https://en.wikipedia.org/wiki/OpenStack)
- [Nebula Wikipedia](https://en.wikipedia.org/wiki/Nebula_(computing_platform))
- [RackSpace Wikipedia](https://en.wikipedia.org/wiki/Rackspacek)
- [Austin Release Nones](https://wiki.openstack.org/wiki/ReleaseNotes/Austin)
