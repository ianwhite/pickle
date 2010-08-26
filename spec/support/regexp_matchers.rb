# matchers for regexps see pickle/parser_spec, pickle/parser/matchers_spec
module RegexpMatchers
  def match_all(*strings)
    simple_matcher "match #{strings.map(&:inspect).to_sentence}" do |regexp, matcher|
      did_not_match = strings.select {|string| /^#{regexp}$/ !~ string }
      matcher.failure_message = "expected #{regexp.inspect} to match #{did_not_match.map(&:inspect).to_sentence}, but they didn't"
      did_not_match.empty?
    end
  end

  def match_any(*strings)
    simple_matcher "match #{strings.map(&:inspect).to_sentence(:two_words_connector  => ' or ', :last_word_connector => ', or ')}" do |regexp, matcher|
      did_match = strings.select {|string| /^#{regexp}$/ =~ string }
      matcher.negative_failure_message = "expected #{regexp.inspect} NOT to match any, but #{did_match.map(&:inspect).to_sentence} did"
      did_match.any?
    end
  end

  def capture(expected, options = {})
    simple_matcher "capture #{expected.inspect} from #{options[:from].inspect}" do |regexp, matcher|
      captured = /^#{regexp}$/.match(options[:from]).try(:[], 1)
      matcher.failure_message = "expected #{regexp.inspect} to capture #{expected.inspect}, but was #{captured.inspect}"
      captured == expected
    end
  end
end

include RegexpMatchers