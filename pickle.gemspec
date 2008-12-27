# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pickle}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ian White"]
  s.date = %q{2008-12-27}
  s.description = %q{Easy model creation and reference in your cucumber features}
  s.email = %q{ian.w.white@gmail.com}
  s.files = ["lib/pickle/injector.rb", "lib/pickle/parser.rb", "lib/pickle/session.rb", "lib/pickle/steps.rb", "lib/pickle.rb", "License.txt", "README.textile", "Todo.txt", "History.txt", "spec/lib/pickle_config_spec.rb", "spec/lib/pickle_injector_spec.rb", "spec/lib/pickle_parser_spec.rb", "spec/lib/pickle_session_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ianwhite/pickle/tree}
  s.rdoc_options = ["--title", "Pickle", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Easy model creation and reference in your cucumber features}
  s.test_files = ["spec/lib/pickle_config_spec.rb", "spec/lib/pickle_injector_spec.rb", "spec/lib/pickle_parser_spec.rb", "spec/lib/pickle_session_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
