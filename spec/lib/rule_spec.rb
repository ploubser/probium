#! /usr/bin/env rspec

require 'spec_helper'
require 'rule'

describe Rule do
  describe 'when creating a new rule' do
    it 'fails when there is an invalid key' do
      expect { Rule.new( {:potato => nil }) }.to raise_error Rule::RuleError
    end

    it 'fails when a required field is missing' do
      expect { Rule.new( {}) }.to raise_error Rule::RuleError
      expect { Rule.new( { :resources => [] }) }.to raise_error Rule::RuleError
      expect { Rule.new( { :resources => {},
                           :description => 'description' }) }.not_to raise_error
    end

    it 'fails when the resources field is not an Hash' do
      expect { Rule.new( { :description => 'description',
                           :resources => 'resources' }) }.to raise_error Rule::RuleError
    end

    it 'populates the correct instance members' do
      rule = Rule.new( { :severity => 10.0,
                         :description => 'description',
                         :resources => {} })
      expect(rule.severity).to eq(10.0)
      expect(rule.description).to eq('description')
      expect(rule.resources).to eq([])
    end
  end

  describe '#check resources' do
  end
end
