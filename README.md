# ISLAY

A Rails engine for building website backends.

It's not a CMS, nor is it a drop-in admin interface.

## Bootstrap the Database

From a console, run:

  rake islay:install:migrations

Then, run up your migrations

  rake db:migrate

To help you get started, you can load some seed data into your fresh database. This will set up a dummy user account which will allow you to log in and have a poke around.

  rake islay:db:seed

The admin credentials are admin@domain.com/password

## Upgrade to Rails 4.x

Generally applications should just work, but any custom models will need to have some modifications.

* Remove calls to `validations_from_schema`; custom code has been replaced with a lib

