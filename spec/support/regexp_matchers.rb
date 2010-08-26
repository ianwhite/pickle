# matchers for regexps, convenient way to assert a bunch of stuff at once, error messages are useful.
#
#   /fo\d/.should match_all 'fo1', 'fo2'
#   /fo\d/.should_not match_any 'foo', 'bar'

module RegexpMatchers
  def match_all(*strings)
    simple_matcher "match #{strings.map(&:inspect).to_sentence}" do |regexp, matcher|
      bounded_regexp = /^#{regexp.source}$/
      did_not_match = strings.select {|string| bounded_regexp !~ string }
      matcher.failure_message = "expected #{bounded_regexp.inspect} to match #{did_not_match.map(&:inspect).to_sentence}, but they didn't"
      did_not_match.empty?
    end
  end

  def match_any(*strings)
    simple_matcher "match #{strings.map(&:inspect).to_sentence(:two_words_connector  => ' or ', :last_word_connector => ', or ')}" do |regexp, matcher|
      bounded_regexp = /^#{regexp.source}$/
      did_match = strings.select {|string| bounded_regexp =~ string }
      matcher.negative_failure_message = "expected #{bounded_regexp.inspect} NOT to match any, but #{did_match.map(&:inspect).to_sentence} did"
      did_match.any?
    end
  end

  def capture(expected, options = {})
    simple_matcher "capture #{expected.inspect} from #{options[:from].inspect}" do |regexp, matcher|
      bounded_regexp = /^#{regexp.source}$/
      captured = bounded_regexp.match(options[:from]).try(:[], 1)
      matcher.failure_message = "expected #{bounded_regexp.inspect} to capture #{expected.inspect}, but was #{captured.inspect}"
      captured == expected
    end
  end
end

include RegexpMatchers