---
title: sonic run_command
reference: true
---

## Usage

    sonic run_command [FILTER] [COMMAND]

## Description

runs command across fleet of servers via AWS Run Command

Run as a command across a list of servers. A filter must be provided.  The filter can be a mix of instance ids and ec2 tags. This command can also take a path to a file. To specify a path to a file use file:// at the beginning of your file.

Examples:

    $ sonic run_command hi-web-prod uptime
    $ sonic run_command hi-web-prod,hi-worker-prod,hi-clock-prod uptime
    $ sonic run_command i-030033c20c54bf149,i-030033c20c54bf150 uname -a
    $ sonic run_command i-030033c20c54bf149 file://hello.sh

You cannot mix instance ids and tag names in the filter.


## Options

```
[--zero-warn], [--no-zero-warn]  # Warns user when no instances found
                                 # Default: true
[--verbose], [--no-verbose]      
[--noop], [--no-noop]            
```

