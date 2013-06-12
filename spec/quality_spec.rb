# encoding: UTF-8
# Copied from Publisher
require 'spec_helper'

INCLUDED_EXTS  = (%w[coffee css csv erb gemspec haml html js json jst
                     lock md rake rb ru sample sass scss txt xml yml] << '')
EXCLUDED_EXTS  = %w[gemfile gif ico png tsv]

# TODO: Check for newline at end of file
# TODO: Check for encoding string at top
# TODO: Check for correct permissions on files
# TODO: Run ruby -wc on ruby files
# TODO: Possible to detect commented code?
BAD_LINE_REGEXES = {
  'trailing whitespace' => /\s+\z/,
  'tab characters' => /\t/,
  'non-display characters' => /[\p{C}&&[^\t]]/,
  'an unmerged region' => /^(?:<{7}|>{7}|={7}) /
}

describe "The project itself" do
  def check_for_bad_lines(fname)
    msgs_with_lines = {}
    File.readlines(fname).each_with_index do |line,number|
      BAD_LINE_REGEXES.each do |msg, regex|
        bad_lines = (msgs_with_lines[msg] ||= [])
        bad_lines << number + 1 if line.chomp =~ regex
      end
    end

    msgs_with_lines.delete_if {|k, v| v.empty?}
    msgs_with_lines.map {|msg, lines| "#{fname} has #{msg} on lines #{lines.join(',')}"}
  end

  it "has no malformed whitespace" do
    error_messages = []
    Dir.chdir(File.expand_path("../..", __FILE__)) do
      `git ls-files`.split("\n").map {|fn| Pathname.new(fn) }.each do |pn|
        next if pn.directory? || pn.symlink?

        case pn.extname().delete('.')
        when *INCLUDED_EXTS
          error_messages += check_for_bad_lines(pn)
        when *EXCLUDED_EXTS
          next # don't process excluded files
        else
          error_messages << "Encountered unknown file type: #{pn}"
        end
      end
    end
    error_messages.compact.should be_well_formed
  end
end
