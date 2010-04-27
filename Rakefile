$:.unshift File.expand_path('lib')

# load given tasks file, reporting errors without failing
def load_tasks(tasks)
  load tasks
rescue Exception => exception
  $stderr << "** loading #{tasks.sub(File.expand_path('.'),'')} failed: "
  case exception
  when LoadError
    $stderr << "to use, install the gems it requires\n"
  else
    $stderr << ([exception.message] + exception.backtrace[0..2]).join("\n    ") << "\n\n"
  end
end

Dir["Rakefile.d/*.rake"].sort.each {|t| load_tasks t}

task :default => :spec

task :ci => ['rcov:verify', 'cucumber']
