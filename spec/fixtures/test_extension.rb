create_resource(:rspec) do |name|
  resource = Puppet::Resource.new(:rspec, 'test')
  resource[:ensure] = 'present'
  resource
end

create_resource(:absent_failure) do |name|
  resource = Puppet::Resource.new(:absent_failure, 'test')
  resource[:ensure] = :absent
  resource
end

create_resource(:absent_success) do |name|
  resource = Puppet::Resource.new(:absent_success, 'test')
  resource[:ensure] = :potato
  resource
end

create_resource(:test_custom_compare_fn) do |name|
  resource = Puppet::Resource.new(:test_custom_compare_fn, 'test')
  resource[:ensure] = 'present'
  resource
end

compare_fn(:test_custom_compare_fn) do |name, expected, actual|
  'bad example'
end
