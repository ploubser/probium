require 'simplecov'

SimpleCov.start do
  add_filter '.bundle'
  add_filter '/spec/'
end
