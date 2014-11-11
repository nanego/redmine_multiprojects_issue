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

This plugin has been tested with Redmine 2.3.0+.

Please apply general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

Note that this plugin now depends on

* **redmine_base_select2** which can be found [here](https://github.com/jbbarth/redmine_base_select2)
and 
* **redmine_base_deface** [here](https://github.com/jbbarth/redmine_base_deface)

First download the source or clone the plugin and put it in the "plugins/" directory of your redmine instance. Note that this is crucial that the directory is named 'redmine_multiprojects_issue'!

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
