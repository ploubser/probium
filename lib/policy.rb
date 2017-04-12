require 'rule'
require 'facter'
require 'log'

class Policy
  include Enumerable
  extend Forwardable
  def_delegators :@rules, :each

  class PolicyError < StandardError
    def initialize(message)
      super("Invalid policy - #{message}")
    end
  end

  VALID_KEYS = [:name, 'name', :rules, 'rules', :confine, 'confine'].freeze

  attr_reader :rules
  attr_reader :name
  attr_reader :confines

  def initialize(policy)
    if (invalid_keys = policy.keys - VALID_KEYS).size > 0
      raise PolicyError, "invalid field(s) '#{invalid_keys.join(',')}'"
    end

    @name = policy[:name] or policy['name'] or raise PolicyError, 'missing required field "name"'
    @rules = policy[:rules] or policy['rules'] or raise PolicyError, 'missing required field "rules"'
    @confines = policy[:confine] or policy['confine']
    @confines ||= {}

    unless @rules.is_a?(Array)
      raise PolicyError, 'rules field must be an Array'
    end

    unless @rules.size > 0
      raise PolicyError, 'rules Array must contain at least one rule'
    end
  end

  def enabled?
    Log.debug { "Checking confine rules for policy - #{@name}" }

    @confines.each do |fact_name, value|
      if (fact_value = Facter.value(fact_name)) != value
        Log.debug { "Skipping policy '#{@name} - #{fact_name}: #{fact_value.inspect} != #{value.inspect}"}
        return false
      end
    end

    Log.debug { "Policy '#{@name}' passed all confine rules." }
    true
  end

  def check_rules
    # Delay loading rules until Policy is checked. Puppet resources are expensive
    # and we avoid it incase enabled? = false
    @rules.map! { |r| Rule.new(r) }

    result = { :name => @name,
               :success => true,
               :rules => [] }
    @rules.each do |rule|
      rule_result = rule.check_resources
      result[:rules] << rule_result
      result[:success] = false unless rule_result[:success]
    end

    result
  end
end
