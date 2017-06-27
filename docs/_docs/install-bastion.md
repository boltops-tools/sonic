---
title: Bastion Setup
---

It is common to secure your network setup by restricting access to your servers by placing them in internal subnets.  In this case you will have a bastion host server that you must use to jump through to get to your instance. Sonic provides built-in support for a bastion host.

You can configure the [settings.yml]({% link _docs/settings.md %}) file to use a bastion host. Here's an example:

```yaml
bastion: # cluster_host mapping
  default: ec2-user@bastion.mydomain.com
  prod: ec2-user@bastion.mydomain.com
  stag: ubuntu@bastion-stag.mydomain.com
```

The configuration specifies a bastion for the specific clusters. If the cluster is not in the configuration it defaults to the default bastion host setting.

The settting directs the `sonic ssh` to jump through the bastion host. This works completely transparently. The sonic commands are exactly the same as if there is no bastion host.

```
sonic ssh i-0f7f833131a51ce35
```

You should notice that the built up command now includes the bastion jump host.

```
$ sonic ssh i-0f7f833131a51ce35 uptime
=> ssh -At ec2-user@34.211.223.3 ssh ec2-user@10.10.110.135 uptime
Warning: Permanently added '34.211.223.3' (ECDSA) to the list of known hosts.
Warning: Permanently added '10.10.110.135' (ECDSA) to the list of known hosts.
 18:35:18 up  1:14,  0 users,  load average: 0.24, 0.07, 0.02
Connection to 34.211.223.3 closed.
$
```

You can also specify the bastion host as a CLI option with `--bastion`, though it is recommended that you configure it in a `settings.yml` file so you do not have to repeatedly type it.

<a id="prev" class="btn btn-basic" href="{% link _docs/install.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
