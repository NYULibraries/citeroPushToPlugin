require 'figs'
Figs.load(stage: "production")
Figs.env.deploy_servers.each do |srvr|
  server srvr, :app, :web
end
set(:branch, 'master') unless exists?(:branch)
