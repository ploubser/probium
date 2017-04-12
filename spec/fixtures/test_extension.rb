create_resource(:rspec) do |name|
  resource = Puppet::Resource.new(:rspec, { :value => nil })
  resource[:ensure] = 'present'
  resource
end
