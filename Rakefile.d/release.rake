# tasks for building and releasing the software
require 'git'
require 'pickle/version'

task :build do
  system "gem build pickle.gemspec"
end

namespace :release do
  task :rubygems => :pre do
    system "gem push pickle-#{Pickle::VERSION}.gem"
  end
  
  task :github => :pre do
    tag = "v#{Pickle::VERSION}"
    git = Git.open('.')
    
    if (git.tag(tag) rescue nil)
      raise "** repo is already tagged with: #{tag}"
    end
    
    git.add_tag(tag)
    git.push('origin', tag)
  end
  
  task :pre => [:spec, :cucumber, :build] do
    git = Git.open('.')
    
    if File.exists?("Gemfile.lock") && File.read("Gemfile.lock") != File.read("Gemfile.lock.development")
      cp "Gemfile.lock", "Gemfile.lock.development"
      raise "** Gemfile.lock.development has been updated, please commit these changes."
    end
    
    if (git.status.changed + git.status.added + git.status.deleted).any?
      raise "** repo is not clean, try committing some files"
    end
    
    if git.object('HEAD').sha != git.object('origin/master').sha
      raise "** origin does not match HEAD, have you pushed?"
    end
  end
  
  task :all => ['release:github', 'release:rubygems']
end