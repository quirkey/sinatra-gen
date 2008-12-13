# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = %q{sinatra-gen}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Quint"]
  s.date = %q{2008-12-13}
  s.default_executable = %q{sinatra-gen}
  s.description = %q{sinatra-gen generates a common file structure and basic app files for a web app utilizing the sinatra framework. For more information on sinatra, check out http://sinatra.rubyforge.org}
  s.email = ["aaron@quirkey.com"]
  s.executables = ["sinatra-gen"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "app_generators/sinatra_app/USAGE", "app_generators/sinatra_app/sinatra_app_generator.rb", "app_generators/sinatra_app/templates/Rakefile.erb", "app_generators/sinatra_app/templates/app.rb.erb", "app_generators/sinatra_app/templates/config.ru.erb", "app_generators/sinatra_app/templates/lib/module.rb.erb", "app_generators/sinatra_app/templates/test/test_app_rspec.rb.erb", "app_generators/sinatra_app/templates/test/test_app_shoulda.rb.erb", "app_generators/sinatra_app/templates/test/test_app_spec.rb.erb", "app_generators/sinatra_app/templates/test/test_app_unit.rb.erb", "app_generators/sinatra_app/templates/test/test_helper.rb.erb", "app_generators/sinatra_app/templates/views/builder_index.erb", "app_generators/sinatra_app/templates/views/erb_index.erb", "app_generators/sinatra_app/templates/views/erb_layout.erb", "app_generators/sinatra_app/templates/views/haml_index.erb", "app_generators/sinatra_app/templates/views/haml_layout.erb", "bin/sinatra-gen", "lib/sinatra-gen.rb", "test/test_generator_helper.rb", "test/test_helper.rb", "test/test_sinatra_app_generator.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/quirkey/sinatra-gen}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{sinatra-gen}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{sinatra-gen generates a common file structure and basic app files for a web app utilizing the sinatra framework}
  s.test_files = ["test/test_generator_helper.rb", "test/test_helper.rb", "test/test_sinatra_app_generator.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubigen>, [">= 1.3.3"])
      s.add_development_dependency(%q<newgem>, [">= 1.1.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<rubigen>, [">= 1.3.3"])
      s.add_dependency(%q<newgem>, [">= 1.1.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<rubigen>, [">= 1.3.3"])
    s.add_dependency(%q<newgem>, [">= 1.1.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
