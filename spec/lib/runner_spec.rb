#! /usr/bin/env rspec

require 'spec_helper'
require 'runner'

describe Runner do
  let(:policy_file) do
    File.join(File.dirname(__FILE__), '../', 'fixtures', 'test_policy.yaml')
  end

  before :each do
    allow(CommandLine).to receive(:policy!).and_return(policy_file)
  end

  describe 'run' do
    let(:result_viewer) do
      double(:result_viewer)
    end

    before :each do
      allow(ResultViewer).to receive(:new).and_return(result_viewer)
      allow(result_viewer).to receive(:run_state).and_return( { :successes => 1, :total => 1 })
    end

    it 'calls the policy checker' do
      expect_any_instance_of(Policy).to receive(:check_rules)
      Runner.new.run
    end

    context 'output modes' do
      before :each do
        expect_any_instance_of(Policy).to receive(:check_rules)
      end

      it 'returns json when output mode is json' do
        expect(result_viewer).to receive(:to_json)
        ARGV << '-o' << 'json'
        Runner.new.run
      end

      it 'returns yaml when output mode is yaml' do
        expect(result_viewer).to receive(:to_yaml)
        ARGV << '-o' << 'yaml'
        Runner.new.run
      end

      it 'returns csv when output mode is csv'

      it 'sets the exit_code to 0 if all policies succeeded' do
        runner = Runner.new
        runner.run
        expect(runner.exit_code). to eq(0)
      end

      it 'sets the exit_code to 1 if any policies failed' do
        allow(result_viewer).to receive(:run_state).and_return( { :successes => 1, :total => 2 })
        runner = Runner.new
        runner.run
        expect(runner.exit_code). to eq(1)
      end
    end
  end
end
