require 'log'

class Extensions
  @@extensions = {}

  def self.[](extension_name)
    @@extensions[extension_name]
  end

  def initialize(location = File.join(File.dirname(__FILE__), 'extensions'))
    validate_location(location)
    @location = File.join(location, '*.rb')
    load_extensions
  end

  private

  def load_extensions
    extension_files = Dir.glob(@location)
    extension_files.each do |extension_file|
      next if File.directory?(extension_file)
      begin
        Log.debug { "Loading extension file - #{extension_file}"}
        instance_eval(File.read(extension_file))
        Log.debug { "Successfully loaded extension file - #{extension_file}"}
      rescue Exception => e
        Log.debug { "Error in extension #{extension_file} - #{e}" }
        raise "Cannot load extension file '#{extension_file}'"
      end
    end
  end

  def create_resource(name, &block)
    @@extensions[name] ||= {}
    @@extensions[name][:resource] = block
  end

  def compare_fn(name, &block)
    @@extensions[name] ||= {}
    @@extensions[name][:compare_fn] = block
  end

  def validate_location(location)
    unless File.exist?(location)
      raise "Extensions directory '#{location}' does not exist"
    end

    unless File.directory?(location)
      raise "Extensions direcotry '#{location}' is not a directory"
    end
  end
end
