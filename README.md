# Pokémon Sprint Name Voting Booth App in Elm

This example shows embedding an Elm app into an ordinary HTML-page. It consists
of a simple Node.js web server and an Elm SPA.

## Ingredients and dependencies:

- [Install Elm](http://elm-lang.org/install)
- [Install Node](https://nodejs.org/en/download/)

Next, install the server dependencies, by running

```
make install
```

## Security Keys:

### Auth0:

Download the Auth0 private key from:

https://manage.auth0.com/#/clients/n0dhDfP61nzDIRpMaw8UsoPLiNxcxdM9/settings

Scroll down and click 'Show Advanced Settings'. Open the tab 'certificates' and copy the 'Signing Certificate'.
Save it to `keys/public-auth0.key`

### Firebase:

Download the firebase private key from:
https://console.firebase.google.com/u/0/project/sprintname-voting-booth/settings/serviceaccounts/adminsdk

Click "Generate new private key".  Save it to `keys/serviceAccountKey.json`.

## Running the application:

In terminal run:

```
make start
```

Open `http://localhost:4201`

## Installing in a docker image:

If you want to install the voting booth app in a docker image, you may do so with:

```
make docker-start
```

