require 'yard'
  
YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/**/*.rb', 'rails_generators/**/*.rb']
end