require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssRuleSetTest < Test::Unit::TestCase

	def test_rule_set_basic
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin:20px'})
		expected = {['body']=>['margin:20px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_basic_with_spaces
		rs = CssToolkit::RuleSet.new({:selector => ' body ', :declarations => ' margin   :  20px '})
		expected = {['body']=>['margin:20px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_longer
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin:20px;padding:10px 5px 3px 8px;'})
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_longer_with_spaces
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px  5px  3px 8px ; '})
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_really_long_with_spaces
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px  5px  3px 8px ;
		 	width: 100px;
		CSS
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => css})

		expected = {['body']=>['background-color:#123abc','margin:20px', 'padding:10px 5px 3px 8px','width:100px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_rule_set_really_long_with_spaces_and_box_model_hack
		# NB hack is actually:
		# voice-family: "\"}\"";
		# extra escaped are for Ruby
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px  5px  3px 8px ;
			width: 100px;
			voice-family: "\\"}\\"";
			voice-family:inherit;
			width: 200px;
		CSS
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => css})

		expected = {['body']=>['background-color:#123abc','margin:20px', 'padding:10px 5px 3px 8px','width:100px','voice-family:"\\"}\\""','voice-family:inherit','width:200px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_add_a_declaration
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px  5px  3px 8px ; '})
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px']}
		assert_equal(expected, rs.to_hash)

		rs << 'width: 100px'
		expected = {['body']=>['margin:20px','padding:10px 5px 3px 8px','width:100px']}
		assert_equal(expected, rs.to_hash)
	end

	def test_to_s_one_line_format
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px  5px  3px 8px ; '})
		expected = 'body{margin:20px;padding:10px 5px 3px 8px}'
		assert_equal(expected, rs.to_s)
	end

	def test_to_s_one_line_format_larger
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px  5px  3px 8px ;
		 	width: 100px;
		CSS
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => css})

		expected = 'body{background-color:#123abc;margin:20px;padding:10px 5px 3px 8px;width:100px}'
		assert_equal(expected, rs.to_s)
	end

	def test_to_s_multi_line_format_larger
		css = <<-CSS
			background-color: #123abc;
			margin : 20px ;
			padding: 10px  5px  3px 8px ;
		 	width: 100px;
		CSS
		rs = CssToolkit::RuleSet.new({:selector => 'body', :declarations => css})

		expected = "body{\n  background-color:#123abc;\n  margin:20px;\n  padding:10px 5px 3px 8px;\n  width:100px\n}"
		assert_equal(expected, rs.to_s(:multi_line))
	end

	def test_add_node_to_stylesheet
		sheet = CssToolkit::StyleSheet.new
		sheet << CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px  5px  3px 8px ; '})
		sheet << CssToolkit::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		expected = 'body{margin:20px;padding:10px 5px 3px 8px}p{font-size:20px;margin:5px;border:1px solid #334123}'
		assert_equal(expected, sheet.to_s)
	end

	def test_add_node_to_stylesheet
		sheet = CssToolkit::StyleSheet.new
		sheet << CssToolkit::RuleSet.new({:selector => 'body', :declarations => 'margin : 20px ; padding: 10px  5px  3px 8px ; '})
		sheet << CssToolkit::RuleSet.new({:selector => 'p', :declarations => 'font-size : 20px ; margin: 5px; border: 1px solid #334123;'})

		expected = "body{\n  margin:20px;\n  padding:10px 5px 3px 8px\n}\np{\n  font-size:20px;\n  margin:5px;\n  border:1px solid #334123\n}\n"
		assert_equal(expected, sheet.to_s(:multi_line))
	end

	def test_charset
		charset = CssToolkit::Charset.new
		expected = '@charset "UTF-8";'
		assert_equal(expected, charset.to_s)

		charset << 'UTF-16'
		expected = '@charset "UTF-16";'
		assert_equal(expected, charset.to_s)

		charset.encoding = 'UTF-32'
		expected = '@charset "UTF-32";'
		assert_equal(expected, charset.to_s)
	end

end