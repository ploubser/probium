#! /usr/bin/env rspec

require 'spec_helper'
require 'command_line'

describe CommandLine do
  before :each do
    ARGV.clear
  end

  describe 'parse!' do
    it 'fails when passed an invalid flag' do
      ARGV << '--potato'
      expect { CommandLine.parse!({}) }.to raise_error(OptionParser::InvalidOption)
    end

    it 'exits 1 when --output-format is invalid' do
      ARGV << '-o potatoes'
      expect(CommandLine.parse!({})[:state]).to eq(:fail)
    end

    it 'exits 0 on --help' do
      ARGV << '--help'
      expect(CommandLine.parse!({})[:state]).to eq(:exit)
    end

    it 'parses valid output formats' do
      valid_formats = ['graphic', 'json', 'yaml', 'csv']
      valid_formats.each do |f|
        ARGV << 'o' << f
        expect { CommandLine.parse!({}) }.not_to raise_error
      end
    end

    it 'parses --extension-dir' do
      options = {}
      ARGV << '-e' << '/rspec/extensions'
      CommandLine.parse!(options)
      expect(options[:extensions_path]).to eq('/rspec/extensions')
    end

    it 'parses --debug' do
      options = {}
      ARGV << '--debug'
      CommandLine.parse!(options)
      expect(options[:debug]).to be true
    end

    it 'parses --no-color' do
      options = {}
      ARGV << '--no-color'
      CommandLine.parse!(options)
      expect(options[:color]).to be false
    end
  end

  describe 'policy!' do
    it 'throws when there is not policy file as argument 1 of ARGV' do
      expect { CommandLine.policy! }.to raise_error(/Missing required policy file/)
    end

    it 'returns the file name from ARGV' do
      ARGV << 'rspec_file'
      expect(CommandLine.policy!).to eq('rspec_file')
    end

  end
end
