require 'yaml'
require 'json'
require 'csv'
require 'rainbow'

class ResultViewer
  attr_reader :run_state

  def initialize(policies)
    @run_state = { :policies => policies,
                   :total => policies.size,
                   :successes => policies.reduce(0) { |count, policy| policy[:success] ? count + 1 : count } }
  end

  def to_s
    string_buffer = []
    string_buffer << "Total Policies: #{@run_state[:total]}"

    @run_state[:policies].each do |policy|
      string_buffer << stringify_policy(policy)
    end

    string_buffer << "Passed: #{@run_state[:successes]}/#{@run_state[:total]}"
    string_buffer.join("\n\n")
  end

  def to_yaml
    @run_state.to_yaml
  end

  def to_json
    @run_state.to_json
  end

  def to_csv
##    CSV.generate do |csv|
 #     csv << ['Rule', 'Property', 'Expected Value', 'Actual Value', 'Success']
 #     rule_results.each do |rule, result|
 #       result.each do |r|
  #        csv << [rule, r[:property], r[:expected], r[:actual], r[:success]]
  #      end
  #    end
  #  end

  "TODO(ploubser): Implement"
  end

  private

  def stringify_policy(policy)
    string_buffer = []
    color = policy[:success] ? :green : :red
    string_buffer << "Policy: #{Rainbow(policy[:name]).send(color)}"
    policy[:rules].each do |rule|
      string_buffer << stringify_rule(rule)
    end
    string_buffer.join("\n\n")
  end

  def stringify_rule(rule)
    string_buffer = []
    color = rule[:success] ? :green : :red
    string_buffer << "Description: #{Rainbow(rule[:description]).send(color)}"

    if rule[:severity]
      string_buffer << "Severity: #{Rainbow(rule[:severity]).send(color)}"
    end

    rule[:resources].each do |resource|
      string_buffer << stringify_resource(resource)
    end

    indent_buffer(string_buffer).join("\n")
  end

  def stringify_resource(resource)
    string_buffer = []
    string_buffer << resource[:title]

    resource[:properties].each do |property|
      string_buffer << stringify_property(property)
    end
    indent_buffer(string_buffer).join("\n")
  end

  def stringify_property(property)
    string_buffer = []
    color = property[:success] ? :green : :red
    string_buffer << "#{property[:name]}: #{property[:expected]} -> #{Rainbow(property[:actual]).send(color)}"
    indent_buffer(string_buffer, 8).join("\n")
  end


  def indent_buffer(buffer, count=4)
    buffer.map do |s|
      ' ' * count + s.to_s
    end
  end
end
