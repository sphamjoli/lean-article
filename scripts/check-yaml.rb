require 'yaml'
files = IO.popen(['git', 'ls-files', '-z'], &:read).split("\0")
files.select { |name| name.end_with?('.yml', '.yaml') }.each do |name|
  Psych.parse_stream(File.read(name))
end
