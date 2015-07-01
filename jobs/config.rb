module Config
  @configFile = File.join(Dir.pwd, "application.yml")
  @config = nil

  def self.get
    if @config == nil
      begin
        @config = YAML.load_file(@configFile)
      rescue
        throw "Unable to find application config file: #{@configFile}.  Please configure and try again (see application-template.yml to get started)"
      end
    end

    @config
  end

end