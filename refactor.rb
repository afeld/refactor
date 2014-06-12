require 'active_support/core_ext/string/inflections'
require 'fileutils'

from = ARGV[0] || raise("Needs a FROM argument.")
to = ARGV[1] || raise("Needs a TO argument.")

from_dashed = from.dasherize
from_underscored = from.underscore
to_dashed = to.dasherize
to_underscored = to.underscore

# all files in current directory
Dir.glob('**/*') do |old_path|
  unless old_path =~ %r{\A(coverage|pkg|tmp|vendor)(\z|/)}
    new_basename = File.basename(old_path).
      gsub(/(?<=\b|_)#{Regexp.quote(from_dashed)}(?=\b|_)/, to_dashed).
      gsub(/(?<=\b|_)#{Regexp.quote(from_underscored)}(?=\b|_)/, to_underscored)

    old_dir = File.dirname(old_path)
    if old_dir == '.'
      new_path = new_basename
    else
      new_path = File.join(old_dir, new_basename)
    end

    unless new_path == old_path
      # rename file
      puts "#{old_path} –> #{new_path}"
    end
  end
end
