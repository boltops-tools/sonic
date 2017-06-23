---
title: Sonic List
---

Sonic provides a quick way to list your instances.

```sh
sonic list [FILTER]
```

Example:

```sh
sonic list i-066b140d9479e9681,i-09482b1a6e330fbf7
sonic list ec2-tag-1,ec2-tag-2
```

You should see something like this:

```sh
$ sonic list i-066b140d9479e9681,i-09482b1a6e330fbf7
i-09482b1a6e330fbf7 prod-20170416110240 54.202.152.168  172.31.21.108 t2.small
i-066b140d9479e9681 docker-20170428071833 34.211.144.113  172.31.11.250 m3.medium
$
```

You can include a header with the `--header` option:

```sh
$ sonic list i-066b140d9479e9681,i-09482b1a6e330fbf7 --header
Instance Id Name  Public IP Private IP  Type
i-09482b1a6e330fbf7 prod-20170416110240 54.202.152.168  172.31.21.108 t2.small
i-066b140d9479e9681 docker-20170428071833 34.211.144.113  172.31.11.250 m3.medium
$
```

The list command can be helpful if you want to list out the instances and pipe it back into other tools. Here's a simple example:

```sh
$ for i in $(sonic list i-066b140d9479e9681,i-09482b1a6e330fbf7 | awk '{print $3}') ; do echo $i ; ssh ec2-user@$i uptime ; done
54.202.152.168
 17:39:14 up 6 days,  1:24,  0 users,  load average: 0.00, 0.00, 0.00
34.211.144.113
 17:39:14 up 3 days, 12:03,  0 users,  load average: 0.00, 0.00, 0.00
$
```

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial-execute.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/settings.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
