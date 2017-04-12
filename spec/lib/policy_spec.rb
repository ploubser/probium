#! /usr/bin/env rspec

require 'spec_helper'
require 'policy'

describe Policy do
  let(:rule) do
    { :description => 'description',
      :resources => {} }
  end

  describe 'when creating a new policy' do
    it 'fails when there is an invalid key' do
      expect { Policy.new( { :potato => nil }) }.to raise_error Policy::PolicyError
    end

    it 'fails when a required key is missing' do
      expect { Policy.new({}) }.to raise_error Policy::PolicyError
      expect { Policy.new({ :name => 'rspec'}) }.to raise_error Policy::PolicyError
      expect { Policy.new({ :rules => [rule] }) }.to raise_error Policy::PolicyError
      expect { Policy.new({ :name => 'rspec',
                            :rules => [rule] }) }.not_to raise_error
    end

    it 'fails when rule is not an array' do
      expect { Policy.new({ :name => 'rspec',
                            :rules => rule }) }.to raise_error Policy::PolicyError
    end

    it 'fails when there are no rules' do
      expect { Policy.new({ :name => 'rspec',
                            :rules => [] }) }.to raise_error Policy::PolicyError
    end

    it 'populates the correct instance members' do
      policy = Policy.new({ :name => 'rspec',
                            :confine => { 'test_fact' => 'rspec' },
                            :rules => [rule] })
      expect(policy.name).to eq('rspec')
      expect(policy.rules.class).to eq(Array)
      policy.rules.each do |rule|
        expect(rule.class).not_to eq(Rule) # Check we don't load rules on initialization
      end
      expect(policy.confines).to eq({ 'test_fact' => 'rspec' })
    end
  end

  describe 'when checking if a policy is enabled' do
    it 'returns true when all the facts match the given values' do
      policy = Policy.new({ :name => 'rspec',
                            :confine => { 'test_fact' => 'rspec',
                                          'test_fact2' => 'rspec' },
                            :rules => [rule] })
      allow(Facter).to receive(:value).with('test_fact').and_return('rspec')
      allow(Facter).to receive(:value).with('test_fact2').and_return('rspec')
      expect(policy.enabled?).to be true
    end

    it 'returns false if any of the facts do not match the given value' do
      policy = Policy.new({ :name => 'rspec',
                            :confine => { 'test_fact' => 'rspec',
                                          'test_fact2' => 'rspec' },
                            :rules => [rule] })
      allow(Facter).to receive(:value).with('test_fact').and_return('not_rspec')
      allow(Facter).to receive(:value).with('test_fact2').and_return('not_rspec')
      expect(policy.enabled?).to be false
    end

    it 'return true if there are no confines' do
      policy = Policy.new({ :name => 'rspec',
                            :rules => [rule] })
      expect(policy.enabled?).to be true
    end
  end
end
