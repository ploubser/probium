require 'spec_helper'
require 'result_viewer'

describe ResultViewer do
  describe 'object to string' do
    before do
      Extensions.new(File.join(File.dirname(__FILE__), '../', 'fixtures'))
      policy_file = File.join(File.dirname(__FILE__), '../', 'fixtures', 'test_policy.yaml')
      policy = Policy.new(YAML.load_file(policy_file))
      @result_viewer = ResultViewer.new([policy.check_rules])
    end

    it 'can transform results into a big old string' do
      expect(@result_viewer.respond_to?(:to_s)).to be_truthy
    end

    it 'can transform results into json' do
      expect(@result_viewer.respond_to?(:to_json)).to be_truthy
      expect(JSON.parse(@result_viewer.to_json)).to be_truthy
    end

    it 'can transform results into yaml' do
      expect(@result_viewer.respond_to?(:to_yaml)).to be_truthy
      expect(YAML.load(@result_viewer.to_yaml)).to be_truthy
    end

    it 'can transform results into csv'
     # expect(@result_viewer.respond_to?(:to_csv)).to be_truthy
     # expect it to be csv too
  end
end
