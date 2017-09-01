## Todo app features

* Todos - sets of todos that users can create, edit and delete
* Todo lists - collections of todos that users can create, edit and delete
* OAuth - OAuth authentication to handle ownership of todos

## A note on documentation

Both Phoenix and Elixir have __amazing__ documentation. Because of this,
wherever possible, instead of introducing and explaining new topics we'll just
provide a link to the appropriate documentation.

If at any point you get stuck your first port of call should be the docs. If all
you learn from this guide is how to find things in the Phoneix documentation
then that's still a big win! :tada:

## First steps

### Install Postgresql, Elixir and Phoenix

Both Phoenix and Elixir have great installation instructions for Mac, Windows,
Linux and even Raspberry Pi. The [Phoenix installation instructions](https://hexdocs.pm/phoenix/installation.html) contains links
to the other sites so should do fine.

Raise an issue if you have any trouble installing and we'll get back to you as
soon as possible :blush:.

### Create a new Phoenix project
Run `mix phx.new ptodos`.

This creates a new `ptodos` directory populated with a simple Phoenix server
setup.

__For users coming from before version 1.3: Where's my web folder!?__

The launch of 1.3 included some pretty major changes to server file structure.
The web folder - where most of the Phoenix code live - used to sit in the
project root. Instead, it's now located in `/lib/<projectname>_web`.

For a more comprehensive list of changes, and some info on the reasoning
behind the changes either
[read this overview on medium](https://medium.com/wemake-services/why-changes-in-phoenix-1-3-are-so-important-2d50c9bdabb9)
or watch
[this video from ElixirConf 2017 (not very beginner friendly but super informative)](https://www.youtube.com/watch?v=tMO28ar0lW8).

### Build the database
Run `mix Ecto.create`

[Ecto](https://hexdocs.pm/ecto/Ecto.html) is an Elixir module for talking to and
updating databases. By default Phoenix uses Postgresql with Ecto, but it can
be hooked up to a wide variety of databases.

If there's an error complaining about your postgres username & password, check
the information in `config/dev.exs` matches your postgres login details.

If you've lost or don't know your password, try following
[this Stack Overflow solution](https://stackoverflow.com/questions/35785892/ecto-postgres-install-error-password-authentication-failed#answer-37375810).

### Briefly run through migrations/schemas/repo


## Add a route to display todos

Our first step is to add a route to our server for displaying and manipulating
todos. To accomplish this, a new table will need to be added to our database and
Phoenix will need to be given instructions on how to communicate with this
table. We'll also start to explore templating with Phoenix (serving dynamic html
pages).

### Generate a todos route
Run `mix phx.gen.html Todos Todo todos title:string`.

This creates a set of files that do some of the initial heavy lifting for us.
Specifically the `.html` part tells Phoenix that we want the content to be in
the format of html via Phoenix templating. There's also `.json` for API routes
and `context`/`schema` for just database stuff.

To find out what the heck `phx.gen.html` is doing, head over to
[the Phoenix docs!](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Html.html#content)

Once you've run the command, in the terminal after the generation logs, there
should be a prompt about the new files:

> Add the resource to your browser scope in lib/todos_web/router.ex:<br><br>
    resources "/todos", TodoController

### Do the router thing
Following the hint above, add the new `todos` route to the router
(`/lib/ptodos_web/router.ex`) :sparkles:

>__The router__
is where you tell your Phoenix application how to handle requests. To
find out more (you guessed it) head over to the
[Phoenix routing guide](https://hexdocs.pm/phoenix/routing.html).

So following the instructions from the generator prompt we can add
`resources "/todos", TodoController` to our router, just underneath the line
with a PageController: `get "/", PageController, :index`

### Add the new todos table to the database
Run `mix ecto.migrate` to add the new todos tables to postgres. We'll learn how
to add our own migrations (changes to the database) later in this guide.

### Run the server
Use `mix phx.server` to run the server. Phoenix ships with live reloading so
generally while coding you can just leave the server running in the command line
and it'll refresh whenever you make changes. The only time this isn't the case
is when you make changes to your dependencies or sometimes with databasae
related stuff. To close the server just hit `ctrl+c` a couple times.

To access server functions from the command line without actually running the
server (great for debugging) use `iex -S mix`

Once your server is up and running head over to http://0.0.0.0:4000/todos to see
our new route in the browser :sparkles:

Double check that it all works by adding, editing and removing a todo.

### HELP WANTED!!
A section on the relationship between the router, controllers and templates
would be amazing here. If anyone has the time to type one up that would be super
useful. For the moment the Phoenix router guide linked above contains most of
the relevent info.

### Time for some cleanup!

#### Remove the show template
Because the todo app's purpose is just displaying a list of tickable todos, we
don't really want individual pages for each one. To remove this feature we'll
need to get rid of the `show` template and controller.

Routers and controllers in Phoenix by default follow RESTful naming conventions
([see here for more information](https://hexdocs.pm/phoenix/routing.html#resources)).

Our first step is to removing the `show.html.eex` template file from `lib/ptodos_web/templates/todo`.

Once the template is removed, we'll also need to take out the show function from
the todo_controller (`lib/ptodos_web/controllers/todo_controller.ex`).

#### Remove all links and redirects to the show route

First remove the show button from the `index.html.eex` template.

This:

```elixir
<td class="text-right">
  <span><%= link "Show", to: todo_path(@conn, :show, todo), class: "btn btn-default btn-xs" %></span>
  <span><%= link "Edit", to: todo_path(@conn, :edit, todo), class: "btn btn-default btn-xs" %></span>
  <span><%= link "Delete", to: todo_path(@conn, :delete, todo), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %></span>
</td>
```

Should become this:

```elixir
<td class="text-right">
  <span><%= link "Edit", to: todo_path(@conn, :edit, todo), class: "btn btn-default btn-xs" %></span>
  <span><%= link "Delete", to: todo_path(@conn, :delete, todo), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %></span>
</td>
```

Next, within the todo_controller we'll need to change how the `update` function
redirects. At the moment when a todo is successfully edited, the app tries to
redirect to the `show` page for that todo. Instead, it should just redirect back
to the index route where all todos are listed.

Have a look inside the `{:ok, todo}` case within the `update` function and
change the redirect to the following:

```elixir
redirect(to: todo_path(conn, :index))
```

The `create` function will need the same fix.

#### Remove the annoying 'are you sure' confirmation popup for deleting todos

Todos should be really easy to manipulate so let's remove the popup alert from `index.html.eex`. It's a super easy fix, just delete
` data: [confirm: "Are you sure?"],`.

#### Remove the Phoenix branding from the app layout

The layout file (`templates/layout/app.html.eex`) holds all html content that's
shared between many pages. For example css imports and html headers usually sit
in there.

By default Phoenix also includes a big logo and a link to 'Get Started' with
Phoenix. Lets trash this.

Delete everything inside the <header> tags to clean it up.

### Test the app

Run `mix phx.server` to test the app.

Hopefully if you head over to http://0.0.0.0:4000/todos and add a new todo
it'll look something like this:

![OMG it worked!](https://user-images.githubusercontent.com/22300773/29921885-51e9e594-8e4b-11e7-8415-f7e73c722e50.png)

## OAuth authentication

Next we'll add OAuth user authentication so our todos can only be changed by
their owners. To accomplish this we'll be using the Elixir
[Ueberauth module](https://github.com/ueberauth/ueberauth) with the
[Github OAuth strategy](https://github.com/ueberauth/ueberauth_github). New
modules can be added to a project by including them in the `mix.exs` and
installing with `mix deps.get`. OAuth also requires some hidden keys that we
don't want pushed up to version control (Github, etc.) - for this we'll be using
[Envy](https://github.com/BlakeWilliams/envy) to automatically load environment
variables.

#### Installing the dependencies

Hop into mix.exs and add `:ueberauth` and `:ueberauth_github` to
`extra_applications`:

![extra_applications](https://user-images.githubusercontent.com/22300773/29924988-d0304744-8e56-11e7-9c47-6c78b610e8a4.png)

We'll also need to add all three modules to our dependencies list. At the time
of writing (Aug 2017) the version numbers in the picture below are all up to
date. To be on the safe side have a quick Google to check there aren't any newer
versions available.

![dependencies](https://user-images.githubusercontent.com/22300773/29925540-7f452b36-8e58-11e7-9a8f-1a80a15f0be5.png)

#### Configuring the dependencies

Both Ueberauth and Envy require some additional configuration.

__Ueberauth__

Ueberauth is an amazing module that does a ton of authentication setup behind
the scenes. Unfortunately it doesn't quite do __everything__. We need to provide
it with some info about our application setup: which OAuth providers to use, and
the OAuth _client id_ and _secret_.

The first step's easy because we only need to add one provider -- Github OAuth.
Open up `config/config.exs` and chuck the following code at the end of the file:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    github: { Ueberauth.Strategy.Github, [] }
  ]
```

In the next few steps we'll connect Envy to a `.env` file containing our Github
OAuth information. For the moment it's fine to just point Ueberauth at some
non-existent __GITHUB_SECRET__ and __GITHUB_CLIENT_ID__ environment variables.
Add the following right underneath the previous code block:   

```elixir
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
 client_id: System.get_env("GITHUB_CLIENT_ID"),
 client_secret: System.get_env("GITHUB_SECRET")
```

__Github__

For OAuth to work, the application needs to be registered on the provider's
website. Log in to Github and point the browser to
https://github.com/settings/developers

Hit `Register a new application` and fill in the form with with the following
details:

| Field | Answer |
|---|---|
|__Application name:__| `Phoenix Todos` |
|__Homepage URL (your site or a temporary address):__| `http://0.0.0.0:4000`|
|__Application description:__| `[optional]`|
|__Authorization callback URL:__| `http://0.0.0.0:4000/auth/github/callback`|

Click `Register application` and leave the tab open - we'll need the Client Id
and Secret in a moment.

__Envy__

Environment variables are absolutely pointless if we don't add the secrets they
contain to our application's .gitignore.

__Before moving on add a line with `*.env` to your .gitignore, then add and
commit your changes!__

Once you're sure git isn't going to push your secrets to Github, create a
`config.env` in the project root and add your OAuth Client ID and Secret with
the following format:

```
GITHUB_SECRET=<your secret key here>
GITHUB_CLIENT_ID=<your client id here>
```

The Envy configuration is a little different to Ueberauth in that it takes place
in the application file (`lib/ptodos/application.ex`) rather than `config.exs`.

Open `application.ex` and add the following:

![envy-setup](https://user-images.githubusercontent.com/22300773/29937760-86acc804-8e7e-11e7-886b-d450175a54a0.png)

I'll quickly run through the code line by line:

```elixir
unless Mix.env == :prod do # this stops the .env from loading in production
  Envy.load(["config.env"]) # load the environment variables with Envy
  Envy.reload_config() # force Elixir to reload with the new variables
end # end...
```
