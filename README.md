[![Build Status](https://travis-ci.org/justinclayton/puppet-module-nexus.png?branch=master)](https://travis-ci.org/justinclayton/puppet-module-nexus)

Description
-------
This module installs [Nexus](http://www.sonatype.org/nexus) from sonatype.org, and configures it for Redhat-family systems. It is compliant with both puppet 2.7+ and 3+, and has been tested for quality using [puppet-lint](http://github.com/puppetlabs/puppet-lint), [rspec-puppet](http://github.com/rodjek/rspec-puppet), and [rspec-system](http://github.com/puppetlabs/rspec-system).

Installation
------
If you're using librarian-puppet, add a line to your `Puppetfile`:

```
mod 'justinclayton/nexus', '1.x'
```

Usage
------
```
include nexus
```