# Change Log

All notable changes to this project will be documented in this file.
This project *loosely* adheres to [Semantic Versioning](http://semver.org/), even before v1.0.

## [2.2.5] - 2021-04-24
- [#14](https://github.com/boltops-tools/sonic/pull/14) execute --timeout option: executionTimeout

## [2.2.4] - 2021-04-13
- [#13](https://github.com/boltops-tools/sonic/pull/13) execute --comment option

## [2.2.3] - 2021-04-12
- [#12](https://github.com/boltops-tools/sonic/pull/12) fix cli check

## [2.2.2] - 2021-04-12
- [#11](https://github.com/boltops-tools/sonic/pull/11) cli check

## [2.2.1] - 2021-04-12
- [#9](https://github.com/boltops-tools/sonic/pull/9) improve command array handling

## [2.2.0]
- #7 sonic execute command: `--tags` and `--instance-id` options instead of polymorphic list. Breaking behavior.
- display output even if tags used
- configure default log group
- correct exit status

## [2.1.1]
- use rainbow gem for terminal colors

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
