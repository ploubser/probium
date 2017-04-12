require 'yaml'
require 'erb'
require 'command_line'
require 'extensions'
require 'result_viewer'
require 'policy'
require 'log'

class Runner
  attr_reader :exit_code

  def initialize
    @defaults = { :output_format => :graphic,
                  :extensions_path => File.join(File.dirname(__FILE__), 'extensions'),
                  :debug => false,
                  :color => true,
                  :state => :run,
                  :msg => nil }
    @options = CommandLine.parse!(@defaults)

    if msg = @options.delete(:message)
      puts msg
    end

    case @options.delete(:state)
    when :exit
      exit 0
    when :fail
      exit 1
    end

    if @options[:debug]
      Log.initialize
    end

    unless @options[:color]
      Rainbow.enabled = false
    end

    Log.debug { "Starting policy check with configured option - #{@options.inspect}" }

    @extensions = Extensions.new(@options[:extensions_path])
    policy_file = CommandLine.policy!
    @policies = load_policies(policy_file).map { |policy| Policy.new(policy) }
    @exit_code = 0
  end

  def run
    processed_policies = []

    @policies.each do |policy|
      if policy.enabled?
        processed_policies << policy.check_rules
      end
    end

    result_viewer = ResultViewer.new(processed_policies)

    if result_viewer.run_state[:successes] != result_viewer.run_state[:total]
      @exit_code = 1
    end

    case @options[:output_format]
    when :graphic
      result_viewer.to_s
    when :json
      result_viewer.to_json
    when :yaml
      result_viewer.to_yaml
    # TODO(ploubser): Fix this
    #when :csv
    #  result_viewer.to_csv
    end
  end

  private

  def load_policies(target_location)
    policies = []

    if File.directory?(target_location)
      Dir.glob(target_location + '/*').each do |policy_file|
        policies << load_policy_file(policy_file)
      end
    else
      policies << load_policy_file(target_location)
    end

    policies
  end

  def load_policy_file(policy_file)
    Log.debug { "Loading policy file - #{policy_file}" }

    unless File.exist?(policy_file)
      raise "Cannot find policy file - '#{policy_file}'"
    end

    policy = {}

    begin
      if policy_file =~ /^.*\.erb$/
        template = ERB.new(File.read(policy_file, 3, '>')).result
        policy = YAML.load(template)
      else
        policy = YAML.load_file(policy_file)
      end
    rescue StandardError => e
        Log.debug { e.message }
        raise "Invalid Policy file - '#{policy_file}'"
    end

    Log.debug { "Successfully loaded policy file - #{policy_file}"}

    policy
  end
end
