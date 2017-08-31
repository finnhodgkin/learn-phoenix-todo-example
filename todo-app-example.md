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

### Time for some cleanup!

We don't want the application to have individual pages for each todo so the first step is to remove the show.html.eex template file from `lib/ptodos_web/templates/todo` and the `show` function from `lib/ptodos_web/controllers/todo_controller.ex`

We'll also need to remove the show button from index template:

This:

```iex
<td class="text-right">
  <span><%= link "Show", to: todo_path(@conn, :show, todo), class: "btn btn-default btn-xs" %></span>
  <span><%= link "Edit", to: todo_path(@conn, :edit, todo), class: "btn btn-default btn-xs" %></span>
  <span><%= link "Delete", to: todo_path(@conn, :delete, todo), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %></span>
</td>
```

Should become:

```iex
<td class="text-right">
  <span><%= link "Edit", to: todo_path(@conn, :edit, todo), class: "btn btn-default btn-xs" %></span>
  <span><%= link "Delete", to: todo_path(@conn, :delete, todo), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %></span>
</td>
```
