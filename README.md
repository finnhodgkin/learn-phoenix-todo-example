## Todo app features

* OAuth
* Todos
* Todo lists
* Ownership of todo lists and todos

## First steps

### Install Postgresql, Elixir and Phoenix

### Create a new Phoenix project
Run `mix phx.new ptodos`.

This creates a new `ptodos` directory with a simple Phoenix server setup.

### Run through the file structure of Phoenix applications as well as the differences between 1.3 and <1.3

### Build the database
Run `mix Ecto.create`

If it complains about your postgres username & password check the information in
config/dev.exs matches your postgres login details.

If you've lost or don't know your password, try following [this Stack Overflow solution](https://stackoverflow.com/questions/35785892/ecto-postgres-install-error-password-authentication-failed#answer-37375810).

### Briefly run through migrations/schemas/repo

## Add a route to display todos

### Generate a todos route
Run `mix phx.gen.html Todos Todo todos title:string`.

In the terminal after the generation logs, there should be a prompt about the new files:

> Add the resource to your browser scope in lib/todos_web/router.ex:<br><br>
    resources "/todos", TodoController

### Do the router thing
Following the hint above, add the new `todos` route to the router :sparkles:

`resources "/todos", TodoController` needs to be added just under the line adding a PageController `get "/", PageController, :index`

### Add the new table to the database
Run `mix ecto.migrate` to add the todos table to the postgres database.

### Run the server
Use `mix phx.server` to run your server.

To just get access to the server functions from the command line (great for debugging) use `iex -S mix`

Head over to http://0.0.0.0:4000/todos to see the new route we just made in the browser :sparkles:

### Explain the relationship between controllers, templates and the router. Maybe just link to the Phoenix docs on each topic.

### Time for some cleanup!

#### Remove the show template
We don't want the application to have individual pages for each todo so the first step is to remove the show.html.eex template file from `lib/ptodos_web/templates/todo`.

Now the template is removed, we'll also need to take out the show function from the todo_controller (`lib/ptodos_web/controllers/todo_controller.ex`).

#### Remove all links and redirects to the show route

First remove the show button from the index template.

This:

```iex
<td class="text-right">
  <span><%= link "Show", to: todo_path(@conn, :show, todo), class: "btn btn-default btn-xs" %></span>
  <span><%= link "Edit", to: todo_path(@conn, :edit, todo), class: "btn btn-default btn-xs" %></span>
  <span><%= link "Delete", to: todo_path(@conn, :delete, todo), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %></span>
</td>
```

Should become this:

```iex
<td class="text-right">
  <span><%= link "Edit", to: todo_path(@conn, :edit, todo), class: "btn btn-default btn-xs" %></span>
  <span><%= link "Delete", to: todo_path(@conn, :delete, todo), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %></span>
</td>
```

Next, within the todo_controller we'll need to change how the `update` function redirects. At the moment when a todo is successfully edited, the app tries to redirect to the `show` page for that todo. Instead, it should just redirect back to the index route where all todos are listed.

Have a look inside the `{:ok, todo}` case within the `update` function and change the redirect to the following:

```iex
redirect(to: todo_path(conn, :index))
```

The `create` function will need the same fix.

#### Remove the annoying 'are you sure' confirmation popup for deleting todos

Todos should be really easy to manipulate so let's remove the popup alert from `index.html.eex`. It's a super easy fix, just delete ` data: [confirm: "Are you sure?"],`.

#### Remove the Phoenix branding from the app layout

The layout file (`templates/layout/app.html.eex`) holds all html content that's shared between many pages. For example css imports and html headers usually sit in there.

By default Phoenix also includes a big logo and a link to 'Get Started' with Phoenix. Lets trash this.

Delete everything inside the <header> tags to clean it up.

### Test the app

Run `mix phx.server` to test the app.

Hopefully if you head over to http://0.0.0.0:4000/todos it'll look something like this:

![OMG it worked!](https://user-images.githubusercontent.com/22300773/29921885-51e9e594-8e4b-11e7-8415-f7e73c722e50.png)

## OAuth authentication

Next we'll add OAuth user authentication so our todos can only be changed by their owners. To accomplish this we'll be using the Elixir [Ueberauth module](https://github.com/ueberauth/ueberauth) with the [Github OAuth strategy](https://github.com/ueberauth/ueberauth_github). New modules can be added to a project by including them in `mix.exs` and installing with `mix deps.get`. OAuth also requires some hidden keys that we don't want pushed up to version control (Github, etc.) - for this we'll use [Envy](https://github.com/BlakeWilliams/envy) to automatically load environment variables.

#### Installing the dependencies

Hop into mix.exs and add `:ueberauth` and `:ueberauth_github` to `extra_applications`:

![extra_applications](https://user-images.githubusercontent.com/22300773/29924988-d0304744-8e56-11e7-9c47-6c78b610e8a4.png)

We'll also need to add all three modules to our dependencies list. At the time of writing (Aug 2017) the version numbers in the picture below are all up to date. To be on the safe side have a quick Google to check there aren't any newer versions.

![dependencies](https://user-images.githubusercontent.com/22300773/29925540-7f452b36-8e58-11e7-9a8f-1a80a15f0be5.png)

#### Configuring the dependencies

Both Ueberauth and Envy require some additional configuration.

__Ueberauth__

Ueberauth is an amazing module that does a ton of authentication setup behind the scenes. Unfortunately it doesn't quite do __everything__. We need to provide it with some info about our application setup: which OAuth providers to use, and the OAuth _client id_ and _secret_.

The first step's easy because we only need to add one provider -- Github OAuth. Open up `config/config.exs` and chuck the following code at the end of the file:

```iex
config :ueberauth, Ueberauth,
  providers: [
    github: { Ueberauth.Strategy.Github, [] }
  ]
```

In the next few steps we'll connect Envy to a `.env` containing our Github OAuth information. For the moment it's fine to just point Ueberauth at some non-existent GITHUB_SECRET and GITHUB_CLIENT_ID environment variables. Add the following right underneath previous code block:   

```iex
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
 client_id: System.get_env("GITHUB_CLIENT_ID"),
 client_secret: System.get_env("GITHUB_SECRET")
```


__Github__

For OAuth to work, the application needs to be registered on the provider's website. Log in to Github and point the browser to https://github.com/settings/developers

Hit `Register a new application` and fill in the form with with the following details:

Application name: `Phoenix Todos`<br/>
Homepage URL (this could be your homepage or just a temporary address): `http://0.0.0.0:4000`<br/>
Application description: `[optional]`<br/>
Authorization callback URL: `http://0.0.0.0:4000/auth/github/callback`

Click `Register application` and leave the tab open--we'll need the Client Id and Secret in a moment.

__Envy__

Environment variables are absolutely pointless if we don't add the secrets they contain to our application's .gitignore. __Before we move on add a line with `config.env` to your .gitignore, then add and commit your changes!__

Once you're sure git isn't going to push your secrets to Github, create a `config.env` in your project's root and add your OAuth Client ID and Secret with the following format:

```
GITHUB_SECRET=<your secret key here>
GITHUB_CLIENT_ID=<your client id here>
```

The Envy configuration is a little different to Ueberauth in that it takes place in the application file (`lib/ptodos/application.ex`) rather than `config.exs`.

Open `application.ex` and add the following:

![envy-setup](https://user-images.githubusercontent.com/22300773/29937760-86acc804-8e7e-11e7-886b-d450175a54a0.png)

I'll quickly run through the code line by line:

```iex
unless Mix.env == :prod do # this stops the .env from loading in production
Envy.load(["config.env"]) # load the environment variables with Envy
Envy.reload_config() # force Elixir to reload with the new variables
end # end...
```
