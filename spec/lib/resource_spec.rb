require 'resource'

describe Resource do
  before :all do
    Extensions.new(File.join(File.dirname(__FILE__), '../', 'fixtures'))
  end

  describe 'when creating a new resource' do
    it 'loads an extension resource' do
      resource = Resource.new("Rspec['test']", { :ensure => 'present' })
      expect(resource.puppet_resource.class).to eq(Puppet::Resource)
    end

    it 'loads a puppet resource' do
      resource = Resource.new("File['#{__FILE__}']", { :ensure => 'present' })
      expect(resource.puppet_resource.class).to eq(Puppet::Resource)
    end

    it 'throws the correct message if you have insufficient privileges' do
      allow(Puppet::Resource).to receive(:indirection).and_raise Puppet::Error, 'Permission denied'
      expect { Resource.new("Potota['potato']", { :ensure => 'present' }) }.
        to raise_error /Insufficient permissions to create resource/
    end

    it 'throws the correct message if you have insufficient privileges if the resource does not exist' do
      expect { Resource.new("Potota['potato']", { :ensure => 'present' }) }.
        to raise_error /Cannot create unknown resource type/
    end
  end

  describe '#check_properties' do
    it 'checks the given properties against the actaul properties of the resource' do
      resource = Resource.new("Rspec['test']", { :ensure => 'present' })
      expect(resource.check_properties).to eq({ :success => true,
                                                :title => "Rspec['test']",
                                                :properties => [{ :name => :ensure,
                                                                  :expected => 'present',
                                                                  :actual => 'present',
                                                                  :success => true }]})
    end
  end
end
