# Local Orbit

* **[Alpha Deploy (Preview)](https://github.com/LocalOrbit/localorbit/compare/alpha...master)**
* **[Staging Deploy (Preview)](https://github.com/LocalOrbit/localorbit/compare/staging...master)**
* **[Production Deploy (Preview)](https://github.com/LocalOrbit/localorbit/compare/production...staging)**

See the `docs/` directory for more documentation.

## Running

### Requirements

* Ruby 2.1.2
* PostgreSQL
* PhantomJS (for running tests)
* ImageMagick
* Yarn

### Setup

1. Clone the repo
2. `brew bundle` (on OS X. Install Requirements above for other platforms. May require you to unlink and reinstall previously installed packages.)
3. `bundle`
4. `cp config/application.yml{.example,}` and modify if needed
5. `cp config/database.yml{.example,}` and modify if needed (Some modification is probably necessary. Try adding `template: template0`)
6. `yarn`
7. `rake db:setup` - runs `db:create`, `db:schema:load` and `db:seed`
8. `rake db:seed:development`
9. `rails server`
10. Add `127.0.0.1 localtest.me` to `/etc/hosts`
11. Go to http://localtest.me:3000 in a browser (we use localtest.me to always point to 127.0.0.1 so we can use subdomains, which localhost doesn't allow.)
12. Startup delayed job with `./bin/delayed_job` (caveat: delete jobs from that table first if loading in production data)

#### AWS

Amazon AWS is used by the app to store images as well as transferring db backups between environments.
Get an invitation to the AWS account and configure an API key and secret. Install the [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [configure it](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

#### Other required services to setup

* [stripe howto](docs/stripe_in_development.md) for configuring stripe for development.
* Setup a [mailtrap](https://mailtrap.io/) account and put the username and password into your application.yml


### Production Setup

* At least one Market must be created before creating Organizations

### Test Accounts
Running `rake db:seed:development` makes the following test accounts available

*Selling Organization*
Email: seller@example.com
Password: password1

*Buying Organization*
Email: buyer@example.com
Password: password1

*Market Manager*
Email: mm@example.com
Password: password1

### Javascript Specs

Specs live in spec/javascripts/\*.js.coffee

Run suite on command line:  bundle exec rake konacha:run
Run suite via browser:  bundle exec rake konacha:serve (then visit http://localhost:3500)
Run suite automatically on changes to javascript sources or specs:  bundle exec guard


### Cloning staging for local development
Run `rake db:dump:staging`

**WARNING: This will replace EVERYTHING in your development db with what is currently on staging**

## Contributing

See [development process](docs/development_process.md).
