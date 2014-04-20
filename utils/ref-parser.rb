require 'pegrb'

##
# Not really a best practice but we need a convenient place to hold the reference
# mappings and a global variable is very convenient.
$REFS = {}

class Line < Struct.new(:line)
  def lines; line; end
end

class RefBlock < Struct.new(:content)
  def lines; content.map(&:lines).join; end
end

ref_grammar = Grammar.rules do

  ws, nl = one_of(/\s/).many.any.ignore, one_of("\n")
  ref_begin, ref_end = ws > m('# REF : '), ws > m('# ENDREF')
  line = (!(ref_begin | ref_end) > (!nl > wildcard).many.any > nl)[:line] >> ->(s) {
    [Line.new(s[:line].map(&:text).join)]
  }

  rule :block, (ws > ref_begin.ignore > (!nl > wildcard).many[:name] > nl.ignore >
   (r(:block) | line).many[:content] > ref_end.ignore > one_of(/\s/).many.any[:end]) >> ->(s) {
    [$REFS[s[:name].map(&:text).join] = RefBlock.new(s[:content] + [s[:end].map(&:text).last])]
  }

  rule :start, r(:block).many

end

require 'pry'
binding.pry
