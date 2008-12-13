class SinatraAppGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  default_options :author => nil

  attr_accessor :app_name, :vendor, :tiny, :git

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

      if git
      end
      
      m.template 'config.ru.erb', 'config.ru'
      m.template 'app.rb.erb'   , 'app.rb'
      m.template 'Rakefile.erb' , 'Rakefile'
      # m.dependency "install_rubigen_scripts", [destination_root, 'sinatra-gen'],
      #   :shebang => options[:shebang], :collision => :force
      
      unless tiny
        BASEDIRS.each { |path| m.directory path }
        m.template 'lib/module.rb.erb', "lib/#{app_name}.rb"
      end
      
      if vendor

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
      opts.on("-g", "--git", "Initialize a git repository. If 'vendor' is used - will checkout with submodule. **Requires the git gem)") {|o| options[:git] = o }      
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      self.vendor = options[:vendor]
      self.tiny   = options[:tiny]
      self.git    = options[:git]
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