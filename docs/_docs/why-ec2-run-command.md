---
title: Why Use EC2 Run Command
---

Why use Amazon EC2 Run Command vs just using a multi-ssh session?

* Some times it is not possible to use ssh across several servers.  For example, really secured networks might have [MFA setup](TODO) so you need to authorized the requests via your phone before the command actually gets ran. In this case, you would get annoying confirmation notifications on your phone over and over as you approve each request for each of your servers.
* EC2 Run Command provides auditability. Any command that runs the EC2 Run Command gets logged and is tracked.
* The EC2 Run Manager has the ability to run the command in "blue/green" fashion with concurrency controls. Say you have 100 servers, you can tell EC2 Run Manager to run the command on one server first and the expodentially roll it out to the rest of the servers until the command has successfully ran on all servers.  If it the command errors on one server then it halts execution and does not run on the rest of the servers.
* This is all provided for free by using EC2 Run Manager.

The initial ertia of setting up EC2 Run Manager is actually very little.  The [installation instructions]({% link _docs/install.md %}) demonstrate that installing EC2 Run Manager is literally one command.

<a id="prev" class="btn btn-basic" href="{% link _docs/why.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/how-it-works.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
