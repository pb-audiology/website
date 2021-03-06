# PB Audiology

Source code for an audiology practice's website.

<!-- toc -->

- [Components](#components)
  * [Ruby web application](#ruby-web-application)
    + [Setup](#setup)
    + [Run the development server](#run-the-development-server)
- [Deployment](#deployment)
  * [Buildpacks](#buildpacks)

<!-- tocstop -->

To regenerate the table of contents run `yarn markdown-toc -i README.md`

# Components

## Ruby web application

This app exists primarily to serve content pages, but has the potential to provide additional server-side functionality if needed.

We build the app on top of the [Roda framework](http://roda.jeremyevans.net/).

It follows the conventions for a Small Application [outlined in the Roda docs](http://roda.jeremyevans.net/rdoc/files/doc/conventions_rdoc.html).

The app has static assets that we manage with Node, using [Webpack](https://webpack.js.org/).

### Setup

Install Node and Yarn.

Install NPM packages:
```
yarn
```

Compile assets, and watch for changes:
```
yarn watch
```

Install Ruby and Bundler.

Install gems:
```
bundle install
```

Install git hooks that will run rubocop on commit:
```
bundle exec overcommit --install
```

Environment: Create a `.env` file. Copy `.env.example`

We use the Google Maps API to embed a map with the office location.

Obtain a development Google API key. Someone with access to our [Google Cloud console](https://console.cloud.google.com/apis/credentials?organizationId=0&project=pb-audiology) must provide the key. The in `.env`, create an entry for it:

```
GOOGLE_API_KEY=...
```

### Run the development server

We use the [Rerun](https://github.com/alexch/rerun) gem to automatically restart the app when files change. To run the web server:
```
rerun -- bundle exec puma -v -C config/puma.rb
```

# Deployment

We host the app on [Heroku](https://www.heroku.com/).

## Buildpacks

The app requires the `heroku/nodejs` and `heroku/ruby` [buildpacks](https://devcenter.heroku.com/articles/buildpacks), in that order. The Node buildpack compiles the assets on deploy. The Ruby buildpack sets up and runs the server application.

## Third-party services

* Heroku to host the application
* Google APIs to embed a map
* Google Domains to register the domain name and configure DNS settings
* Google G Suite to provide email (`@paulinebaileyaudiology.com`)

