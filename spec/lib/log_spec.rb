require 'log'

describe Log do
  before :all do
    Log.initialize
  end

  describe 'on initialization' do
    it 'should set the logger level to debug' do
      expect(Log.class_variable_get(:@@log).level).to be Logger::DEBUG
    end
  end

  describe '#debug' do
    it 'should log the block' do
      expect(Log.class_variable_get(:@@log)).to receive(:debug)
      Log.debug { 'Test message' }
    end
  end

  after :all do
    # Turn off logging so we don't spam like crazy
    Log.class_variable_get(:@@log).level = Logger::WARN
  end
end
