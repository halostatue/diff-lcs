# frozen_string_literal: true

require "spec_helper"

RSpec.describe "bin/ldiff" do
  include CaptureSubprocessIO

  # standard:disable Style/HashSyntax
  fixtures = [
    {:name => "output.diff", :left => "aX", :right => "bXaX", :diff => 1},
    {:name => "output.diff.bin1", :left => "file1.bin", :right => "file1.bin", :diff => 0},
    {:name => "output.diff.bin2", :left => "file1.bin", :right => "file2.bin", :diff => 1},
    {:name => "output.diff.chef", :left => "old-chef", :right => "new-chef", :diff => 1},
    {:name => "output.diff.chef2", :left => "old-chef2", :right => "new-chef2", :diff => 1}
  ].product([nil, "-e", "-f", "-c", "-u"]).map { |(fixture, flag)|
    fixture = fixture.dup
    fixture[:flag] = flag
    fixture
  }
  # standard:enable Style/HashSyntax

  def self.test_ldiff(fixture)
    desc = [
      fixture[:flag],
      "spec/fixtures/#{fixture[:left]}",
      "spec/fixtures/#{fixture[:right]}",
      "#",
      "=>",
      "spec/fixtures/ldiff/#{fixture[:name]}#{fixture[:flag]}"
    ].join(" ")

    it desc do
      ldiff_output, ldiff_status = run_ldiff(fixture)
      expect(ldiff_status).to eq(fixture[:diff])
      expect(ldiff_output).to eq(read_fixture(fixture))
    end
  end

  fixtures.each do |fixture|
    test_ldiff(fixture)
  end

  def read_fixture(options)
    fixture = options.fetch(:name)
    flag = options.fetch(:flag)
    name = "spec/fixtures/ldiff/#{fixture}#{flag}"
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
        spec/fixtures/(\S+)
        \s*
        \d{4}-\d\d-\d\d
        \s*
        \d\d:\d\d:\d\d(?:\.\d+)
        \s*
        (?:[-+]\d{4}|Z)
      }x,
      '*** spec/fixtures/\1	0000-00-00 :00 =>:00 =>00.000000000 -0000'
    )
  end

  def run_ldiff(options)
    flag = options.fetch(:flag)
    left = options.fetch(:left)
    right = options.fetch(:right)

    stdout, stderr = capture_subprocess_io do
      system("ruby -Ilib bin/ldiff #{flag} spec/fixtures/#{left} spec/fixtures/#{right}")
    end

    expect(stderr).to be_empty if RUBY_VERSION >= "1.9"
    [clean_data(stdout, flag), $?.exitstatus]
  end
end
