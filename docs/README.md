# Probium

Probium is a Ruby based CLI tool that uses the Puppet RAL (and a bit of extra magic)
to report on the state of a system defined by a set of policies. Policies are data,
expressed as either YAML or JSON, that define the desired state of certain resources.

Use and extend it to create reports for something as simple as validating the state of
listening ports on a system to testing models as complex as PCI compliance.

## Installation


### Rubygems

```shell
$ gem install probium
```

### Source
```shell
$ git clone git@github.com:ploubser/probium.git
$ gem build probium.gemspec
$ gem install probium-0.0.1.gem
```

You can confirm that your installation was successful by running

```shell
$ probium --help
Usage: probium my_policy.yaml [options]
    -o, --output-format=FORMAT       Format in which to display policy report (graphic, json, yaml, csv)
    -e, --extension-dir=PATH         Location of extension files
    -d, --debug                      Enable debug output
        --no-color                   Disable color in output
    -h, --help                       Print this help
```


## Policies

Policies are the core constructs of Probium. They are expressed as hashes with the following keys:

- **name** `String` (required) - The policy name.
- **confine** `{String : String}` (optional) - Pairs of factname : value that will cause to policy to only be run
  if the values match those of the system it is being run on.
- **rules** `[Rule]` (required) - The set up rules that make up a policy. We will describe them in the next section.

## Rules

A rule describes a system state that must be true. There can be many rules for one policy.
Rules are expressed as hashes with the following keys:

- **description** `String` (required) - A short description of the rule.
- **severity** `String` (optional) - An optional value that expresses the importance of the rule being followed.
- **resources** `{String : Resource}` (required) - The resources and that states that must be true if the rule is to be followed.

## Resources

Resources represent the live state on the system being inspected. Resources in Probium closely resemble resources
in Puppet and are expressed as follows:

```
ResourceType['title'] => properties
```

YAML example:

```yaml
:File['/tmp/foo']:
  :ensure: present
  :group: "0"
  :mode: "0644"
```

## Resource Extensions

Sometimes we care about the state of something that isn't a Puppet resource. Probium uses resource extensions to
create new resource types and modify existing resources.

Currently Probium has the following resource extensions:

- [port](extensions/port.md)

## Putting it all together

Let's start by creating a simple policy. First we create a policy file and add a single rule.

```yaml
:name: Weyland Corp Compliance policy 4000
:rules:
  - :description: /etc/sudoers is secure
```

We can now add a resource to our rule. In this example we care about the state of the /etc/sudoers file.

```yaml
:name: Weyland Corp Compliance policy 4000
:rules:
  - :description: /etc/sudoers is secure
    :resources:
      :File['/etc/sudoers']:
        :ensure: present
        :mode: "0440"
        :group: 0
        :owner: 0
```

Now if we save this file as `weyland_compliance_policy.yaml` we can use probium to check it.

```shell
$ sudo probium weyland_compliance_policy.yaml
Total Policies: 1

Policy: Weyland Corp Compliance policy 4000

    Description: /etc/sudoers is secure
        File['/etc/sudoers']
            ensure: present -> file
            mode: 0440 -> 0440
            group: 0 -> 0
            owner: 0 -> 0

Passed: 1/1
```

##### Note - Probium may be privilege sensitive.  If you want to inspect the state of a resource, and that inspection requires root privilege, then you need to run Probium as root.

Now let's add a slightly more complex rule. We now also care that the telnetd service isn't present and that
it's default port is closed.

```
:name: Weyland Corp Compliance policy 4000
:rules:
  - :description: /etc/sudoers is secure
    :resources:
      :File['/etc/sudoers']:
        :ensure: present
        :mode: "0440"
        :group: 0
        :owner: 0
  - :description: Telnet isn't running and it's port is closed
    :resources:
      :Service['telnetd']:
        :ensure: absent
      :Port['23']:
        :open: false
```

We can now run the policy the same as we did previously.

```shell
$ sudo probium weyland_compliance_policy.yaml
Total Policies: 1

Policy: Weyland Corp Compliance policy 4000

    Description: /etc/sudoers is secure
        File['/etc/sudoers']
            ensure: present -> file
            mode: 0440 -> 0440
            group: 0 -> 0
            owner: 0 -> 0

    Description: Telnet isn't running and it's port is closed
        Service['telnetd']
            ensure: absent -> absent
        Port['23']
            open: false -> false

Passed: 1/1
```

