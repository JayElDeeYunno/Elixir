import Config

config :medappointsys, MedAppointSys.Repo,
  database: "medappointsys_repo",
  username: "postgres",
  password: "123",
  hostname: "localhost",
  log: false
  config :medappointsys, ecto_repos: [MedAppointSys.Repo]
