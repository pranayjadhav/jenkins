require 'fileutils'
FileUtils.rmtree %w(auto-packaging) 
Dir.mkdir 'auto-packaging'
Dir.mkdir 'auto-packaging\src'
Dir.mkdir 'auto-packaging\src\staticresources'

FileUtils.copy_entry 'src/', 'auto-packaging/src'
FileUtils.cp 'auto-package.xml', 'auto-packaging\src\package.xml'
FileUtils.rm Dir.glob('auto-packaging/src/objects/*.object')
FileUtils.rm 'NotExistFile', :force => true
puts "Auto packaging completed..."
