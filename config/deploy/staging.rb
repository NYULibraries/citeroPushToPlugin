require 'figs'
Figs.load(stage: "staging")
Figs.env.deploy_servers.each do |srvr|
  server srvr, :app, :web
end
set(:branch, ENV["GIT_BRANCH"].gsub(/remotes\//,"").gsub(/origin\//,""))
