---
title: Settings
---

You can adjust the behavior of sonic and set some handy default values with settings files.  The settings files used are determined by the value of environment variable `SONIC_PROFILE` or `AWS_PROFILE`. The value determines the settings profile to to use.  There can exist multiple settings files which all get loaded and merged. The options from the files follow the following precedence rules:

1. current folder - The current folder's `.sonic/[PROFILE].yml` values take the highest precedence. The current folder is typically the project folder.
2. user - The user's `~/.sonic/[PROFILE].yml` values take the second highest precedence.
3. default - The [default settings](https://github.com/boltopslabs/sonic/blob/master/lib/sonic/default/settings.yml) bundled with the tool takes the lowest precedence.

A concrete example helps explain it. Let's say `AWS_PROFILE=prod-profile` with the following files:

* in current folder: `.sonic/prod-profile.yml`
* in user home folder: `~/.sonic/prod-profile.yml`

Then the `.sonic/prod-profile.yml` gets merged into `~/.sonic/prod-profile.yml` and that in turn gets merged into sonic's [default settings](https://github.com/boltopslabs/sonic/blob/master/lib/sonic/default/settings.yml).

You can also use the `SONIC_PROFILE=prod-profile` environment variable instead of the `AWS_PROFILE` environment variable. The `SONIC_PROFILE` wins over the `AWS_PROFILE` value.

## Full Example

Here is an `prod-profile.yml` example:

```yaml
bastion: # cluster_host mapping
  user: ec2-user
  host: # default is nil - which means a bastion host wont be used
  host_key_check: false

# used with `sonic ecs ssh` command
ecs_service_cluster_map:
  default: default # default cluster
  hi-web: production
  hi-clock: production
  hi-worker: production
```

The following table covers the different setting options:

Setting  | Description | Default
------------- | ------------- | -------------
bastion.user  | User to ssh into the server with. This can be overriden at the CLI with the user@host notation but can be set in the settings.yml file also. | ec2-user
bastion.host  | Bastion mapping allows you to set a bastion host on a per ECS cluster basis.  The bastion host is used as the jump host. Examples: bastion.mydomain.com, myuser@bastion.myuser.com or 123.123.123.123. | (no value)
bastion.host_key_check  | Controls whether or not use the strict host checking ssh option.  Since EC2 server host changes often the default value is false. | false
ecs_service_cluster_map  | Service to cluster mapping.  This is a Hash structure that maps the service name to cluster names. | (no value)

The default settings are located tool source code at [lib/sonic/default/settings.yml](https://github.com/boltopslabs/sonic/blob/master/lib/sonic/default/settings.yml).

### Service to Cluster Mapping

A useful option is the `ecs_service_cluster_map`.  This option maps ecs service names to cluster names.  This saves you from  typing the `--cluster` option repeatedly.  Here is an example `~/.sonic/settings.yml`:

```yaml
ecs_service_cluster_map:
  default: my-default-cluster
  hi-web: production
  hi-clock: production
  hi-worker: production
```

This results in shorter commands:

```
sonic ecs ssh hi-web
sonic ecs ssh hi-clock
sonic ecs ssh hi-worker
```

Instead of what you normally would have to type:

```
sonic ecs ssh hi-web --cluster production
sonic ecs ssh hi-clock --cluster production
sonic ecs ssh hi-worker --cluster production
```


<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-list.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/help.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
