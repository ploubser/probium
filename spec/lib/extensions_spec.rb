#! /usr/bin/env rspec

require 'spec_helper'
require 'extensions'

describe Extensions do
  describe 'on creation' do
    it 'validates and loads the extensions' do
      expect { Extensions.new(File.join(File.dirname(__FILE__), '../', 'fixtures')) }.to_not raise_error
    end
  end

  describe '#[]' do
    before :all do
      @extensions = Extensions.new(File.join(File.dirname(__FILE__), '../', 'fixtures'))
    end

    it 'returns the extension hash for the named extension' do
      expect(Extensions[:rspec]).to be_truthy
      expect(Extensions[:rspec][:resource]).to be_truthy
    end

    it 'returns nil when the named extension does not exist' do
      expect(Extensions[:not_rspec]).to be_nil
    end
  end
end
