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

  attr_accessor :app_name, :vendor, :tiny, :git, :git_init, :heroku, :test_framework, :view_framework, :install_scripts, :cap, :actions

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
      
      if heroku
        m.run("#{git} init")
        m.run("heroku create #{app_name}")
      end
      
      m.template 'config.ru.erb', 'config.ru'
      m.template 'app.rb.erb'   , "#{app_name}.rb"
      m.template 'Rakefile.erb' , 'Rakefile'
            
      unless tiny
        BASEDIRS.each { |path| m.directory path }
        m.file     'config.yml', 'config.yml'
        m.template 'lib/module.rb.erb', "lib/#{app_name}.rb"
        m.template 'test/test_helper.rb.erb', 'test/test_helper.rb'
        m.template "test/test_app_#{test_framework}.rb.erb", "test/test_#{app_name}.rb"
        m.template "views/#{view_framework}_index.erb", "views/index.#{view_framework}"
        m.template "views/#{view_framework}_layout.erb", "views/layout.#{view_framework}" unless view_framework == 'builder'
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
    end
  end

  protected
    def banner
      <<-EOS
Creates the skeleton for a new sinatra app

USAGE: #{spec.name} app_name
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
      opts.on("-d", "--vendor", "Extract the latest sinatra to vendor/sinatra") {|o| options[:vendor] = o }
      opts.on("--tiny", "Only create the minimal files.") {|o| options[:tiny] = o }
      opts.on("--init", "Initialize a git repository") {|o| options[:init] = o }
      opts.on("--heroku", "Creates app on Heroku (also does 'git init')") { |o| options[:heroku] = o }
      opts.on("--cap", "Adds config directory with basic capistrano deploy.rb") {|o| options[:cap] = o }
      opts.on("--scripts", "Install the rubigen scripts (script/generate, script/destroy)")  {|o| options[:scripts] = o }
      opts.on("--git /path/to/git", "Specify a different path for 'git'") {|o| options[:git] = o }
      opts.on("--test=test_framework", String, "Specify your testing framework (unit (default)/rspec/spec/shoulda/bacon)") {|o| options[:test_framework] = o }
      opts.on("--views=view_framework", "Specify your view framework (erb (default)/haml/builder)")  {|o| options[:view_framework] = o }
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      self.vendor          = options[:vendor]
      self.tiny            = options[:tiny]
      self.cap             = options[:cap]
      self.git             = options[:git] || `which git`.strip
      self.git_init        = options[:init] || false
      self.heroku          = options[:heroku]
      self.test_framework  = options[:test_framework] || 'unit'
      self.view_framework  = options[:view_framework] || 'erb'
      self.install_scripts = options[:scripts] || false
    end

    def klass_name
      app_name.classify
    end
    
    def parse_actions(*action_args)
      @actions = action_args.flatten.collect { |a| a.split(':', 2) }
    end

    # Installation skeleton.  Intermediate directories are automatically
    # created so don't sweat their absence here.
    BASEDIRS = %w(
      lib
      test
      public
      views
    )
end