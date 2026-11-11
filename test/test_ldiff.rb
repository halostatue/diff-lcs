# frozen_string_literal: true

require "test_helper"
require "diff/lcs/ldiff"

class TestLdiff < Minitest::Test
  FIXTURES = [
    {name: "diff", left: "aX", right: "bXaX", diff: 1},
    {name: "diff.missing_new_line1", left: "four_lines", right: "four_lines_with_missing_new_line", diff: 1},
    {name: "diff.missing_new_line2", left: "four_lines_with_missing_new_line", right: "four_lines", diff: 1},
    {name: "diff.issue95_trailing_context", left: "123_x", right: "456_x", diff: 1},
    {name: "diff.four_lines.vs.empty", left: "four_lines", right: "empty", diff: 1},
    {name: "diff.empty.vs.four_lines", left: "empty", right: "four_lines", diff: 1},
    {name: "diff.bin1", left: "file1.bin", right: "file1.bin", diff: 0},
    {name: "diff.bin2", left: "file1.bin", right: "file2.bin", diff: 1},
    {name: "diff.chef", left: "old-chef", right: "new-chef", diff: 1},
    {name: "diff.chef2", left: "old-chef2", right: "new-chef2", diff: 1}
  ].product([nil, "-c", "-u"]).map { |(fixture, flag)|
    fixture = fixture.dup
    fixture[:flag] = flag
    fixture
  }

  FIXTURES.each do |fixture|
    test_name = "test_ldiff_#{fixture[:name]}_#{fixture[:flag] || "default"}"
      .tr(".", "_")
      .tr("-", "_")

    define_method(test_name) do
      stdout, stderr, status = run_ldiff(fixture)
      assert_equal fixture[:diff], status
      assert_equal read_fixture(fixture, mode: "error", allow_missing: true), stderr
      assert_equal read_fixture(fixture, mode: "output", allow_missing: false), stdout
    end
  end

  def test_run_reads_file_names_from_args
    status, output, error = run_in_process(%w[test/fixtures/aX test/fixtures/bXaX])

    assert_equal 1, status
    assert_equal "", error
    assert_equal read_fixture({name: "diff", flag: nil}), output
  end

  def test_run_parses_options_from_args
    status, output, error = run_in_process(%w[-u test/fixtures/aX test/fixtures/bXaX])

    assert_equal 1, status
    assert_equal "", error
    assert_equal read_fixture({name: "diff", flag: "-u"}), clean_data(output, "-u")
  end

  def test_run_leaves_args_untouched
    status, _output, error = run_in_process(%w[-u test/fixtures/aX test/fixtures/bXaX].freeze)

    assert_equal 1, status
    assert_equal "", error
  end

  def test_run_reads_dash_from_input
    input = StringIO.new(::File.read("test/fixtures/aX"))
    status, output, error = run_in_process(%w[- test/fixtures/bXaX], input: input)

    assert_equal 1, status
    assert_equal "", error
    assert_equal read_fixture({name: "diff", flag: nil}), output
  end

  def test_run_reports_usage_for_missing_file_names
    status, _output, error = run_in_process(%w[test/fixtures/aX])

    assert_equal 127, status
    assert_match(/\AUsage: #{Regexp.escape(File.basename($0))} \[options\] oldfile newfile$/, error)
  end

  def test_run_warns_about_invalid_options
    status, output, error = run_in_process(%w[--bogus test/fixtures/aX test/fixtures/bXaX])

    assert_equal 1, status
    assert_equal "#{OptionParser.new.program_name}: invalid option: --bogus\n", error
    assert_equal read_fixture({name: "diff", flag: nil}), output
  end

  private

  def run_in_process(args, input: StringIO.new)
    output = StringIO.new
    error = StringIO.new
    status = Diff::LCS::Ldiff.run(args, input, output, error)
    [status, output.string, error.string]
  end

  def read_fixture(options, mode: "output", allow_missing: false)
    fixture = options.fetch(:name)
    flag = options.fetch(:flag)
    name = "test/fixtures/ldiff/#{mode}.#{fixture}#{flag}"

    return "" if !::File.exist?(name) && allow_missing

    data = IO.__send__(IO.respond_to?(:binread) ? :binread : :read, name)
    clean_data(data, flag)
  end

  def clean_data(data, flag)
    data =
      case flag
      when "-c", "-u"
        clean_output_timestamp(data)
      else
        data
      end
    data.gsub(/\r\n?/, "\n")
  end

  def clean_output_timestamp(data)
    data.gsub(
      %r{
        ^
        [-+*]{3}
        \s*
        test/fixtures/(\S+)
        \s*
        \d{4}-\d\d-\d\d
        \s*
        \d\d:\d\d:\d\d(?:\.\d+)
        \s*
        (?:[-+]\d{4}|Z)
      }x,
      '*** test/fixtures/\1	0000-00-00 :00 =>:00 =>00.000000000 -0000'
    )
  end

  def run_ldiff(options)
    flag = options.fetch(:flag)
    left = options.fetch(:left)
    right = options.fetch(:right)

    stdout, stderr = capture_subprocess_io do
      system("ruby -Ilib bin/ldiff #{flag} test/fixtures/#{left} test/fixtures/#{right}")
    end

    [clean_data(stdout, flag), stderr, $?.exitstatus]
  end
end
