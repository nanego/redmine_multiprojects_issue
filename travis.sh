#/bin/bash

set -e

if [[ ! "$TESTSPACE" = /* ]] ||
   [[ ! "$PATH_TO_REDMINE" = /* ]] ||
   [[ ! "$REDMINE_VER" = * ]] ||
   [[ ! "$NAME_OF_PLUGIN" = * ]] ||
   [[ ! "$PATH_TO_PLUGIN" = /* ]];
then
  echo "You should set"\
       " TESTSPACE, PATH_TO_REDMINE, REDMINE_VER"\
       " NAME_OF_PLUGIN, PATH_TO_PLUGIN"\
       " environment variables"
  echo "You set:"\
       "$TESTSPACE"\
       "$PATH_TO_REDMINE"\
       "$REDMINE_VER"\
       "$NAME_OF_PLUGIN"\
       "$PATH_TO_PLUGIN"
  exit 1;
fi

export RAILS_ENV=test

export REDMINE_GIT_REPO=git://github.com/redmine/redmine.git
export REDMINE_GIT_TAG=$REDMINE_VER
export BUNDLE_GEMFILE=$PATH_TO_REDMINE/Gemfile

# checkout redmine
if [ "$REDMINE_GIT_TAG" == "master" ];
then
  git clone $REDMINE_GIT_REPO $PATH_TO_REDMINE
else
  git clone $REDMINE_GIT_REPO --branch=$REDMINE_GIT_TAG $PATH_TO_REDMINE
fi

cd $PATH_TO_REDMINE

# Temporary fix for issue #32785 X-Sendfile header field is not set if rack 2.1.0 is installed
# TODO => Remove this when Redmine 4.1.1 is released
echo "gem 'rack', '~> 2.0.8'" >> Gemfile

mv $TESTSPACE/database.yml.travis config/database.yml
mv $TESTSPACE/additional_environment.rb config/

# install gems
bundle install --jobs=4

# run redmine database migrations
bundle exec rails db:migrate RAILS_ENV=test

# create a link to the backlogs plugin
ln -sf $PATH_TO_PLUGIN plugins/$NAME_OF_PLUGIN

# Add other plugins dependencies
git clone https://github.com/jbbarth/redmine_base_deface.git plugins/redmine_base_deface
git clone https://github.com/jbbarth/redmine_base_rspec.git plugins/redmine_base_rspec
git clone https://github.com/nanego/redmine_base_stimulusjs.git plugins/redmine_base_stimulusjs

# install gems
bundle install --jobs=4

# run plugins migrations
bundle exec rails redmine:plugins RAILS_ENV=test

# install redmine database
# bundle exec rails redmine:load_default_data REDMINE_LANG=en

# bundle exec rails db:structure:dump
bundle exec rails db:fixtures:load
bundle exec rails test:scm:setup:subversion

# run tests
# bundle exec rake TEST=test/unit/role_test.rb
bundle exec rails test
bundle exec rails redmine:plugins:test NAME=$NAME_OF_PLUGIN
