require 'fileutils'
FileUtils.rmtree %w(auto-packaging)
Dir.mkdir 'auto-packaging'
Dir.mkdir 'auto-packaging\src'
Dir.mkdir 'auto-packaging\src\staticresources'

FileUtils.copy_entry 'src/', 'auto-packaging/src'
FileUtils.cp 'auto-package.xml', 'auto-packaging\src\package.xml'
puts "Auto packaging completed.."
