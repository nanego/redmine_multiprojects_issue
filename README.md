Redmine Multiprojects Issue plugin
======================

This redmine plugin allow you to specify more than one project per issue.

Cross-projects issues appear in all concerned projects. They can be viewed by every users who have enough permission on at least one impacted project, but can be updated only by users who have enough permissions on the main project (the project used to create the issue).

Screenshots
------------

![redmine_multiprojects_issue screenshot](http://blog.nanego.com/images/multiproject_query.png)
![redmine_multiprojects_issue screenshot](http://blog.nanego.com/images/multiproject_show.png)
![redmine_multiprojects_issue screenshot](http://blog.nanego.com/images/multiproject_modify.png)

Installation
------------

This plugin has been tested with Redmine 2.3.0+. For Redmine versions up to 3.2.x, [release v0.2](https://github.com/nanego/redmine_multiprojects_issue/releases/tag/v0.2) must be used. For Redmine version 3.3.0+, use the current master. See below for specific instructions.

Please apply general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

Note that this plugin now depends on:

* **redmine_base_deface** which can be found [here](https://github.com/jbbarth/redmine_base_deface)

First download the source or clone the plugin and put it in the "plugins/" directory of your redmine instance. Note that this is crucial that the directory is named 'redmine_multiprojects_issue'!

If you are runnning Redmine 2.3.0 to 3.2.x, you need to download or clone [v0.2](https://github.com/nanego/redmine_multiprojects_issue/releases/tag/v0.2). If you are running Redmine 3.3.0+, download or clone the current master.

Then execute:

    $ bundle install
    $ rake redmine:plugins

And finally restart your Redmine instance.


Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
