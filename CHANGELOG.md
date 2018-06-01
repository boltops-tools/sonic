# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [2.1.0]
- change the setting format to ssh.user instead of bastion.user

## [2.0.0]
- Merge pull request #5 from boltopslabs/cli-template-upgrade
- improve css for docs site
- add CLI reference docs
- use JumpProxy option for bastion
- change the way settings work, usage of SONIC_PROFILE and AWS_PROFILE and separate files
- Big restructuring of sonic commands:
- sonic ecs exec
- sonic ecs run
- sonic execute # much improved and added conveniences

## [1.4.0]
- only use required aws-sdk modules
- update gemspec homepage
- update quick start install

## [1.3.2]
- Add sonic ssh -i option so users can specify custom private keys.
- Add sonic ssh -r retry option so you don't have to keep pressing up enter.

## [1.3.1]
- remove byebug debugging

## [1.3.0]
- support for different bastion cluster host mapping in settings

## [1.2.0]
- add old instance id support
- update docs and help

## [1.1.1]
- update docs and help

## [1.1.0]
- standardize filter to be first argument

## [1.0.0]
- sonic ecs exec
- sonic ecs sh
- sonic execute
- sonic list
- sonic ssh
