require 'log'
require 'resource'

class Rule
  class RuleError < StandardError
    def initialize(msg)
      super("Invalid rule - #{msg}")
    end
  end

  VALID_KEYS = [:resources, 'resources',
                :description, 'description',
                :severity, 'severity'].freeze

  attr_reader :resources
  attr_reader :description
  attr_reader :severity

  def initialize(rule)
    if (invalid_keys = rule.keys - VALID_KEYS).size > 0
      raise RuleError, "invalid field(s) '#{invalid_keys.join(',')}'"
    end

    tmp_resources = rule[:resources] or rule['resources'] or
      raise RuleError, 'missing required field "resources"'
    @description = rule[:description] or rule['description'] or
                   raise RuleError, 'missing required field "description"'
    @severity = rule[:severity] or rule['severity']

    unless tmp_resources.is_a? Hash
      raise RuleError, 'resources field must be an Hash'
    end

    @resources = tmp_resources.map do |title, properties|
      Resource.new(title, properties)
    end
  end

  def check_resources
    result = { :description => @description,
               :severity => @severity,
               :success => true,
               :resources => [] }
    @resources.each do |resource|
      resource_result = resource.check_properties
      result[:resources] << resource_result
      result[:success] = false unless resource_result[:success]
    end
    result
  end
end
