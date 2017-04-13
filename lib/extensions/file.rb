def compare(name, expected, actual)
  if name == :ensure
    return actual != :absent && actual != 'absent'
  end

  return actual == expected
end

compare_fn(:file) do |name, expected, actual|
  result = true

  unless actual.is_a? Array
    result = compare(name, expected, actual)
  else
    actual.each do |a|
      unless compare(name, expected, actual)
        result = false
        break
      end
    end
  end

  result
end

def create_one_file(filename)
  Puppet::Resource.indirection.find("file/#{filename}")
end

def create_many_files(file_glob)
  files = Dir.glob(file_glob)

  if files.empty?
    raise StandardError, "Cannot load file resource - '#{file_glob}'. Pattern returns 0 files."
  end
  resource = Puppet::Resource.new('file', file_glob)
  files.each do |file|
    r = Puppet::Resource.indirection.find("file/#{file}")
    r.each do |property, value|
      resource[property] ||= []
      resource[property] << value
    end
  end

  resource
end

create_resource(:file) do |filename|
  if filename =~ /\*/ ||           # and implying **
     filename =~ /\?/ ||           # any
     filename =~ /\[.+\]/ ||       # set
     filename =~ /\{.+,.+\}/ ||    # or
     filename =~ /\<.+\>.+\<\/.+>/ # escape metacharacters

    create_many_files(filename)
  else
    create_one_file(filename)
  end
end

