require 'active_support/core_ext/string/inflections'
require 'fileutils'

from = ARGV[0] || raise("Needs a FROM argument.")
to = ARGV[1] || raise("Needs a TO argument.")

from_camelized = from.camelize
from_dashed = from.dasherize
from_humanized = from.humanize
from_underscored = from.underscore
to_camelized = to.camelize
to_dashed = to.dasherize
to_underscored = to.underscore

camelized_regex = /(?<=\b|_)#{Regexp.quote(from_camelized)}(?=\b|_)/
dashed_regex = /(?<=\b|_)#{Regexp.quote(from_dashed)}(?=\b|_)/
humanized_regex = /(?<=\b|_)#{Regexp.quote(from_humanized)}(?=\b|_)/i
underscored_regex = /(?<=\b|_)#{Regexp.quote(from_underscored)}(?=\b|_)/

# all files in current directory
Dir.glob('**/*') do |old_path|
  # ignore certain directories
  unless old_path =~ %r{\A(coverage|pkg|tmp|vendor)(\z|/)}
    is_file = File.file?(old_path)
    if is_file
      # replace within file
      old_text = File.read(old_path)

      new_text = old_text.dup
      new_text.gsub!(camelized_regex, to_camelized)
      new_text.gsub!(dashed_regex, to_dashed)
      new_text.gsub!(underscored_regex, to_underscored)

      unless new_text == old_text
        # rewrite existing file
        File.write(old_path, new_text)
      end
    end

    # only check the basename so that the directory doesn't get renamed twice
    old_basename = File.basename(old_path)
    new_basename = old_basename.dup
    new_basename.gsub!(dashed_regex, to_dashed)
    new_basename.gsub!(underscored_regex, to_underscored)

    if new_basename == old_basename
      # no change
      new_path = old_path
    else
      # rename file
      new_path = File.join(File.dirname(old_path), new_basename)
      puts "#{old_path} –> #{new_path}"
      FileUtils.mv(old_path, new_path)
    end

    if is_file
      # show possible matches in body
      line_num = 0
      new_text.each_line do |line|
        if line =~ humanized_regex
          puts "#{new_path}:#{line_num}: #{line.strip}"
        end
        line_num += 1
      end
    end
  end
end
