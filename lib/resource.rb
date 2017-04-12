require 'extensions'
require 'log'
require 'puppet'

class Resource
  class ResourceError < StandardError
    def initialize(msg)
      super("Invalid resource - #{msg}")
    end
  end

  attr_reader :title
  attr_reader :type
  attr_reader :name
  attr_reader :expected_properties
  attr_reader :puppet_resource

  def initialize(title, properties)
    if title.to_s =~ /^([A-Z].+)\[(.+)\]$/
      @type = $1.to_s.downcase.to_sym
      @name =$2.to_s.gsub(/'|"/, '')
    else
      raise ResourceError, "invalid resource title - #{title}"
    end

    @title = title
    @expected_properties = properties

    @compare_fn = lambda do |name, expected, actual|
      if name == :ensure
        if expected == 'present'
          return actual != :absent
        end

        if expected == 'absent'
          expected = expected.to_sym # user can express it as 'absent' or :absent
        end
      end

      expected == actual
    end

    create_resource
  end

  def check_properties
    result = { :success => true,
               :title => @title,
               :properties => [] }
    @expected_properties.each do |property, value|
      status = @compare_fn.call(property, value, @puppet_resource[property])
      result[:success] = false unless status
      result[:properties] << { :name => property,
                               :expected => value,
                               :actual => @puppet_resource[property].to_s,
                               :success => status }
    end

    result
  end

  private

  def create_resource
    Log.debug { "Loading resource #{@title}"}
    start_time = Time.now
    if extension = Extensions[@type]
      Log.debug { "Found resource type '#{@type}' in extensions." }
      @puppet_resource = extension[:resource].call(@name)
      if extension[:compare_fn]
        Log.debug { "Loading custom compare function for resource - #{@title}"}
        @compare_fn = extension[:compare_fn]
      end
    else
      begin
        Log.debug { "Couldn't find resource type '#{@type}' in extensions. Creating Puppet resource." }
        @puppet_resource = Puppet::Resource.indirection.find("#{@type}/#{@name}")
      rescue Puppet::Error => e
        msg = "Cannot create resource type - '#{@type}'. Unkown error - #{e}"
        if e.message =~ /^.*Permission denied.*$/
          msg = "Insufficient permissions to create resource - #{@title}"
        elsif e.message =~ /^.*Could not find type.*$/
          msg = "Cannot create unknown resource type - '#{@type}'"
        end
        raise Resource::ResourceError, msg
      end
    end
    Log.debug { "Loaded resource #{@title} in #{Time.now - start_time}" }
  end
end
