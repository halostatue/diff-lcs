# frozen_string_literal: true

require "diff/lcs"
require "diff/lcs/block"

# A Hunk is a group of Blocks which overlap because of the context surrounding each block.
# (So if we're not using context, every hunk will contain one block.) Used in the diff
# program (bin/ldiff).
#
# Hunks can also be used without bin/ldiff to produce the same output for two sequences of
# lines.
#
# ```ruby
# require "diff/lcs"
# require "diff/lcs/hunk"
#
# data_old = "a\nb\nc\n".lines
# data_new = "a\nx\nc\n".lines
#
# puts Diff::LCS::Hunk.diff(data_old, data_new, :unified)
# # @@ -1,3 +1,3 @@
# #  a
# # -b
# # +x
# #  c
# ```
#
# The lines must keep their line endings, as String#lines returns them: a last line which
# does not end with "\n" is reported with "\ No newline at end of file". Chomped lines are
# not supported, and may add or omit that marker.
class Diff::LCS::Hunk
  OLD_DIFF_OP_ACTION = {"+" => "a", "-" => "d", "!" => "c"}.freeze # :nodoc:
  private_constant :OLD_DIFF_OP_ACTION

  FORMATS = %i[old unified context].freeze # :nodoc:
  private_constant :FORMATS

  # Returns the hunks for the differences between the lines of `data_old` and `data_new`,
  # each with `context` lines of context (3 by default, as `diff -u` and `diff -c`). Hunks
  # which overlap because of their context are merged. Returns an empty array if there are
  # no differences.
  #
  # Each hunk's #diff output may not end with a newline; Hunk.diff adds one between hunks
  # and marks the last hunk, as bin/ldiff does.
  def self.from_diff(data_old, data_new, context = 3)
    unless context.is_a?(Integer) && !context.negative?
      raise ArgumentError, "context must be a non-negative Integer, not #{context.inspect}"
    end

    data_old, data_new = file_lines(data_old), file_lines(data_new)

    # After we've read up to a certain point in each file, the number of items we've read
    # from each file will differ by FLD (could be 0).
    file_length_difference = 0

    Diff::LCS.diff(data_old, data_new).each_with_object([]) do |piece, hunks|
      hunk = new(data_old, data_new, piece, context, file_length_difference)
      file_length_difference = hunk.file_length_difference

      # If a hunk overlaps with the last hunk, join them.
      if context.positive? && hunk.merge(hunks.last)
        hunks[-1] = hunk
      else
        hunks << hunk
      end
    end
  end

  # Returns a diff string for the differences between the lines of `data_old` and
  # `data_new` in the provided `format` (`:old`, `:unified`, or `:context`) with `context`
  # lines of context (3 by default, as `diff -u` and `diff -c`). Returns an empty string if
  # there are no differences. The `:old` format has no context lines, so `context` does not
  # change its output.
  #
  # The diff string does not include the file header lines (`---` and `+++` for a unified
  # diff) that are written by bin/ldiff. It has the encoding of the lines.
  def self.diff(data_old, data_new, format = :old, context = 3)
    fail "Unknown diff format #{format}." unless FORMATS.include?(format)

    old_lines, new_lines = file_lines(data_old), file_lines(data_new)
    hunks = from_diff(old_lines, new_lines, context)
    last = hunks.last
    # The encoding the hunks use, or the one of the data if there are no hunks.
    output = String.new(encoding: (old_lines[0] || new_lines[0] || data_old[0] || data_new[0] || "").encoding)
    newline = "\n".encode(output.encoding)

    hunks.each do |hunk|
      output << hunk.diff(format, hunk.equal?(last))
      output << newline unless output.end_with?(newline)
    end

    output
  end

  # A single empty line without a newline is an empty file.
  def self.file_lines(data) # :nodoc:
    (data.size == 1 && data[0].empty?) ? [] : data
  end
  private_class_method :file_lines

  # Create a hunk using references to both the old and new data, as well as the piece of
  # data.
  def initialize(data_old, data_new, piece, flag_context, file_length_difference)
    # At first, a hunk will have just one Block in it
    @blocks = [Diff::LCS::Block.from_chunk(piece)]

    if @blocks[0].remove.empty? && @blocks[0].insert.empty?
      fail "Cannot build a hunk from #{piece.inspect}; has no add or remove actions"
    end

    @preferred_data_encoding = data_old.fetch(0) { data_new.fetch(0) { "" } }.encoding
    @newline = "\n".encode(@preferred_data_encoding)
    @missing_newline = "\\ No newline at end of file".encode(@preferred_data_encoding)

    @data_old = data_old
    @data_new = data_new
    @old_empty = data_old.empty? || (data_old.size == 1 && data_old[0].empty?)
    @new_empty = data_new.empty? || (data_new.size == 1 && data_new[0].empty?)

    before = after = file_length_difference
    after += @blocks[0].diff_size
    @file_length_difference = after # The caller must get this manually
    @max_diff_size = @blocks.map { |e| e.diff_size.abs }.max

    @start_old, @end_old, @start_new, @end_new = block_positions(@blocks[0], before, after)

    self.flag_context = flag_context
  end

  attr_reader :blocks
  attr_reader :start_old, :start_new
  attr_reader :end_old, :end_new
  attr_reader :file_length_difference

  ##
  # Change the "start" and "end" fields to note that context should be added to this hunk.
  # :attr_accessor: :flag_context
  attr_reader :flag_context

  ##
  def flag_context=(context) # :nodoc:
    return if context.nil? || context.zero?

    add_start = (context > @start_old) ? @start_old : context

    @start_old -= add_start
    @start_new -= add_start

    old_size = @data_old.size

    add_end =
      if (@end_old + context) >= old_size
        old_size - @end_old - 1
      else
        context
      end

    @end_old += add_end
    @end_new += add_end
  end

  # Merges this hunk and the provided hunk together if they overlap. Returns a truthy
  # value so that if there is no overlap, you can know the merge was skipped.
  def merge(hunk)
    return unless overlaps?(hunk)

    @start_old = hunk.start_old
    @start_new = hunk.start_new
    blocks.unshift(*hunk.blocks)
  end
  alias_method :unshift, :merge

  # Determines whether there is an overlap between this hunk and the provided hunk. This
  # will be true if the difference between the two hunks start or end positions is within
  # one position of each other.
  def overlaps?(hunk)
    hunk && (((@start_old - hunk.end_old) <= 1) || ((@start_new - hunk.end_new) <= 1))
  end

  # Returns a diff string based on a format.
  def diff(format, last = false)
    case format
    when :old
      old_diff(last)
    when :unified
      unified_diff(last)
    when :context
      context_diff(last)
    else
      fail "Unknown diff format #{format}."
    end
  end

  private

  # An old diff has no context lines, so each block of the hunk is written on its own,
  # with the line numbers of its own changes rather than those of the hunk.
  def old_diff(last = false)
    del, ins, sep = ["< ", "> ", "---\n"].map { _1.encode(@preferred_data_encoding) }

    if last
      old_missing_newline = !@old_empty && missing_last_newline?(@data_old)
      new_missing_newline = !@new_empty && missing_last_newline?(@data_new)
    end

    # Context lines are the same in both files, so the difference between the start
    # positions is the file length difference before the first block.
    before = @start_new - @start_old

    @blocks.each_with_object(String.new(encoding: @preferred_data_encoding)) do |block, s|
      after = before + block.diff_size
      start_old, end_old, start_new, end_new = block_positions(block, before, after)
      last_block = last && block.equal?(@blocks[-1])

      # Old diff range is just like a context diff range, except the ranges are on one line
      # with the action between them.
      s << "#{line_range(start_old, end_old)}#{OLD_DIFF_OP_ACTION[block.op]}#{line_range(start_new, end_new)}\n"
        .encode(@preferred_data_encoding)

      unless block.remove.empty?
        @data_old[start_old..end_old].each { |e| s << del + e.chomp + @newline }
      end

      s << @missing_newline << @newline if last_block && old_missing_newline && !new_missing_newline
      s << sep if block.op == "!"

      unless block.insert.empty?
        @data_new[start_new..end_new].each { |e| s << ins + e.chomp + @newline }
      end

      s << @missing_newline << @newline if last_block && new_missing_newline && !old_missing_newline

      before = after
    end
  end

  # Returns the start and end of each array for the block, as
  # `[start_old, end_old, start_new, end_new]`. If the array doesn't exist (e.g., we're only
  # adding items in this block), then figure out the line number based on the line number
  # of the other file and the difference in file lengths `before` and `after` the block.
  def block_positions(block, before, after)
    if block.remove.empty?
      a1 = a2 = nil
    else
      a1 = block.remove[0].position
      a2 = block.remove[-1].position
    end

    if block.insert.empty?
      b1 = b2 = nil
    else
      b1 = block.insert[0].position
      b2 = block.insert[-1].position
    end

    [a1 || (b1 - before), a2 || (b2 - after), b1 || (a1 + before), b2 || (a2 + after)]
  end

  def unified_diff(last = false)
    # Calculate item number range.
    s = "@@ -#{unified_range(:old)} +#{unified_range(:new)} @@\n"
      .encode(@preferred_data_encoding)

    # `outlist` starts containing the hunk of the old file. Removing an item just means
    # putting a '-' in front of it. Inserting an item requires getting it from the new
    # file and splicing it in. We splice in `num_added` items. Remove blocks use
    # `num_added` because splicing changed the length of outlist.
    #
    # We remove `num_removed` items. Insert blocks use `num_removed` because their item
    # numbers -- corresponding to positions in the NEW file -- don't take removed items
    # into account.
    lo, hi, num_added, num_removed = @start_old, @end_old, 0, 0

    space = " ".encode(@preferred_data_encoding)
    outlist = @data_old[lo..hi].map { |e| "#{space}#{e.chomp}" }

    last_block = blocks[-1]

    if last
      old_missing_newline = !@old_empty && missing_last_newline?(@data_old)
      new_missing_newline = !@new_empty && missing_last_newline?(@data_new)
    end

    @blocks.each do |block|
      block.remove.each do |item|
        offset = item.position - lo + num_added
        outlist[offset][0, 1] = item.action.to_s.encode(@preferred_data_encoding) # -
        num_removed += 1
      end

      if last && block == last_block && old_missing_newline && !new_missing_newline
        outlist << @missing_newline
        num_removed += 1
      end

      block.insert.each do |item|
        op = item.action.to_s.encode(@preferred_data_encoding) # +
        offset = item.position - @start_new + num_removed
        outlist[offset, 0] = op + @data_new[item.position].chomp
        num_added += 1
      end
    end

    outlist << @missing_newline if last && new_missing_newline

    s << outlist.join("\n".encode(@preferred_data_encoding))

    s
  end

  def context_diff(last = false)
    s = "***************\n".encode(@preferred_data_encoding)
    s << "*** #{line_range(@start_old, @end_old)} ****\n".encode(@preferred_data_encoding)
    r = line_range(@start_new, @end_new)

    spaces = "  ".encode(@preferred_data_encoding)

    if last
      old_missing_newline = missing_last_newline?(@data_old)
      new_missing_newline = missing_last_newline?(@data_new)
    end

    # Print out file 1 part for each block in context diff format if there are any blocks
    # that remove items
    lo, hi = @start_old, @end_old
    removes = @blocks.reject { |e| e.remove.empty? }

    unless removes.empty?
      outlist = @data_old[lo..hi].map { |e| "#{spaces}#{e.chomp}" }

      last_block = removes[-1]

      removes.each do |block|
        block.remove.each do |item|
          outlist[item.position - lo][0, 1] = block.op.encode(@preferred_data_encoding) # - or !
        end

        if last && block == last_block && old_missing_newline
          outlist << @missing_newline
        end
      end

      s << outlist.join(@newline) << @newline
    end

    s << "--- #{r} ----\n".encode(@preferred_data_encoding)
    lo, hi = @start_new, @end_new
    inserts = @blocks.reject { |e| e.insert.empty? }

    unless inserts.empty?
      outlist = @data_new[lo..hi].map { |e| "#{spaces}#{e.chomp}" }

      last_block = inserts[-1]

      inserts.each do |block|
        block.insert.each do |item|
          outlist[item.position - lo][0, 1] = block.op.encode(@preferred_data_encoding) # + or !
        end

        if last && block == last_block && new_missing_newline
          outlist << @missing_newline
        end
      end
      s << outlist.join(@newline)
    end

    s
  end

  # Generate a range of item numbers to print for the positions `first` to `last`. Only
  # print 1 number if the range has only one item in it. Otherwise, it's 'start,end'
  def line_range(first, last)
    (first < last) ? "#{first + 1},#{last + 1}" : (last + 1).to_s
  end

  # Generate a range of item numbers to print for unified diff. Print number where block
  # starts, followed by number of lines in the block (don't print number of lines if it's
  # 1)
  def unified_range(mode)
    s, e =
      case mode
      when :old
        return "0,0" if @old_empty
        [(@start_old + 1), (@end_old + 1)]
      when :new
        return "0,0" if @new_empty
        [(@start_new + 1), (@end_new + 1)]
      end

    length = e - s + 1

    (length <= 1) ? e.to_s : "#{s},#{length}"
  end

  def missing_last_newline?(data)
    if data[-2]
      data[-2].end_with?(@newline) && !data[-1].end_with?(@newline)
    elsif data[-1]
      !data[-1].end_with?(@newline)
    else
      true
    end
  end
end
