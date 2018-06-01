---
title: sonic list
reference: true
---

## Usage

    sonic list [FILTER]

## Description

Lists ec2 instances.

A filter must be provided.  The filter can be a mix of instance ids and ec2 tags. sonic list will auto-detect the what type of filter it is.  The filter is optional.

## Examples

    $ sonic list
    $ sonic list hi-web-prod
    $ sonic list hi-web-prod,hi-clock-prod
    $ sonic list i-09482b1a6e330fbf7

## Example Output

    $ sonic list --header i-09482b1a6e330fbf7
    Instance Id Public IP Private IP  Type
    i-09482b1a6e330fbf7 54.202.152.168  172.31.21.108 t2.small
    $

You cannot mix instance ids and tag names in the filter.


## Options

```
[--header], [--no-header]    # Displays header
[--verbose], [--no-verbose]  
[--noop], [--no-noop]        
```

