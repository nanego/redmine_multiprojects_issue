Redmine Multiprojects Issue plugin
======================

[![5.0.2][1]][5]
[![4.2.7][2]][5]

This redmine plugin allows you to specify more than one project per issue.

Cross-projects issues appear in all related projects. They can be viewed by every users who have enough permission on at least one related project, but can be updated only by users who have enough permissions on the main project (the project used to create the issue).

Do not forget to add the "View multi-projects issues" permission to authorized roles.

Screenshots
------------

![redmine_multiprojects_issue screenshot](https://raw.githubusercontent.com/nanego/redmine_multiprojects_issue/master/assets/images/multiprojects_show.png)
![redmine_multiprojects_issue screenshot](https://raw.githubusercontent.com/nanego/redmine_multiprojects_issue/master/assets/images/multiprojects_issues.png)
![redmine_multiprojects_issue screenshot](https://raw.githubusercontent.com/nanego/redmine_multiprojects_issue/master/assets/images/multiprojects_edit.png)

Installation
------------

This plugin has been tested with Redmine 2.3.0+.

Compatibility with older Redmine versions:
* for Redmine versions up to 3.2.x, [release v0.2](https://github.com/nanego/redmine_multiprojects_issue/releases/tag/v0.2) must be used.
* for Redmine version 3.3 & 3.4, please use this release [v3.4.6](https://github.com/nanego/redmine_multiprojects_issue/releases/tag/v3.4.6)
* for Redmine version 4.0 & 4.1, use this release [v4.1.2](https://github.com/nanego/redmine_multiprojects_issue/releases/tag/v4.1.2)
* for Redmine version 4.2.x, use this release [v4.2.7](https://github.com/nanego/redmine_multiprojects_issue/releases/tag/v4.2.7)

With Redmine 5.0+, use the current master branch. See below for specific instructions.

Please apply general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

Note that this plugin depends on:

* **redmine_base_deface** which can be found [here](https://github.com/jbbarth/redmine_base_deface)
* **redmine_base_stimulusjs** which can be found [here](https://github.com/nanego/redmine_base_stimulusjs)

These plugins must be installed first.

Then, download the source or clone the plugin and put it in the "plugins/" directory of your redmine instance. Note that this is crucial that the directory is named 'redmine_multiprojects_issue'!

Then execute:

    $ bundle install
    $ rake redmine:plugins

And finally restart your Redmine instance.

## Test status

|Plugin branch| Redmine Version | Test Status       |
|-------------|-----------------|-------------------|
|master       | 5.0.2           | [![5.0.2][1]][5]  |
|master       | 4.2.7           | [![4.2.7][2]][5]  |
|master       | master          | [![master][4]][5] |

[1]: https://github.com/nanego/redmine_multiprojects_issue/actions/workflows/5_0_2.yml/badge.svg
[2]: https://github.com/nanego/redmine_multiprojects_issue/actions/workflows/4_2_7.yml/badge.svg
[4]: https://github.com/nanego/redmine_multiprojects_issue/actions/workflows/master.yml/badge.svg
[5]: https://github.com/nanego/redmine_multiprojects_issue/actions

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
