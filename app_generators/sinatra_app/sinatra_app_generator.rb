class RubiGen::Commands::Create

  def run(command, relative_path = '')
    in_directory = destination_path(relative_path)
    logger.run command
    system("cd #{in_directory} && #{command}")
  end

end


class SinatraAppGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
  Config::CONFIG['ruby_install_name'])

  SINATRA_GIT_URL = 'git://github.com/sinatra/sinatra.git'

  default_options :author => nil

  attr_accessor :app_name, 
                :vendor, 
                :tiny, 
                :git, 
                :git_init, 
                :heroku, 
                :test_framework, 
                :view_framework, 
                :install_scripts, 
                :cap, 
                :actions,
                :middleware,
                :bin_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    self.app_name = base_name
    extract_options
    parse_actions(args)
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory ''
      
      if git_init
        m.run("#{git} init")
      end      

      m.template 'config.ru.erb', 'config.ru'
      m.template 'Rakefile.erb' , 'Rakefile'
      
      test_dir = (tests_are_specs? ? 'spec' : 'test')
      
      unless tiny
        BASEDIRS.each { |path| m.directory path }
        m.directory test_dir
        m.file     'config.yml', 'config.yml'
        m.template 'lib/app.rb.erb', "lib/#{app_name}.rb"
        m.template 'test/test_helper.rb.erb', "#{test_dir}/#{test_dir}_helper.rb"
        m.template "test/test_app_#{test_framework}.rb.erb", 
                   "#{test_dir}/#{(tests_are_specs? ? "#{app_name}_spec" : "test_#{app_name}")}.rb"
        m.template "views/#{view_framework}_index.erb", "views/index.#{view_framework}"
        m.template "views/#{view_framework}_layout.erb", "views/layout.#{view_framework}" unless view_framework == 'builder'
      else
        m.template "lib/app.rb.erb", "#{app_name}.rb"
      end

      if options[:bin]
        m.directory "bin"
        m.template "bin/app.erb", "bin/#{bin_name}", {:chmod => 0755}
      end

      if vendor
        m.directory 'vendor'
        if git_init || File.exists?(File.join(@destination_root, '.git'))
          command = "#{git} submodule add #{SINATRA_GIT_URL} vendor/sinatra"
        else         
          command = "#{git} clone #{SINATRA_GIT_URL} vendor/sinatra"
        end
        m.run(command)
      end

      if cap
        m.directory 'config'
        m.file 'Capfile', 'Capfile'
        m.template 'config/deploy.rb.erb', 'config/deploy.rb'
      end

      if install_scripts
        m.dependency "install_rubigen_scripts", [destination_root, 'sinatra-gen'], :shebang => options[:shebang], :collision => :force
      end
      
      if heroku
        m.run("#{heroku} create #{app_name}")
      end
      
    end
  end

  protected
  def banner
    <<-EOS
    Creates the skeleton for a new sinatra app

    USAGE: sinatra-gen app_name [options] [paths]
    EOS
  end

  def add_options!(opts)
    opts.separator ''
    opts.separator 'Options:'

    opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    opts.on("-d", "--vendor", "Extract the latest sinatra to vendor/sinatra") {|o| options[:vendor] = o }
    opts.on("--tiny", "Only create the minimal files.") {|o| options[:tiny] = o }
    opts.on("--init", "Initialize a git repository") {|o| options[:init] = o }
    opts.on("--heroku", "Create a Heroku app (also runs 'git init').\n Optionally, specify the path to the heroku bin") { |o| options[:heroku] = o }
    opts.on("--cap", "Adds config directory with basic capistrano deploy.rb") {|o| options[:cap] = o }
    opts.on("--scripts", "Install the rubigen scripts (script/generate, script/destroy)")  {|o| options[:scripts] = o }
    opts.on("--git /path/to/git", "Specify a different path for 'git'") {|o| options[:git] = o }
    opts.on("--test=test_framework", String, "Specify your testing framework (bacon (default)/rspec/spec/shoulda/test)") {|o| options[:test_framework] = o }
    opts.on("--views=view_framework", "Specify your view framework (haml (default)/erb/builder)")  {|o| options[:view_framework] = o }
    opts.on("--middleware=rack-middleware", Array, "Specify Rack Middleware to be required and included (comma delimited)") {|o| options[:middleware] = o }
    opts.on("--vegas=[bin_name]", "--bin=[bin_name]", "Create an executable bin using Vegas. Pass an optional bin_name") {|o| options[:bin] = true; options[:bin_name] = o }
  end

  def extract_options
    # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
    # Templates can access these value via the attr_reader-generated methods, but not the
    # raw instance variable value.
    self.vendor          = options[:vendor]
    self.tiny            = options[:tiny]
    self.cap             = options[:cap]
    self.git             = options[:git] || `which git`.strip
    self.heroku          = options[:heroku] ? `which heroku`.strip : false
    self.git_init        = options[:init] || !!heroku || false
    self.test_framework  = options[:test_framework] || 'bacon'
    self.view_framework  = options[:view_framework] || 'haml'
    self.install_scripts = options[:scripts] || false
    self.middleware      = options[:middleware] ? options[:middleware].reject {|m| m.blank? } : []
    self.bin_name        = options[:bin_name] || app_name
  end

  def klass_name
    app_name.classify
  end

  def app_klass
    tiny ? "Sinatra::Application" : klass_name
  end

  def parse_actions(*action_args)
    @actions = action_args.flatten.collect { |a| a.split(':', 2) }
  end
  
  def tests_are_specs?
    ['rspec','spec','bacon'].include?(test_framework)
  end

  # Installation skeleton.  Intermediate directories are automatically
  # created so don't sweat their absence here.
  BASEDIRS = %w(
                lib
                public
                views
                )
end