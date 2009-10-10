require File.join(File.dirname(__FILE__), "test_generator_helper.rb")

class TestSinatraAppGenerator < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper

  def setup
    bare_setup
  end

  def teardown
    bare_teardown
  end

  def test_generate_app_without_options
    run_generator('sinatra_app', [APP_ROOT], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file 'views/layout.haml'
    assert_generated_file 'views/index.haml'
    assert_generated_file "spec/#{app_name}_spec.rb" do |test_contents|
      assert_match(/describe/, test_contents)
    end    
  end

  def test_generate_app_with_vendor_option
    run_generator('sinatra_app', [APP_ROOT, '--vendor'], sources)
    assert_basic_paths_and_files('spec')
    assert_directory_exists 'vendor/sinatra/lib'
  end
  
  def test_generate_app_with_tiny_option
    run_generator('sinatra_app', [APP_ROOT, '--tiny'], sources)
    assert_generated_file   'config.ru'
    assert_generated_file   "#{app_name}.rb"
    assert_generated_file   'Rakefile'
  end
  
  def test_generate_app_with_init_option
    run_generator('sinatra_app', [APP_ROOT, '--init'], sources)
    assert_basic_paths_and_files('spec')
    assert_directory_exists '.git'
  end

  def test_generate_app_with_heroku_option
    run_generator('sinatra_app', [APP_ROOT, '--heroku'], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file '.gems' do |contents|
      assert_match(/sinatra/, contents)
    end
    assert_directory_exists '.git'
    assert_generated_file   '.git/config' do |config_contents|
      assert_match(/\[remote "heroku"\]/, config_contents)      
    end
  end
  
  def test_generate_app_with_cap_option
    run_generator('sinatra_app', [APP_ROOT, '--cap'], sources)
    assert_basic_paths_and_files('spec')
    assert_directory_exists 'config'
    assert_generated_file   'Capfile'
    assert_generated_file   'config/deploy.rb' do |deploy_contents|
      assert_match(/set \:application, "#{app_name}"/, deploy_contents)
    end
  end
  
  def test_generate_app_with_rspec_test_option
    run_generator('sinatra_app', [APP_ROOT, '--test=rspec'], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file 'spec/spec_helper.rb' do |helper_contents|
      assert_match(/spec/, helper_contents)
    end
    assert_generated_file "spec/#{app_name}_spec.rb" do |test_contents|
      assert_match(/describe/, test_contents)
    end
  end
  
  def test_generate_app_with_spec_test_option
    run_generator('sinatra_app', [APP_ROOT, '--test=spec'], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file 'spec/spec_helper.rb' do |helper_contents|
      assert_match(/spec/, helper_contents)
    end
    assert_generated_file "spec/#{app_name}_spec.rb" do |test_contents|
      assert_match(/describe/, test_contents)
    end
  end
  
  def test_generate_app_with_shoulda_test_option
    run_generator('sinatra_app', [APP_ROOT, '--test=shoulda'], sources)
    assert_basic_paths_and_files('test')
    assert_generated_file 'test/test_helper.rb' do |helper_contents|
      assert_match(/test\/unit/, helper_contents)
      assert_match(/shoulda/, helper_contents)
    end
    assert_generated_file "test/test_#{app_name}.rb" do |test_contents|
      assert_match(/context/, test_contents)
    end
  end
  
  def test_generate_app_with_test_unit_option
    run_generator('sinatra_app', [APP_ROOT, '--test=unit'], sources)
    assert_basic_paths_and_files('test')
    assert_generated_file 'test/test_helper.rb' do |helper_contents|
      assert_match(/test\/unit/, helper_contents)
    end
    assert_generated_file "test/test_#{app_name}.rb" do |test_contents|
      assert_match(/def test/, test_contents)
    end
  end
  
  def test_generate_app_with_test_bacon_option
    run_generator('sinatra_app', [APP_ROOT, '--test=bacon'], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file 'spec/spec_helper.rb' do |helper_contents|
      assert_match(/bacon/, helper_contents)
    end
    assert_generated_file "spec/#{app_name}_spec.rb" do |test_contents|
      assert_match(/describe/, test_contents)
    end
  end

  def test_generate_app_with_integration_cucumber_option
    run_generator('sinatra_app', [APP_ROOT, '--integration=cucumber'], sources)
    assert_basic_paths_and_files('features')
    assert_basic_paths_and_files('features/support')
    assert_generated_file 'features/support/env.rb' do |env_contents|
      assert_match(/World/, env_contents)
    end
  end

  def test_generate_app_with_views_erb_option
    run_generator('sinatra_app', [APP_ROOT, '--views=erb'], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file "lib/#{app_name}.rb" do |app_contents|
      assert_match(/erb \:index/, app_contents)
    end
    assert_generated_file 'views/layout.erb'
    assert_generated_file 'views/index.erb'
  end
  
  def test_generate_app_with_views_haml_option
    run_generator('sinatra_app', [APP_ROOT, '--views=haml'], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file "lib/#{app_name}.rb" do |app_contents|
      assert_match(/haml \:index/, app_contents)
    end
    assert_generated_file 'views/layout.haml'
    assert_generated_file 'views/index.haml'
  end

  def test_generate_app_with_views_builder_option
    run_generator('sinatra_app', [APP_ROOT, '--views=builder'], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file "lib/#{app_name}.rb" do |app_contents|
      assert_match(/builder \:index/, app_contents)
    end
    assert_generated_file 'views/index.builder'
  end
  
  def test_generate_app_with_scripts_option
    run_generator('sinatra_app', [APP_ROOT, '--scripts'], sources)
    assert_basic_paths_and_files('spec')
    assert_directory_exists 'script'
    assert_generated_file 'script/destroy'
    assert_generated_file 'script/generate'
  end
  
  def test_generate_app_with_actions_and_no_options
    run_generator('sinatra_app', [APP_ROOT, 'get:/', 'post:/users/:id', 'put:/users/*'], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file "lib/#{app_name}.rb" do |app_contents|
      assert_match(/get '\/' do/, app_contents)
      assert_match(/post '\/users\/\:id' do/, app_contents)
      assert_match(/put '\/users\/\*' do/, app_contents)
    end
  end
  
  def test_generate_app_with_actions_and_options
    run_generator('sinatra_app', [APP_ROOT, 'get:/', 'post:/users/:id', '--tiny', 'put:/users/*'], sources)
    assert_generated_file   'config.ru'
    assert_generated_file   'Rakefile'
    assert_generated_file "#{app_name}.rb" do |app_contents|
      assert_match(/get '\/' do/, app_contents)
      assert_match(/post '\/users\/\:id' do/, app_contents)
      assert_match(/put '\/users\/\*' do/, app_contents)
    end
  end
  
  def test_generate_app_with_middleware
    run_generator('sinatra_app', [APP_ROOT, "--middleware", "rack/flash,Rack::Cache"], sources)
    assert_generated_file   'config.ru'
    assert_generated_file   'Rakefile'
    assert_generated_file "lib/#{app_name}.rb" do |app_contents|
      assert_match(/require \'rack\/flash\'/, app_contents)
      assert_match(/require \'rack\/cache\'/, app_contents)
      assert_match(/use Rack::Flash/, app_contents)
      assert_match(/use Rack::Cache/, app_contents)
    end
  end
  
  def test_generate_app_with_vegas_and_default_bin
    run_generator('sinatra_app', [APP_ROOT, '--vegas'], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file "bin/#{app_name}" do |app_contents|
      assert_match("Vegas::Runner.new(#{app_name.classify}, '#{app_name}')", app_contents)
    end
  end
  
  def test_generate_app_with_vegas_and_different_bin_name
    run_generator('sinatra_app', [APP_ROOT, '--vegas=other_bin'], sources)
    assert_basic_paths_and_files('spec')
    assert_generated_file "bin/other_bin" do |app_contents|
      assert_match("Vegas::Runner.new(#{app_name.classify}, 'other_bin')", app_contents)
    end
  end
  
  private
  def assert_basic_paths_and_files(spec_or_test = 'spec')
    assert_directory_exists 'lib'
    assert_directory_exists  spec_or_test
    assert_directory_exists 'public'
    assert_directory_exists 'views'
    assert_generated_file   'config.ru'
    assert_generated_file   'Rakefile'
    assert_generated_file   'config.yml'
    assert_generated_class  "lib/#{app_name}"
  end
    
  
  def sources
    [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))]
  end

  def app_name
    File.basename(APP_ROOT)
  end

  def generator_path
    "app_generators"
  end
end
