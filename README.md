## Todo app features

* Todos - sets of todos that users can create, edit and delete
* Todo lists - collections of todos that users can create, edit and delete
* OAuth - OAuth authentication to handle ownership of todos

## A note on documentation

Both Phoenix and Elixir have __amazing__ documentation. Because of this,
wherever possible, instead of introducing and explaining new topics we'll just
provide a link to the appropriate documentation.

If at any point you get stuck, your first port of call should be the docs. If
all you learn from this guide is how to find things in the Phoneix documentation
then that's still a big win! :tada:

## First steps

### Install Postgresql, Elixir and Phoenix

An example of Phoenix and Elixir's great documentation is their exceptional
installation instructions for Mac, Windows, Linux and even Raspberry Pi. The
[Phoenix installation instructions](https://hexdocs.pm/phoenix/installation.html)
contain links to the other sites so should do fine.

Raise an issue if you have any trouble installing and we'll get back to you as
soon as possible :blush:.

### Create a new Phoenix project
Run `mix phx.new ptodos`.

This creates a new `ptodos` directory populated with a simple Phoenix server
setup.

__For users coming from before version 1.3: Where's my web folder!?__

The launch of 1.3 included some pretty major changes to server file structure.
The web folder - where most Phoenix codes lives - used to sit in the project
root. Instead, it's now located in `/lib/<projectname>_web`.

For a more comprehensive list of changes, and some info on the reasoning
behind the changes either
[read this overview on medium](https://medium.com/wemake-services/why-changes-in-phoenix-1-3-are-so-important-2d50c9bdabb9)
or watch
[this video from ElixirConf 2017 (not very beginner friendly but super informative)](https://www.youtube.com/watch?v=tMO28ar0lW8).

### Build the database
Run `mix Ecto.create`

[Ecto](https://hexdocs.pm/ecto/Ecto.html) is an Elixir module for talking to and
updating databases. By default Phoenix uses Postgresql with Ecto, but can
be hooked up to a wide variety of databases.

If you get an error about your postgres username & password when running
Ecto.create, check the information in `config/dev.exs` matches your postgres
login details.

If you've lost or don't know your password, try following
[this Stack Overflow solution](https://stackoverflow.com/questions/35785892/ecto-postgres-install-error-password-authentication-failed#answer-37375810).

## Add a route to display todos

Our first step is to add a route to our server for displaying and manipulating
todos. To accomplish this, a new table will need to be added to our database and
Phoenix will need some instructions on how to communicate with the table. We'll
also start to explore templating with Phoenix (serving dynamic html pages).

### Generate a todos route
Run `mix phx.gen.html Todos Todo todos title:string`.

This creates a set of files that do some of the initial heavy lifting for you.
Specifically the `.html` part tells Phoenix that we want the content to be in
the format of html via Phoenix templates. There's also `.json` for API routes,
`.channel` for Phoenix channels (sockets) and `context`/`schema` for just
database stuff.

To find out what the heck `phx.gen.html` is doing, head over to
[the Phoenix docs!](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Html.html#content)

Once you've run the command, in the terminal after the generation logs there
should be a prompt about the new files:

> Add the resource to your browser scope in lib/todos_web/router.ex:<br><br>
    resources "/todos", TodoController

### Do the router thing
Following the hint above add the new `todos` route to the router
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
stuff. If in doubt just close the server by hitting `ctrl+c` twice and start it
up again.

To access server functions from the command line without actually running the
server (great for debugging) use `iex -S mix`.

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
([see the docs here for more information](https://hexdocs.pm/phoenix/routing.html#resources)).

Our first step is to removing the `show.html.eex` template file from
`lib/ptodos_web/templates/todo`.

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

Todos should be really easy to manipulate so let's remove the popup alert from
`index.html.eex`. It's a super easy fix, just delete
` data: [confirm: "Are you sure?"],`.

#### Remove the Phoenix branding from the app layout

The layout file (`templates/layout/app.html.eex`) holds all html content that's
shared between many pages. For example css imports and html headers usually sit
in there.

By default Phoenix also includes a big logo and a link to 'Get Started' with
Phoenix. Lets trash this.

Delete everything inside and including the `<header>` tags to clean it up.

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

### Installing the dependencies

Hop into mix.exs and add `:ueberauth` and `:ueberauth_github` to
`extra_applications`:

![extra_applications](https://user-images.githubusercontent.com/22300773/29924988-d0304744-8e56-11e7-9c47-6c78b610e8a4.png)

We'll also need to add all three modules to our dependencies list. At the time
of writing (Aug 2017) the version numbers in the picture below are all up to
date. To be on the safe side have a quick Google to check there aren't any newer
versions available.

![dependencies](https://user-images.githubusercontent.com/22300773/29925540-7f452b36-8e58-11e7-9a8f-1a80a15f0be5.png)

### Configuring the dependencies

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

### Add an authentication router scope

Ueberauth comes with a bunch of pre-configured stuff that handles the actual
OAuth handshake, but we still need to tell our router that Ueberauth exists, and
also how to handle authentication.

First `require` Ueberauth just after `use PtodosWeb, :router` at the top of
the router. If you're coming from the land of Node.js then this will look
familiar :sparkles:

Next add an Auth scope:

```elixir
scope "/auth", PtodosWeb do
  pipe_through :browser

  get "/signout", AuthController, :signout
  get "/:provider", AuthController, :request
  get "/:provider/callback", AuthController, :callback
end
```

The `scope` is where we tell Phoenix which requests should go where. For example
here we're saying that any url starting with "/auth" will be routed to the
contained `get`s in the AuthController. `:provider` is used because Ueberauth
can be set up to use multiple OAuth providers (Google, Facebook, Github, etc.).
More info [in the docs!](https://hexdocs.pm/phoenix/routing.html#scoped-routes)

Ptodos only uses Github OAuth so the only auth urls that'll actually work are
`/signout`, `/github` and `/github/callback`.

### Add authentication controllers

Ueberauth handles the `/github` route, but we'll need to add our own signout and
callback controllers to handle adding users to the database, etc.

Create an `auth_controller.ex` file in
`/lib/ptodos_web/controllers/auth_controller.ex`.

Just like the `page_controller` and `todo_controller`, the auth controller will
need to be a module and use the `PtodosWeb, :controller`. We'll also need to
`plug Ueberauth` to gain access to OAuth stuff.

So to start add:

```elixir
defmodule PtodosWeb.AuthController do
  use PtodosWeb, :controller
  plug Ueberauth

end
```

> _But where are the controllers?_

Lets start by defining the functions (controllers) we'll need inside the auth
module. Ueberauth adds OAuth information to the connection under 'assigns', so
let's inspect assigns and redirect to the todo index page.

```elixir
def callback(conn, _params) do
  IO.inspect conn.assigns
  redirect(conn, to: todo_path(conn, :index))
end

def signout(conn, _params) do
  conn
end
```

> _But they don't do anything_ :woman_shrugging:

Let's work on the callback first. Hop over to `/github` to see if
Ueberauth redirects through Github correctly. If all is well it should take you
through login and then redirect to the todos index.

Take a look in the terminal and you'll see that Ueberauth has popped a bunch of
user information on `conn.assigns.ueberauth_auth`. For this app we'll only need
the user's name (from `conn.assigns.ueberauth_auth.user`) and unique id
(`conn.assigns.ueberauth_auth.info`).

Typing those long addresses multiple times is messy. Pattern matching to the
rescue:

```elixir
def callback(%{assigns: %{ueberauth_auth: %{info: %{email: email, name: name}}}} = conn, _params) do
```

This gives us access to email and name within the callback controller. Now we
have a user but they're not stored in our database, and the browser won't
'remember' who it is if you navigate to a different page. Luckily Phoenix has a
nice session storage setup we can utilise.

Before we get on to that, let's work on adding `users` to the database.

> _What about signout?_

We'll leave the signout controller until we've got a working login.

### Add a users context

When the todos controller, context and templates were generated we used
`mix phx.gen.html`. For `users` we don't need templates or controllers at all:
the app doesn't have a user control panel, just users in a database.

This time round just use
`mix phx.gen.context Users User users email:string name:string` to generate the
context with no templates - Phoenix won't touch `lib/ptodos_web` at all. We want
each user to have an email and a name (the information we pulled from OAuth).

Run `mix ecto.migrate` to add the users table to postgres.

### Add yourself to the database

First lets define a private function in AuthController module that checks to see
if a user exists in the database and adds them if they don't:

```elixir
defp insert_or_sign_user(user) do
  case Users.get_by_email(user.email) do
    nil ->
      Users.create_user(user)
    user ->
      {:ok, user}
  end
end
```

In the AuthController callback function we'll call this function and then
redirect with a welcome flash message (or error if something breaks):

```elixir
def callback(%{assigns: %{ueberauth_auth: %{info: %{email: email, name: name}}}} = conn, _params) do
  case insert_or_sign_user(%{email: email, name: name) do
    {:ok, user} ->
      conn
      |> put_flash(:info, "Welcome back!")
      |> redirect(to: todo_path(conn, :index))
    {:error, _reason} ->
      conn
      |> put_flash(:error, "Error signing in")
      |> redirect(to: todo_path(conn, :index))
  end
end
```

The Users context currently doesn't have a `get_by_email/1` function. To add it
hop over to `/lib/ptodos/users/users.ex` and define it:

```elixir
def get_by_email(email), do: Repo.get_by(User, email: email)
```

### Cookie time :cookie:

Adding a secure (encrypted) session cookie is super easy with Phoenix. Just pipe
the conn in the callback through a put_session call:

```elixir
def callback(%{assigns: %{ueberauth_auth: %{info: %{email: email, name: name}}}} = conn, _params) do
  case insert_or_sign_user(%{email: email, name: name}) do
    {:ok, user} ->
      conn
      |> put_flash(:info, "Welcome back!")
      |> put_session(:user_id, user.id)
      |> redirect(to: todo_path(conn, :index))
#...
```

### Create the signout controller

Removing a session is even easier than adding one:

```elixir
def signout(conn, _params) do
  conn
  |> put_flash(:info, "Signed out")
  |> configure_session(drop: true)
  |> redirect(to: todo_path(conn, :index))
end
```

### Authenticate the session for every request

Although the session is saved for logged in users, no check is being made
against registererd users in the database (no actual authentication as of yet).

To fix this we'll add a module plug to the router. Plugs are pretty central to
Phoenix -
[hop over to the docs to find out more](https://hexdocs.pm/phoenix/plug.html).

Add the about-to-be-created plug to the `:browser` pipeline in the router. This
pipeline is a series of steps (plugs) that a request (conn) goes through before
being sent back as a response.  

```elixir
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :fetch_flash
  plug :protect_from_forgery
  plug :put_secure_browser_headers
  plug PtodosWeb.Plugs.SetUser # our soon to be plug
end
```

Module plugs go in a `plugs` directory within `controllers`
(`/lib/ptodos_web/controllers/plugs`). Create a new `set_user.ex` module plug
and add the below code. I've commented each line to clarify exactly what's going
on.

```elixir
defmodule PtodosWeb.Plugs.SetUser do # define the module plug
  import Plug.Conn # Import the plug connection module

  alias Ptodos.Users # Give the plug access to our `users` database context

  def init(_params) do # Module plugs require an init function but it can be
  end # left blank if there's nothing to initialise

  def call(conn, _init_params) do
    user_id = get_session(conn, :user_id) # Get the user id stored on the cookie

    cond do
      user = user_id && Users.get_user(user_id) -> # If user_id then assign the
        assign(conn, :user, user) # user details from the database to the conn
      true ->
        assign(conn, :user, nil) # otherwise assign the user to nil in the conn
    end
  end
end
```

There's a problem with the code above, `gen.context` doesn't generate a
`Users.get_user`. Instead, it just has `get_user!`.

  > The `!` or _bang_ is kind of like 'throw' in javascript - it's used to
  identify functions that actually error, rather than just returning a tuple
  like `{:error, _reason}`.

The set_user plug can't _bang_ when there's no session because then non-logged
in users would just see an error page. To fix this, hop in to `users.ex` and
remove the `!`s from `get_user!` (remember to also change the examples in the
documentation and the `!` from `Repo.get!`):

```elixir
@doc """
...
## Examples

    iex> get_user(123)
    %User{}

    iex> get_user(456)
    ** (Ecto.NoResultsError)

"""
def get_user(id), do: Repo.get(User, id)
```

### Prove it works

First let's add a login/logout button to the layout so it's visible on every
page.
