server "primodev1.bobst.nyu.edu", :app, :web
server "primodev2.bobst.nyu.edu", :app, :web
set(:branch, 'devel') unless exists?(:branch)
