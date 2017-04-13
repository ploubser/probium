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

    it 'throws the correct message when your resource name is wrong' do
      expect { Resource.new("Rspec/'respec']", {}) }.to raise_error Resource::ResourceError
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

    it 'loads a custom compare function and fails when it does not return a bool' do
      resource = Resource.new("Test_custom_compare_fn['test']", { :ensure => 'present' })
      expect { resource.check_properties }.to raise_error /Custom compare function returned a non Boolean value/
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

  describe '#transform_expected_value' do
    before :all do
      @resource = Resource.new("Rspec['test']", { :ensure => 'present' })
    end

    it 'can transform to int' do
      expect(@resource.send(:transform_expected_value, '1', 1)).to eq(1)
    end

    it 'can transform to floats' do
      expect(@resource.send(:transform_expected_value, 1, 1.0)).to eq(1.0)
    end

    it 'can transform to symbols' do
      expect(@resource.send(:transform_expected_value, 'foo', :bar)).to eq(:foo)
    end

    it 'can transform to strings' do
      expect(@resource.send(:transform_expected_value, :foo, 'bar')).to eq('foo')
    end

    it 'can transform into the first element of an array' do
      expect(@resource.send(:transform_expected_value, 'foo', [:bar, :baz])).to eq(:foo)
    end

    it 'does not transform maps' do
      expect(@resource.send(:transform_expected_value, 1, { :foo => 1 })).to eq(1)
    end

    it 'does not transform objects' do
      expect(@resource.send(:transform_expected_value, 1, @resouce)).to eq(1)
    end

    it 'throws if the transformation fails' do
      expect { @resource.send(:transform_expected_value, {}, 1) }.to raise_error Resource::ResourceError
    end
  end

  describe 'comparing propery values' do
    before :all do
      Extensions.new(File.join(File.dirname(__FILE__), '../', 'fixtures'))
    end

    it 'knows how to call a compare_fn' do
      expect(Resource.new("Rspec['rspec]", { :ensure => 'present' }).check_properties[:success]).to be true
    end

    it 'transforms expected and actual value into the same type' do
      expect(Resource.new("Rspec['rspec]", { :ensure => :present }).check_properties[:success]).to be true
    end

    it 'negates when the expected value is wrapped in not()' do
      expect(Resource.new("Rspec['rspec]", { :ensure => 'not(monkey)' }).check_properties[:success]).to be true
    end

    context 'the default compare function knowns how present works' do
      it 'fails if the value is explicitly absent' do
        resource = Resource.new("Absent_failure['rspec']", { :ensure => :present })
        expect(resource.check_properties[:success]).to be false
      end

      it 'succeeds if the value is not explicitly absent' do
        resource = Resource.new("Absent_success['rspec']", { :ensure => :present })
        expect(resource.check_properties[:success]).to be true
      end
    end
  end
end
