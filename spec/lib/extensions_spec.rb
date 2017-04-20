#! /usr/bin/env rspec

require 'spec_helper'
require 'extensions'

describe Extensions do
  describe 'on creation' do
    it 'validates and loads the extensions' do
      expect { Extensions.new(File.join(File.dirname(__FILE__), '../', 'fixtures')) }.to_not raise_error
    end

    it 'raises if the location does not exist' do
      allow(File).to receive(:exist?).and_return(false)
      expect { Extensions.new }.to raise_error /does not exist/
    end

    it 'raises when the location is not a directory' do
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:directory?).and_return(false)
      expect { Extensions.new }.to raise_error /not a directory/
    end

    it 'raises when it cannot read the file' do
      allow(File).to receive(:read).and_raise('explosion')
      expect do
        Extensions.new(File.join(File.dirname(__FILE__), '../', 'fixtures'))
      end.to raise_error /Cannot load extension file/
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
