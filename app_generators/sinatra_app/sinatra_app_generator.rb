class SinatraAppGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  default_options :author => nil

  attr_accessor :app_name, :vendor, :tiny, :git, :git_init, :test_framework

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    self.app_name = base_name
    extract_options
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory ''      

      if git_init
        `cd #{@destination_root} && #{git} init`
      end
      
      m.template 'config.ru.erb', 'config.ru'
      m.template 'app.rb.erb'   , 'app.rb'
      m.template 'Rakefile.erb' , 'Rakefile'
      # m.dependency "install_rubigen_scripts", [destination_root, 'sinatra-gen'],
      #   :shebang => options[:shebang], :collision => :force
      
      unless tiny
        BASEDIRS.each { |path| m.directory path }
        m.template 'lib/module.rb.erb', "lib/#{app_name}.rb"
        m.template 'test/test_helper.rb.erb', 'test/test_helper.rb'
        m.template "test/test_app_#{test_framework}.rb.erb", "test/test_#{app_name}.rb"
      end
      
      if vendor
        m.directory 'vendor'
        if git_init || File.exists?(File.join(@destination_root, '.git'))
          command = "cd #{@destination_root} && #{git} submodule add git://github.com/bmizerany/sinatra.git vendor/sinatra"
        else
          command = "cd #{@destination_root} && #{git} clone git://github.com/bmizerany/sinatra.git vendor/sinatra"
        end
        `#{command}`
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
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |options[:author]| }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
      opts.on("-d", "--vendor", "Extract the latest sinatra to vendor/sinatra") {|o| options[:vendor] = o }
      opts.on("-t", "--tiny", "Only create the minimal files.") {|o| options[:tiny] = o }
      opts.on("-i", "--init", "Initialize a git repository") {|o| options[:init] = o }
      opts.on("--git /path/to/git", "Specify a different path for 'git'") {|o| options[:git] = o }
      opts.on("--test=test_framework", String, "Specify your testing framework (rspec/spec/shoulda/unit). default = unit") {|o| options[:test_framework] = o }
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      self.vendor         = options[:vendor]
      self.tiny           = options[:tiny]
      self.git            = options[:git] || `which git`.strip
      self.git_init       = options[:init]
      self.test_framework = options[:test_framework] || 'unit'
    end

    def klass_name
      app_name.classify
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