# Call with cap -S branch="<branch-name>" [staging|production] deploy
require 'figs'
require 'capistrano/ext/multistage'


set :ssh_options, {:forward_agent => true}
set :application, "citeroPushToPlugin"
# Your Primo user
set :user, ENV['USER']
# Your javacompiler
set :javac, ENV['JAVAC']
# set(:servers)       { Figs.deploy_servers }
default_run_options[:shell] = '/bin/bash --login'

# Git variables
set :repository,  "git@github.com:NYULibraries/#{application}.git"
set :scm, :git
#Source code management username
set :scm_username, ENV['SCM_USERNAME']
set :deploy_via, :remote_cache
set :deploy_to, "/exlibris/primo/p4_1/ng/primo/home/profile/search/pushTo.v4"

# Environments
set :use_sudo, false
set :stages, ["staging", "production"]
set :default_stage, "staging"

namespace :deploy do
  desc <<-DESC
    No restart necessary for Primo.
  DESC
  task :restart do
    puts "Skipping restart."
  end

  desc <<-DESC
    No symlink creation necessary for Primo.
  DESC
  task :create_symlink do
    puts "Skipping symlink creation."
  end

  desc <<-DESC
    Copy the latest release to the custom directory since symlinks don't seem to work.
  DESC
  task :copy_latest_release do
    # Symlinks don't seem to work for with the web server so we copy the latest release.
    puts "Skip"
  end

  desc <<-DESC
    Touches up the released code. This is called by update_code after the basic \
    deploy finishes. Overrides internal implementation since the internal \
    implementation assumes rails.

    This task will make the release group-writable (if the :group_writable \
    variable is set to true, which is the default). It will copy the latest \
    release to the custom directory and cleanup the releases.
  DESC
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
    copy_latest_release
    # Compile the distribution assets
    run "rvm use 1.9.3"
    run "mkdir -p #{deploy_to}/library"
    run "cp -f #{latest_release}/src/main/java/edu/nyu/library/Citation* #{deploy_to}/library"

    classpath = "/exlibris/app/oracle/product/112/jdbc/lib/classes12.jar"
    classpath = "#{classpath}:/exlibris/primo/p4_1/ng/primo/home/system/thirdparty/jbossas/server/search/deploy/primo_library-app.ear/primo_library-libweb.war/WEB-INF/classes"
    classpath = "#{classpath}:/exlibris/primo/p4_1/ng/primo/home/system/thirdparty/jbossas/common/lib/servlet-api.jar"
    classpath = "#{classpath}:/exlibris/primo/p4_1/ng/primo/home/system/thirdparty/jbossas/server/search/lib/commons-beanutils.jar"
    classpath = "#{classpath}:/exlibris/primo/p4_1/ng/primo/home/system/thirdparty/jbossas/server/search/lib/xbean.jar"
    classpath = "#{classpath}:/exlibris/primo/p4_1/ng/primo/home/system/tomcat/search/webapps/primo_library#libweb/WEB-INF/lib/primo-library-common-4.5.0.jar"
    classpath = "#{classpath}:/exlibris/primo/p4_1/ng/primo/home/system/tomcat/search/webapps/primo_library#libweb/WEB-INF/lib/primo-common-infra-4.5.0.jar"
    classpath = "#{classpath}:/exlibris/primo/p4_1/ng/primo/home/system/tomcat/search/webapps/primo_library#libweb/WEB-INF/lib/jaguar-client-4.5.0.jar"

    run "#{javac} -cp '#{classpath}' /exlibris/primo/p4_1/ng/primo/home/profile/search/pushTo.v4/library/Citation*.java"

    run "mkdir -p /exlibris/primo/p4_1/ng/primo/home/system/thirdparty/jbossas/server/search/deploy/primo_library-app.ear/primo_library-libweb.war/WEB-INF/classes/edu/nyu/library/"
    run "mkdir -p /exlibris/primo/p4_1/ng/primo/home/system/tomcat/search/webapps/primo_library#libweb/WEB-INF/classes/edu/nyu/library/"

    run "cp -f #{deploy_to}/library/CitationProcess.class /exlibris/primo/p4_1/ng/primo/home/system/thirdparty/jbossas/server/search/deploy/primo_library-app.ear/primo_library-libweb.war/WEB-INF/classes/edu/nyu/library/"
    run "cp -f #{deploy_to}/library/CitationProcess.class /exlibris/primo/p4_1/ng/primo/home/system/tomcat/search/webapps/primo_library#libweb/WEB-INF/classes/edu/nyu/library/"

    run "mv #{deploy_to}/library/CitationProcess.java #{deploy_to}"
    run "rm -rf #{deploy_to}/library"
    run "rm -rf #{deploy_to}/releases"
    run "rm -rf #{deploy_to}/shared"

    run "echo \"All done\""
    cleanup
  end

  task :migrate do
    puts "Skip"
  end
end
