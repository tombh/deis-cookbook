# Deis Cookbook
The [opdemand/deis-cookbook](https://github.com/opdemand/deis-chef) project
contains Chef recipes for provisioning Deis nodes.
To get started with your own private PaaS, check out the
[Deis](https://github.com/opdemand/deis) project.

[![Build Status](https://travis-ci.org/opdemand/deis.png)](https://travis-ci.org/opdemand/deis)
[![Coverage Status](https://coveralls.io/repos/opdemand/deis/badge.png?branch=master)](https://coveralls.io/r/opdemand/deis?branch=master)

![Deis Graphic](https://s3-us-west-2.amazonaws.com/deis-images/deis-graphic.png)

## What is Deis?
Deis is an open source PaaS that makes it easy to deploy and scale LXC containers and Chef nodes used to host applications, databases, middleware and other services. Deis leverages Chef, Docker and Heroku Buildpacks to provide a private PaaS that is lightweight and flexible.Deis comes with out-of-the-box support for Ruby, Python, Node.js, Java, Clojure, Scala, Play, PHP, Perl, Dart and Go.  However, Deis can deploy *anything* using Heroku Buildpacks, Docker images or Chef recipes.  Deis is designed to work with any cloud provider, although only EC2 is currently supported.## Why Deis?##### Deploy anything

Deploy a wide range of languages and frameworks with a simple "git push" using [Heroku Buildpacks](https://devcenter.heroku.com/articles/buildpacks) or [Dockerfiles](http://docs.docker.io/en/latest/use/builder/).  Use custom Chef layers to deploy databases, middleware and other add-on services.
##### Control everything
Choose your hosting providers.  Define a "formation" with custom proxy and runtime layers.  Scale nodes and containers independently.  Manage the entire platform with a private Deis controller.
##### Scale effortlessly
Scale nodes and containers with a single command.  Provisioning is transparent, container formations are rebalanced automatically and proxies are updated to re-route traffic without downtime.
##### 100% Open Source
Free, transparent and easily customized.  Join the open-source PaaS and DevOps community by using Deis and complimentary projects like Docker, Chef and Heroku Buildpacks.## Getting Started
Coming Soon!

## Requirements

The Deis cookbook is designed to work with **Ubuntu 12.04 LTS**.  While other Ubuntu or Debian distros may work, they have not been tested.

#### Cookbooks

Deis depends on the following cookbooks:

- `apt` - for managing Ubuntu PPAs
- `sudo` - for managing /etc/sudoers.d

[Berkshelf](http://berkshelf.com) is used for managing cookbook dependencies.

    bundle install    # to install required gems, including berkshelf
    berks install     # to install cookbooks to the berkshelf directory
    berks upload      # to upload cookbooks to your chef server


Attributes
----------
TODO: List you cookbook attributes here.

e.g.
#### deis::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['deis']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### deis::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `deis` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[deis]"
  ]
}
```

Contributing
------------
Contributions are always welcome.  We're especially interested in contributions related to:

 * Following Chef best practices
 * Making better use of attributes
 * Improving idempotence
 * Extending OS support to other distros

To contribute:

1. Fork this repository
2. Create a named feature branch (like `add_component_x`)
3. Commit your change(s) and push them to your branch
4. Write tests for your change (if applicable)
5. Submit a Pull Request using Github

License and Authors
-------------------
Author:: Gabriel Monroy <gabriel@opdemand.com>

Copyright:: 2013, OpDemand LLC

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
