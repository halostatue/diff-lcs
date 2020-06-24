# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'bin/ldiff' do
  include CaptureSubprocessIO

  let(:output_diff) { read_fixture }
  let(:output_diff_c) { read_fixture('-c') }
  let(:output_diff_e) { read_fixture('-e') }
  let(:output_diff_f) { read_fixture('-f') }
  let(:output_diff_u) { read_fixture('-u') }
  let(:output_diff_chef) { read_fixture('-u', base: 'output.diff.chef') }

  specify do
    expect(run_ldiff('-u', left: 'old-chef', right: 'new-chef')).to eq(output_diff_chef)
  end

  specify do
    expect(run_ldiff).to eq(output_diff)
  end

  specify do
    expect(run_ldiff('-c')).to eq(output_diff_c)
  end

  specify do
    expect(run_ldiff('-e')).to eq(output_diff_e)
  end

  specify do
    expect(run_ldiff('-f')).to eq(output_diff_f)
  end

  specify do
    expect(run_ldiff('-u')).to eq(output_diff_u)
  end

  def read_fixture(flag = nil, base: 'output.diff')
    clean_data(IO.binread("spec/fixtures/ldiff/#{base}#{flag}"), flag)
  end

  def clean_data(data, flag)
    data =
      case flag
      when '-c', '-u'
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
      '*** spec/fixtures/\1	0000-00-00 00:00:00.000000000 -0000'
    )
  end

  def run_ldiff(flag = nil, left: 'aX', right: 'bXaX')
    stdout, stderr = capture_subprocess_io do
      system("ruby -Ilib bin/ldiff #{flag} spec/fixtures/#{left} spec/fixtures/#{right}")
    end
    expect(stderr).to be_empty
    expect(stdout).not_to be_empty
    clean_data(stdout, flag)
  end
end
