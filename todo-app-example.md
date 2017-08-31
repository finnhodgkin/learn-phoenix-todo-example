### Install Postgresql, Elixir and Phoenix

### Create a new Phoenix project
Run `mix phx.new ptodos`.

This creates a new `ptodos` directory with a simple Phoenix server.

### Build the database
Run `mix Ecto.create`

If it complains about your postgres username & password check the information in
config/dev.exs matches your postgres login details.

If you've lost or don't know your password, try following [this Stack Overflow solution](https://stackoverflow.com/questions/35785892/ecto-postgres-install-error-password-authentication-failed#answer-37375810).

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

### Explain the relationship between controllers, templates and the router.

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

### Add