What if we have a resource that is called something on one operating system, and something else on another?
Let's say we care about the state of /etc/shadow on a Linux system and /etc/master.passwd on our OSX dev boxes.
One solution is to write your policy as an erb template.

Let's create the following policy file and call it `weyland_compliance_policy.yaml.erb`,

```yaml
<% filename = '/etc/shadow/' %>
<%   if Facter.value('operatingsystem') == 'Darwin' %>
<%     filename = '/etc/master.passwd' %>
<%   end %>
:name: Weyland Corp Compliance policy 4000
:rules:
  - :description: /etc/sudoers is secure
    :resources:
      :File['/etc/sudoers']:
        :ensure: present
        :mode: "0440"
        :group: 0
        :owner: 0
  - :description: Telnet isn't running and it's port is closed
    :resources:
      :Service['telnetd']:
        :ensure: absent
      :Port['23']:
        :open: false
  - :description: Our pasword hashes are A-OK
    :resources:
      :File['<%= filename %>']:
        :ensure: present
        :mode: "0600"
        :group: 0
        :owner: 0
```

and if we run it on OSX

```shell
$ sudo probium policies/weyland_compliance_policy.yaml.erb
Total Policies: 1

Policy: Weyland Corp Compliance policy 4000

    Description: /etc/sudoers is secure
        File['/etc/sudoers']
            ensure: present -> file
            mode: 0440 -> 0440
            group: 0 -> 0
            owner: 0 -> 0

    Description: Telnet isn't running and it's port is closed
        Service['telnetd']
            ensure: absent -> absent
        Port['23']
            open: false -> false

    Description: Our pasword hashes are A-OK
        File['/etc/master.passwd']
            ensure: present -> file
            mode: 0600 -> 0600
            group: 0 -> 0
            owner: 0 -> 0

Passed: 1/1
```

We can also split our policy up into smaller policies and confine certain resources to certain facts.

Let's take our base policy and call it `weyland_compliance_shared_policy.yaml`,

```
:name: Weyland Corp Shared Compliance policy 4000
:rules:
  - :description: /etc/sudoers is secure
    :resources:
      :File['/etc/sudoers']:
        :ensure: present
        :mode: "0440"
        :group: 0
        :owner: 0
  - :description: Telnet isn't running and it's port is closed
    :resources:
      :Service['telnetd']:
        :ensure: absent
      :Port['23']:
        :open: false
```

and then add two more,

`weyland_compliance_shadow_linux.yaml`

```yaml
:name: Shadow files on linux
:confine:
  :operatingsystem: Linux
:rules:
  - :description: Our pasword hashes are A-OK
    :resources:
      :File['/etc/shadow']:
        :ensure: present
        :mode: "0600"
        :group: 0
        :owner: 0
```
and `weyland_compliance_shadow_osx.yaml`

```yaml
:name: Shadow files on OSX
:confine:
  :operatingsystem: Darwin
:rules:
  - :description: Our pasword hashes are A-OK
    :resources:
      :File['/etc/master.passwd']:
        :ensure: present
        :mode: "0600"
        :group: 0
        :owner: 0
```

We can now put these files in a directory, like

```shell
├── policy_group
│   ├── weyland_compliance_policy.yaml
│   ├── weyland_compliance_shadow_linux.yaml
│   └── weyland_compliance_shadow_osx.yaml
```

and pass the directory as the first argument to Probium,

```shell
$ sudo probium policies/policy_group/
Total Policies: 2

Policy: Shadow files on OSX

    Description: Our pasword hashes are A-OK
        File['/etc/master.passwd']
            ensure: present -> file
            mode: 0600 -> 0600
            group: 0 -> 0
            owner: 0 -> 0

Policy: Weyland Corp Compliance policy 4000

    Description: /etc/sudoers is secure
        File['/etc/sudoers']
            ensure: present -> file
            mode: 0440 -> 0440
            group: 0 -> 0
            owner: 0 -> 0

    Description: Telnet isn't running and it's port is closed
        Service['telnetd']
            ensure: absent -> absent
        Port['23']
            open: false -> false

Passed: 2/2
```
##### Note - All the examples in this README can be found in the `policies` directory inside the repo.



