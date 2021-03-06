## Todo app features

* Todos - sets of todos that users can create, edit and delete
* OAuth - OAuth authentication to handle ownership of todos

## Upcoming features

* Todo lists - collections of todos that users can create, edit and delete
* Live updates through sockets

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
The `web` folder, where most Phoenix code used to live, is now located in `/lib/<projectname>_web`.

For a more comprehensive list of changes and the reasoning behind them have a read of
[this overview on medium](https://medium.com/wemake-services/why-changes-in-phoenix-1-3-are-so-important-2d50c9bdabb9)
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

The first step is to add a route to the server for displaying and manipulating
todos. You'll need to add a todos table to the database and also give Phoenix some
instruction on how it should be accessed. The database content can then be
served up via Phoenix templates (dynamic html pages).

### Generate a todos route
Run `mix phx.gen.html Todos Todo todos title:string`.

This creates a set of files that do some of the initial heavy lifting for you.
Specifically the `.html` part tells Phoenix that we want the content to be in
the format of html via Phoenix templates. There's also `.json` for API routes,
`.channel` for Phoenix channels (sockets) and `context`/`schema` for
database-only stuff.

To find out what the heck `phx.gen.html` is doing, head over to
[the Phoenix docs!](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Html.html#content)

After running the command there should be a final prompt about the new files:

> Add the resource to your browser scope in lib/todos_web/router.ex:<br><br>
    resources "/todos", TodoController

### Do the router thing
Following the hint add the new `todos` route to the router
(`/lib/ptodos_web/router.ex`) :sparkles:

>__The router__
is where you tell your Phoenix application how to handle requests. To
find out more (you guessed it) have a look at the
[Phoenix docs on routing](https://hexdocs.pm/phoenix/routing.html).

Following the instructions from the generator prompt add
`resources "/todos", TodoController` to the router underneath the line
with a PageController: `get "/", PageController, :index`

### Add the new todos table to the database
Run `mix ecto.migrate` to add the new todos tables to postgres. Later sections  
of this guide will go into more detail about adding your own migrations (changes
to the database).

### Run the server
Use `mix phx.server` to run the server. Phoenix ships with live reloading so
generally while coding you can just leave the server running in the command line
and it'll refresh whenever you make changes. The only time this isn't the case
is when you make changes to your dependencies or to the database. If in doubt
just close the server by hitting `ctrl+c` twice and run `mix phx.server` to
start it up again.

To access server functions from the command line without actually running the
server (great for debugging) use `iex -S mix`.

Once your server is up and running head over to http://0.0.0.0:4000/todos to see
the new route in the browser :sparkles:

Double check it works by adding, editing and removing a todo.

### HELP WANTED!

A section on the relationship between the router, controllers and templates
would be amazing here. If anyone has the time to type one up that would be super
useful. For the moment the Phoenix router guide linked above contains most of
the relevent info.

### Time for some cleanup

#### Remove the show template

Because the todo app's purpose is to display a list of tickable todos,
there's no need for individual 'show' pages for each todo. To remove this feature
the `show` template and controller function will need to go.

Routers and controllers in Phoenix by default follow RESTful naming conventions
([see the docs here for more information](https://hexdocs.pm/phoenix/routing.html#resources)).

Remove the `show.html.eex` template file from
`lib/ptodos_web/templates/todo`.

Once the template is removed you'll also need to take out the show function from
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

Next, within the todo_controller change how the `update` function
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

Todos should be really super easy to manipulate so the next step is to remove
the popup alert from `index.html.eex`. It's a super easy fix, just delete
` data: [confirm: "Are you sure?"],`.

#### Remove the Phoenix branding from the app layout

The layout file (`templates/layout/app.html.eex`) holds all html content that's
shared between many pages, for example css imports and html headers. By default
Phoenix also includes a big logo and a link to 'Get Started' with
Phoenix. Lets trash this.

Delete everything inside and including the `<header>` tags to clean it up.

### Test the app

Run `mix phx.server` to test the app.

Hopefully if you head over to http://0.0.0.0:4000/todos and add a new todo
it'll look something like this:

![OMG it worked!](https://user-images.githubusercontent.com/22300773/29921885-51e9e594-8e4b-11e7-8415-f7e73c722e50.png)

## OAuth authentication

The next step is to add OAuth user authentication so todos can only be
changed by their owners. To accomplish this we'll be using the Elixir
[Ueberauth module](https://github.com/ueberauth/ueberauth) with the
[Github OAuth strategy](https://github.com/ueberauth/ueberauth_github). OAuth
requires some hidden keys that shouldn't be pushed up to version control
(Github, etc.) so you'll also need the [the Envy module](https://github.com/BlakeWilliams/envy).

You can install modules in Elixir by including them in the `mix.exs` file in the
project root and then running `mix deps.get`.

### Installing the dependencies

Hop into mix.exs and add `:ueberauth` and `:ueberauth_github` to
`extra_applications`:

![extra_applications](https://user-images.githubusercontent.com/22300773/29924988-d0304744-8e56-11e7-9c47-6c78b610e8a4.png)

You'll also need to add all three modules to the dependencies list. At the time
of writing (Aug 2017) the version numbers in the code below are all up to
date but to be on the safe side have a quick Google to check there aren't any
newer versions available.

```elixir
defp deps do
  [
    {:phoenix, "~> 1.3.0"},
    {:phoenix_pubsub, "~> 1.0"},
    {:phoenix_ecto, "~> 3.2"},
    {:postgrex, ">= 0.0.0"},
    {:phoenix_html, "~> 2.10"},
    {:phoenix_live_reload, "~> 1.0", only: :dev},
    {:gettext, "~> 0.11"},
    {:cowboy, "~> 1.0"},
    {:ueberauth, "~> 0.4"},
    {:ueberauth_github, "~> 0.4"},
    {:envy, "~> 1.1.1"}
  ]
end
```

### Configuring the dependencies

Both Ueberauth and Envy require some additional configuration.

__Ueberauth__

Ueberauth is an amazing module that does a ton of authentication setup behind
the scenes. Unfortunately it doesn't quite do __everything__. You'll need to
provide some info about the application setup: which OAuth providers to
use, and the OAuth _client id_ and _secret_.

The first step's easy because the app is only using one provider: Github OAuth.
Open up `config/config.exs` and chuck the following code at the end of the file:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    github: { Ueberauth.Strategy.Github, [] }
  ]
```

In the next section you'll connect Envy to a `config.env` file containing Github
OAuth information. For the moment it's fine to just point Ueberauth to some
non-existent __GITHUB_SECRET__ and __GITHUB_CLIENT_ID__ environment variables.
Add the following below the previous code block:   

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

Click `Register application` and leave the tab open - you'll need the Client Id
and Secret in a moment.

__Envy__

Environment variables are absolutely pointless if you don't add the secrets they
contain to the application's .gitignore.

__Before moving on add a line with `*.env` to your .gitignore.__

When you're sure git isn't going to push your secrets to Github, create a
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
OAuth handshake, but you still need to tell the router that Ueberauth exists, and
also how to handle authentication.

First `require` Ueberauth just after `use PtodosWeb, :router` at the top of
the router. If you're coming from the land of Node.js then this may look
familiar :sparkles:

Add an Auth scope:

```elixir
scope "/auth", PtodosWeb do
  pipe_through :browser

  get "/signout", AuthController, :signout
  get "/:provider", AuthController, :request
  get "/:provider/callback", AuthController, :callback
end
```

The `scope` tells Phoenix which requests should go where. For example
here it's saying that any url starting with "/auth" should be routed to the
contained `get`s in the AuthController. `:provider` is used because Ueberauth
can be set up to use multiple OAuth providers (Google, Facebook, Github, etc.).
More info on scopes [in the docs!](https://hexdocs.pm/phoenix/routing.html#scoped-routes)

Ptodos only uses Github OAuth so the only auth urls that'll actually work are
`/signout`, `/github` and `/github/callback`.

### Add authentication controllers

Ueberauth handles the `/github` route, but you'll need to add your own signout
and callback controllers to handle adding users to the database, etc.

Create an `auth_controller.ex` file in
`/lib/ptodos_web/controllers/auth_controller.ex`.

Just like the `page_controller` and `todo_controller`, the auth controller will
need to be a module and use the `PtodosWeb, :controller`. It'll also need to
include a call to `plug Ueberauth` to gain access to the Ueberauth module.

So to start add:

```elixir
defmodule PtodosWeb.AuthController do
  use PtodosWeb, :controller
  plug Ueberauth

end
```

> ___But where are the controllers?___

Start by defining the functions (controllers) inside the auth controller.
Ueberauth adds OAuth information to the connection under 'assigns', so add an
IO.inspect on conn.assigns to see what's going on, then redirect to the
todo index page.

```elixir
def callback(conn, _params) do
  IO.inspect conn.assigns
  redirect(conn, to: todo_path(conn, :index))
end

def signout(conn, _params) do
  conn
end
```

> ___But they don't do anything___ :woman_shrugging:

Let's work on the callback first. Hop over to `/github` to see if
Ueberauth redirects through Github correctly. If all's well it should take you
through login and then redirect to the todos index.

Take a look in the terminal and you'll see that Ueberauth has popped a bunch of
Github user information on `conn.assigns.ueberauth_auth`. For this app you'll
only need the user's name and email (both from
`conn.assigns.ueberauth_auth.info`).

Typing those long addresses multiple times is messy. Pattern matching to the
rescue:

```elixir
def callback(%{assigns: %{ueberauth_auth: %{info: %{email: email, name: name}}}} = conn, _params) do
```

Okay maybe that's still a bit messy :woman_shrugging:. This gives us access to
`email` and `name` within the callback controller. Now you have a user but
they're not stored in the database, and the browser won't 'remember' who the
user is if they navigate to a different page. Luckily Phoenix has a nice session
storage setup you can utilise.

But before that let's add `users` to the database.

> ___What about signout?___

Signout can wait until there's a working login :+1:.

### Add a users context

When the todos controller, context and templates were generated you used
`mix phx.gen.html`. For `users` there's no need for templates or controllers at
all: the app doesn't have a user control panel, just users in a database.

This time round just use
`mix phx.gen.context Users User users email:string name:string` to generate the
context with no templates - Phoenix won't touch `lib/ptodos_web` at all. Each
user should have an email and a name (the information pulled from OAuth).

Run `mix ecto.migrate` to add the users table to postgres.

### Add yourself to the database

First define a private function in the AuthController module that checks to see
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

Then in the AuthController callback function, call `insert_or_sign_user` and
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
the conn through a put_session call:

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

Removing a session is even easier:

```elixir
def signout(conn, _params) do
  conn
  |> put_flash(:info, "Signed out")
  |> configure_session(drop: true)
  |> redirect(to: todo_path(conn, :index))
end
```

### Authenticate the session for every request

Although the session is saved for logged in users, no check is made
against previously registerered users in the database (so no actual
authentication as of yet).

To fix this you'll need to add a module plug to the router. Plugs are pretty
central to Phoenix -
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

For login to function there needs to be a log in and log out button on every
page. Open up `app.html.ex` and add the following under the two `get_flash`
tags:

```elixir
<header>
  <div>
    <%= if @conn.assigns[:user] do %>
        <%= link "Logout", to: auth_path(@conn, :signout) %>
    <% else %>
        <%= link "Login with Github", to: auth_path(@conn, :request, "github") %>
    <% end %>
  </div>
</header>
```

`if @conn.assigns[:user]` checks to see if the user is authenticated and
displays either a Login or Logout button. Although it's possible to just use
`<a>` html tags to point at `/auth/github` and `/auth/signout`, using links
gives more control because they continue to work even if the route url is
changed.

Hit the link to log in and log out :tada:

### Add todo ownership

To stop users from editing other user's todos, the `todos` and `users` tables
need to be linked. Ecto/Phoenix have a great system for managing this.

First generate a migration (`mix ecto.gen.migration adds_user_id_to_todos`) to
add a `user_id` column to the todos table. This creates a new migration file in
`/priv/repo/migrations`. Open the new file and add a `:user_id` column to the
todos table:

```elixir
alter table(:todos) do
  add :user_id, references(:users)
end
```

As well as making the database `:user_id` reference `:users`, Phoenix also
needs to know how the tables are connected. In `todo.ex` and `user.ex` add the
following:

```elixir
schema "todos" do
  field :title, :string
  belongs_to :user, Ptodos.Users.User
#...

def changeset(%Todo{} = todo, attrs) do
  todo
  |> cast(attrs, [:title, :user_id])
  |> validate_required([:title, :user_id])
end
```
and
```elixir
schema "users" do
  field :email, :string
  field :name, :string
  has_many :todos, Ptodos.Todos.Todo
#...
```

Run `mix ecto.migration` to add the new column.

### Hide create todo from un-authenticated users

Instead of having a whole new page for adding todos, it makes sense to just have
an input at the bottom of the list. Copy the form from `new.html.eex` to the
bottom of `index.html.eex` and delete `new.html.eex`. Wrap the form in the same
if block used above:

```elixir
<%= if @conn.assigns.user do %>
  <%= render "add_todo_form.html", Map.put(assigns, :action, todo_path(@conn, :create)) %>
<% end %>
```

The index template will need access to the todo changeset for the form to
function. Hop into the todo controller:

```elixir
def index(conn, _params) do
  todos = Todos.list_todos()
  changeset = Ptodos.Todos.change_todo(%Ptodos.Todos.Todo{})
  render(conn, "index.html", todos: todos, changeset: changeset)
end
```

### Add user_id to new todos

Whenever a todo is created the current user's id should be added. First in
`todos.ex` create_todo needs access to the user's id
([see the Ecto association docs for more info](https://hexdocs.pm/ecto/Ecto.html#module-associations)):

```elixir
def create_todo(attrs \\ %{}, user) do
  Ecto.build_assoc(user, :todos)
  |> Todo.changeset(attrs)
  |> Repo.insert()
end
```

The call to `create_todo/1` also needs to be changed to `create_todo/2` with
user details as the second argument:

```elixir
def create(conn, %{"todo" => todo_params}) do
  case Todos.create_todo(todo_params, conn.assigns.user) do
  #...
```

### Filter the todo list buttons by user

Wrap the buttons in `index.html.eex` in an if block to check for authenticated
users:

```elixir
<%= if @conn.assigns.user && @conn.assigns.user.id == todo.user_id do %>
  <td class="text-right">
    <span><%= link "Edit", to: todo_path(@conn, :edit, todo), class: "btn btn-default btn-xs" %></span>
    <span><%= link "Delete", to: todo_path(@conn, :delete, todo), method: :delete, class: "btn btn-danger btn-xs" %></span>
  </td>
<% end %>
```

### Stop sneaky users from bypassing authentication

Although un-authenticated users can't see the _edit_ and _delete_ buttons, they
could still delete todos by sending a well designed post request directly to the
`:delete` route. _Function plugs to the rescue_.

Add two new function plugs to the top of the todo controller:

```elixir
plug :authenticate when action in [:create, :edit, :delete, :update]
plug :check_owner when action in [:edit, :delete, :update]
```

Define the functions at the bottom of the controller:

```elixir
defp check_owner(%{params: %{"id" => id}} = conn, _params) do
  if Todos.get_todo!(id).user_id == conn.assigns.user.id do
    conn
  else
    conn
    |> put_flash(:error, "You don't own that resource.")
    |> redirect(to: todo_path(conn, :index))
    |> halt()
  end
end

defp authenticate(conn, _params) do
  if conn.assigns[:user] do
    conn
  else
    conn
    |> put_flash(:error, "Not logged in.")
    |> redirect(to: todo_path(conn, :index))
    |> halt()
  end
end
```

And that's authentication done :)

## Make todos the homepage

The default Phoenix homepage still displays for the index route. Delete the
page_controller, page template directory and page_view and hop into the
router to fix this. Remove the `get` PageController route and swap the `/todos`
path to `/`.

Yippee.


## Todo
1. User-owned lists to teach more in-depth database table integration.
1. An api route so todos can be marked as complete on the front-end without
a page refresh.
1. Customise the html/css to make it more dwyl (maybe tachyons?).
1. Stretch goal: channels for live updates.
