import Config

config :medappointsys, MedAppointSys.Repo,
  database: "medappointsys_repo",
  username: "postgres",
  password: "u$3Rd3!t@13th",
  hostname: "localhost",
  log: false
  config :medappointsys, ecto_repos: [MedAppointSys.Repo]
