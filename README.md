Redmine Multiprojects Issue plugin
======================

[![Build Status](https://travis-ci.com/nanego/redmine_multiprojects_issue.svg?branch=master)](https://travis-ci.com/nanego/redmine_multiprojects_issue)

This redmine plugin allows you to specify more than one project per issue.

Cross-projects issues appear in all related projects. They can be viewed by every users who have enough permission on at least one impacted project, but can be updated only by users who have enough permissions on the main project (the project used to create the issue).

Screenshots
------------

![redmine_multiprojects_issue screenshot](https://raw.githubusercontent.com/nanego/redmine_multiprojects_issue/master/assets/images/multiprojects_show.png)
![redmine_multiprojects_issue screenshot](https://raw.githubusercontent.com/nanego/redmine_multiprojects_issue/master/assets/images/multiprojects_issues.png)
![redmine_multiprojects_issue screenshot](https://raw.githubusercontent.com/nanego/redmine_multiprojects_issue/master/assets/images/multiprojects_edit.png)

Installation
------------

This plugin has been tested with Redmine 2.3.0+.

For Redmine versions up to 3.2.x, [release v0.2](https://github.com/nanego/redmine_multiprojects_issue/releases/tag/v0.2) must be used.

For Redmine version 3.3 & 3.4, use this release [v3.4.6](https://github.com/nanego/redmine_multiprojects_issue/releases/tag/v3.4.6)

For Redmine version 4.0.0+, use the current master branch. See below for specific instructions.

Please apply general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

Note that this plugin now depends on:

* **redmine_base_deface** which can be found [here](https://github.com/jbbarth/redmine_base_deface)
* **redmine_base_stimulusjs** which can be found [here](https://github.com/nanego/redmine_base_stimulusjs)

These plugins must be installed first.

Then, download the source or clone the plugin and put it in the "plugins/" directory of your redmine instance. Note that this is crucial that the directory is named 'redmine_multiprojects_issue'!

Then execute:

    $ bundle install
    $ rake redmine:plugins

And finally restart your Redmine instance.

## Test status

|Plugin branch| Redmine Version   | Test Status       |
|-------------|-------------------|-------------------| 
|master       | 4.1.1             | [![Build1][1]][5] |  
|master       | 4.0.7             | [![Build2][2]][5] |
|master       | master            | [![Build1][3]][5] | 

[1]: https://travis-matrix-badges.herokuapp.com/repos/nanego/redmine_multiprojects_issue/branches/master/1?use_travis_com=true
[2]: https://travis-matrix-badges.herokuapp.com/repos/nanego/redmine_multiprojects_issue/branches/master/2?use_travis_com=true
[3]: https://travis-matrix-badges.herokuapp.com/repos/nanego/redmine_multiprojects_issue/branches/master/3?use_travis_com=true
[5]: https://travis-ci.com/nanego/redmine_multiprojects_issue



Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
