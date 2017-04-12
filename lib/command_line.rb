require 'optparse'

class CommandLine
  VALID_OUTPUT_FORMATS = [:graphic, :json, :yaml, :csv].freeze

  def self.parse!(options)
    OptionParser.new do |opts|
      opts.banner = 'Usage: probium my_policy.yaml [options]'

      opts.on('-o', '--output-format=FORMAT', 'Format in which to display policy report (graphic, json, yaml, csv)') do |of|
        if VALID_OUTPUT_FORMATS.include?(f = of.downcase.to_sym)
          options[:output_format] = f
        else
          options[:message] =  "Invalid output-format '#{of}'. Options are #{VALID_OUTPUT_FORMATS.join(', ')}"
          options[:state] = :fail
        end
      end

      opts.on('-e', '--extension-dir=PATH', 'Location of extension files') do |path|
        options[:extensions_path] = path
      end

      opts.on('-d', '--debug', 'Enable debug output') do
        options[:debug] = true
      end

      opts.on('--no-color', 'Disable color in output') do
        options[:color] = false
      end

      opts.on('-h', '--help', 'Print this help') do
        options[:message] = opts
        options[:state] = :exit
      end
    end.parse!
    options
  end

  def self.policy!
    policy_file = ARGV.shift
    unless policy_file
      raise StandardError, 'Missing required policy file as argument'
    end
    policy_file
  end
end
