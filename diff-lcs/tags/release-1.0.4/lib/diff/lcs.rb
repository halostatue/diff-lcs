#! /usr/env/bin ruby
#--
# Copyright 2004 Austin Ziegler <diff-lcs@halostatue.ca>
#   adapted from:
#     Algorithm::Diff (Perl) by Ned Konz <perl@bike-nomad.com>
#     Smalltalk by Mario I. Wolczko <mario@wolczko.com>
#   implements McIlroy-Hunt diff algorithm
#
# This program is free software. It may be redistributed and/or modified under
# the terms of the GPL version 2 (or later), the Perl Artistic licence, or the
# Ruby licence.
# 
# $Id$
#++

module Diff
    # = Diff::LCS 1.0.4
    # Computes "intelligent" differences between two ordered Enumerables. This
    # is an implementation of the McIlroy-Hunt "diff" algorithm for Enumerable
    # objects that include Diffable.
    #
    # Based on Mario I. Wolczko's <mario@wolczko.com> Smalltalk version (1.2,
    # 1993) and Ned Konz's <perl@bike-nomad.com> Perl version
    # (Algorithm::Diff).
    #
    # == Synopsis
    #   require 'diff/lcs'
    #
    #   seq1 = %w(a b c e h j l m n p)
    #   seq2 = %w(b c d e f j k l m r s t)
    #
    #   lcs = Diff::LCS.LCS(seq1, seq2)
    #   diffs = Diff::LCS.diff(seq1, seq2)
    #   sdiff = Diff::LCS.sdiff(seq1, seq2)
    #   seq = Diff::LCS.traverse_sequences(seq1, seq2, callback_obj)
    #   bal = Diff::LCS.traverse_balanced(seq1, seq2, callback_obj)
    #
    # Alternatively, objects can be extended with Diff::LCS:
    #
    #   seq1.extend(Diff::LCS)
    #   lcs = seq1.lcs(seq2)
    #   diffs = seq1.diff(seq2)
    #   sdiff = seq1.sdiff(seq2)
    #   seq = Diff::LCS.traverse_sequences(seq1, seq2, callback_obj)
    #   bal = Diff::LCS.traverse_balanced(seq1, seq2, callback_obj)
    # 
    # Default extensions are provided for Array and String objects through the
    # use of 'diff/lcs/array' and 'diff/lcs/string'.
    #
    # == Introduction (by Mark-Jason Dominus)
    # I once read an article written by the authors of +diff+; they said that
    # they hard worked very hard on the algorithm until they found the right
    # one.
    #
    # I think what they ended up using (and I hope someone will correct me,
    # because I am not very confident about this) was the `longest common
    # subsequence' method. In the LCS problem, you have two sequences of
    # items:
    #
    #    a b c d f g h j q z
    #    a b c d e f g i j k r x y z
    #
    # and you want to find the longest sequence of items that is present in
    # both original sequences in the same order. That is, you want to find a
    # new sequence *S* which can be obtained from the first sequence by
    # deleting some items, and from the secend sequence by deleting other
    # items. You also want *S* to be as long as possible. In this case *S*
    # is:
    # 
    #    a b c d f g j z
    #
    # From there it's only a small step to get diff-like output:
    #
    #    e   h i   k   q r x y
    #    +   - +   +   - + + +
    #
    # This module solves the LCS problem. It also includes a canned function
    # to generate +diff+-like output.
    #
    # It might seem from the example above that the LCS of two sequences is
    # always pretty obvious, but that's not always the case, especially when
    # the two sequences have many repeated elements. For example, consider
    #
    #    a x b y c z p d q
    #    a b c a x b y c z
    #
    # A naive approach might start by matching up the +a+ and +b+ that
    # appear at the beginning of each sequence, like this:
    # 
    #    a x b y c         z p d q
    #    a   b   c a b y c z
    #
    # This finds the common subsequence +a b c z+. But actually, the LCS is
    # +a x b y c z+:
    #
    #          a x b y c z p d q
    #    a b c a x b y c z
    #
    # === Key Generation
    # The Perl version accepts an optional hash-key generation code reference
    # because all comparisons are done stringwise. This is not necessary for
    # Ruby, as the spaceship operator (<=>) should be provided on classes that
    # may be present in an ordered Enumerable.
    #
    # == Author
    # This version is by Austin Ziegler <diff-lcs@halostatue.ca>.
    #
    # It is based on the Perl Algorithm::Diff by Ned Konz
    # <perl@bike-nomad.com>, copyright &copy; 2000 - 2002 and the Smalltalk
    # diff version by Mario I. Wolczko <mario@wolczko.com>, copyright &copy;
    # 1993.
    #
    # == Licence
    # Copyright &copy; 2004 Austin Ziegler
    # This program is free software; you can redistribute it and/or modify it
    # under the same terms as Ruby, or alternatively under the Perl Artistic
    # licence.
    #
    # == Credits
    # Much of the documentation is taken directly from the Perl
    # Algorithm::Diff implementation and was written by Mark-Jason Dominus
    # <mjd-perl-diff@plover.com>. The basic Ruby implementation was reported
    # from the Smalltalk implementation, available at
    # ftp://st.cs.uiuc.edu/pub/Smalltalk/MANCHESTER/manchester/4.0/diff.st
    #
    # +sdiff+ and +traverse_balanced+ were written for the Perl version by
    # Mike Schilli <m@perlmeister.com>.
    #
    # The algorithm is described in <em>A Fast Algorithm for Computing Longest
    # Common Subsequences</em>, CACM, vol.20, no.5, pp.350-353, May 1977, with
    # a few minor improvements to improve the speed.
  module LCS
    VERSION = '1.0.4'   #:nodoc:
  end
end

require 'diff/lcs/event'
require 'diff/lcs/callbacks'

module Diff::LCS
    # Returns the Longest Common Subsequnce(s)
    # LCS returns an Array containing the longest common subsequence between
    # +self+ and +other+.
    #
    #   lcs = seq1.lcs(seq2)
  def lcs(other, &block) #:yields self[ii] if there are matched subsequences:
    Diff::LCS.LCS(self, other, &block)
  end

  def diff(other, callbacks = nil, &block)
    Diff::LCS::diff(self, other, callbacks, &block)
  end

  def sdiff(other, callbacks = nil, &block)
    Diff::LCS::sdiff(self, other, callbacks, &block)
  end

  def traverse_sequences(other)
    traverse_sequences(self, other, Diff::LCS::YieldingCallbacks)
  end

  def traverse_balanced(other)
    traverse_balanced(self, other, Diff::LCS::YieldingCallbacks)
  end

  def patch(diffs)
    Diff::LCS::patch(self, diffs)
  end
end

module Diff::LCS
  class << self
      # Find the place at which +value+ would normally be inserted into the
      # Enumerable. If that place is already occupied by +value+, do nothing
      # and return +nil+. If the place does not exist (i.e., it is off the end
      # of the Enumerable), add it to the end. Otherwise, replace the element
      # at that point with +value+. It is assumed that the Enumerable's values
      # are numeric.
      #
      # This operation preserves the sort order.
    def __replace_next_larger(enum, value, last_index = nil)
        # Off the end?
      if enum.empty? or (value > enum[-1])
        enum << value
        return enum.size - 1
      end

        # Binary search for the insertion point
      last_index ||= enum.size
      first_index = 0
      while (first_index <= last_index)
        ii = (first_index + last_index) >> 1

        found = enum[ii]

        if value == found
          return nil
        elsif value > found
          first_index = ii + 1
        else
          last_index = ii - 1
        end
      end

        # The insertion point is in first_index; overwrite the next larger
        # value.
      enum[first_index] = value
      return first_index
    end

      # Compute the longest common subsequence between the ordered Enumerables
      # +a+ and +b+. The result is an array whose contents is such that
      #
      #     result = Diff::LCS.__lcs(a, b)
      #     result.each_with_index do |e, ii|
      #       assert_equal(a[ii], b[e]) unless e.nil?
      #     end
    def __lcs(a, b)
      a_start = b_start = 0
      a_finish = a.size - 1
      b_finish = b.size - 1
      vector = []

        # Prune off any common elements at the beginning...
      while (a_start <= a_finish) and
            (b_start <= b_finish) and
            (a[a_start] == b[b_start])
        vector[a_start] = b_start
        a_start += 1
        b_start += 1
      end

        # Now the end...
      while (a_start <= a_finish) and
            (b_start <= b_finish) and
            (a[a_finish] == b[b_finish])
        vector[a_finish] = b_finish
        a_finish -= 1
        b_finish -= 1
      end

        # Now, compute the equivalence classes of positions of elements.
      b_matches = Diff::LCS.__position_hash(b, b_start .. b_finish)

      thresh = []
      links = []

      (a_start .. a_finish).each do |ii|
        ai = a.kind_of?(String) ? a[ii, 1] : a[ii]
        bm = b_matches[ai]
        kk = nil
        bm.reverse_each do |jj|
          if kk and (thresh[kk] > jj) and (thresh[kk - 1] < jj)
            thresh[kk] = jj
          else
            kk = Diff::LCS.__replace_next_larger(thresh, jj, kk)
          end
          links[kk] = [ (kk > 0) ? links[kk - 1] : nil, ii, jj ] unless kk.nil?
        end
      end

      unless thresh.empty?
        link = links[thresh.size - 1]
        while not link.nil?
          vector[link[1]] = link[2]
          link = link[0]
        end
      end

      vector
    end

      # If +vector+ maps the matching elements of another collection onto this
      # Enumerable, compute the inverse +vector+ that maps this Enumerable
      # onto the collection.
    def __inverse_vector(a, vector)
      inverse = a.dup
      (0 ... vector.size).each do |ii|
        inverse[vector[ii]] = ii unless vector[ii].nil?
      end
      inverse
    end

      # Returns a hash mapping each element of an Enumerable to the set of
      # positions it occupies in the Enumerable, optionally restricted to the
      # elements specified in the range of indexes specified by +interval+.
    def __position_hash(enum, interval = 0 .. -1)
      hash = Hash.new { |hh, kk| hh[kk] = [] }
      interval.each do |ii|
        kk = enum.kind_of?(String) ? enum[ii, 1] : enum[ii]
        hash[kk] << ii
      end
      hash
    end

      # Given two ordered Enumerables, LCS returns an Array containing their
      # longest common subsequence.
      #
      #   lcs = Diff::LCS.LCS(seq1, seq2)
    def LCS(a, b, &block) #:yields self[ii] if there are matched subsequences:
      matches = Diff::LCS.__lcs(a, b)
      ret = []
      matches.each_with_index do |e, ii|
        unless matches[ii].nil?
          ret << a[ii]
          yield a[ii] if block_given?
        end
      end
      ret
    end

      # Diff::LCS.diff computes the smallest set of additions and deletions
      # necessary to turn the first sequence into the second, and returns a
      # description of these changes. The description is a list of +hunks+;
      # each hunk represents a contiguous section of items which should be
      # added, deleted, or replaced. The return value of +diff+ is an Array
      # of hunks.
      #
      #     diffs = Diff::LCS.diff(seq1, seq2) 
      #       # [ [ [ :-,  0, 'a' ] ],
      #       #   [ [ :+,  2, 'd' ] ],
      #       #   [ [ :-,  4, 'h' ],
      #       #     [ :+,  4, 'f' ] ],
      #       #   [ [ :+,  6, 'k' ] ],
      #       #   [ [ :-,  8, 'n' ],
      #       #     [ :-,  9, 'p' ],
      #       #     [ :+,  9, 'r' ],
      #       #     [ :+, 10, 's' ],
      #       #     [ :+, 11, 't' ] ] ]
      #
      # There are five hunks here. The first hunk says that the +a+ at
      # position 0 of the first sequence should be deleted (<tt>:-</tt>).
      # The second hunk says that the +d+ at position 2 of the second
      # sequence should be inserted (<tt>:+</tt>). The third hunk says that
      # the +h+ at position 4 of the first sequence should be removed and
      # replaced with the +f+ from position 4 of the second sequence. The
      # other two hunks similarly.
    def diff(a, b, callbacks = nil, &block)
      callbacks ||= Diff::LCS::DiffCallbacks.new
      traverse_sequences(a, b, callbacks)
      callbacks.match(nil)
      if block_given?
        res = callbacks.diffs.map do |hunk|
          if hunk.kind_of?(Array)
            hunk = hunk.map { |block| yield block }
          else
            yield hunk
          end
        end
        res
      else
        callbacks.diffs
      end
    end

      # Diff::LCS.sdiff computes all necessary components to show two sequences
      # and their minimized differences side by side, just like the Unix
      # utility <em>sdiff</em> does:
      #
      #     same             same
      #     before     |     after
      #     old        <     -
      #     -          >     new
      #
      # It returns an Array of Arrays that contain display instructions.
      # Display instructions consist of three elements: A modifier indicator
      # (<tt>:+</tt>: Element added, <tt>:-</tt>: Element removed, +u+:
      # Element unmodified, +c+: Element changed) and the value of the old
      # and new elements, to be displayed side by side.
      #
      #   sdiffs = Diff::LCS.sdiff(seq1, seq2)
      #   # [ [ '-', 'a',  '' ],
      #   #   [ 'u', 'b', 'b' ],
      #   #   [ 'u', 'c', 'c' ],
      #   #   [ '+',  '', 'd' ],
      #   #   [ 'u', 'e', 'e' ],
      #   #   [ 'c', 'h', 'f' ],
      #   #   [ 'u', 'j', 'j' ],
      #   #   [ '+', '',  'k' ],
      #   #   [ 'u', 'l', 'l' ],
      #   #   [ 'u', 'm', 'm' ],
      #   #   [ 'c', 'n', 'r' ],
      #   #   [ 'c', 'p', 's' ],
      #   #   [ '+',  '', 't' ] ]
    def sdiff(a, b, callbacks = nil, &block)
      callbacks ||= Diff::LCS::SDiffCallbacks.new
      traverse_balanced(a, b, callbacks)
      if block_given?
        res = callbacks.diffs.map do |hunk|
          if hunk.kind_of?(Array)
            hunk = hunk.map { |block| yield block }
          else
            yield hunk
          end
        end
        res
      else
        callbacks.diffs
      end
    end

      # Diff::LCS.traverse_sequences is the most general facility provided by this
      # module; +diff+ and +LCS+ are implemented as calls to it.
      #
      # Imagine that there are two arrows. Arrow A points to an element of
      # sequence A, and arrow B points to an element of the sequence B.
      # Initially, the arrows point to the first elements of the respective
      # sequences. +traverse_sequences+ will advance the arrows through the
      # sequences one element at a time, calling an appropriate
      # user-specified callback function before each advance. It will
      # advance the arrows in such a way that if there are equal elements
      # <tt>A[ii]</tt> and <tt>B[jj]</tt> which are equal and which are part
      # of the LCS, there will be some moment during the execution of
      # +traverse_sequences+ when arrow A is pointing to <tt>A[ii]</tt> and
      # arrow B is pointing to <tt>B[jj]</tt>. When this happens,
      # +traverse_sequences+ will call the <tt>:match</tt> lambda and then
      # it will advance both arrows.
      #
      # Otherwise, one of the arrows is pointing to an element of its
      # sequence that is not part of the LCS. +traverse_sequences+ will
      # advance that arrow and will call the <tt>:discard_a</tt> or the
      # <tt>:discard_b</tt> lambdas, depending on which arrow it advanced.
      # If both arrows point to elements that are not part of the LCS, then
      # +traverse_sequences+ will advance one of them and call the
      # appropriate callback, but it is not specified which it will call.
      #
      # The arguments to +traverse_sequences+ are the two sequences to
      # traverse, and a hash which specifies the lambdas, like this:
      #
      #   traverse_sequences(seq1, seq2,
      #                      :match => callback_1,
      #                      :discard_a => callback_2,
      #                      :discard_b => callback_3)
      #
      # The lambdas for <tt>:match</tt>, <tt>:discard_a</tt>, and
      # <tt>:discard_b</tt> are invoked with the indices of the two arrows
      # as their arguments and are not expected to return any values.
      #
      # If arrow A reaches the end of its sequence before arrow B does,
      # +traverse_sequences+ will call the <tt>:a_finished</tt> lambda with
      # the last index in A. If <tt>:a_finished</tt> does not exist, then
      # <tt>:discard_b</tt> will be called until the end of the B sequence.
      # If B terminates before A, then <tt>:b_finished</tt> or
      # <tt>:discard_a</tt> will be called.
      #
      # Omitted callbacks are not called.
      #
    def traverse_sequences(a, b, callbacks = Diff::LCS::SequenceCallbacks)
      matches = Diff::LCS.__lcs(a, b)

      run_finished_a = run_finished_b = false
      string = a.kind_of?(String)

      a_size = a.size
      b_size = b.size
      ai = bj = 0

      (0 .. matches.size).each do |ii|
        b_line = matches[ii]

        ax = string ? a[ii, 1] : a[ii]
        bx = string ? b[bj, 1] : b[bj]

        if b_line.nil?
          unless ax.nil?
            event = Diff::LCS::Event.new(:discard_a, ax, ii, bx, bj)
            callbacks.discard_a(event)
          end
        else
          loop do
            break unless bj < b_line
            bx = string ? b[bj, 1] : b[bj]
            event = Diff::LCS::Event.new(:discard_b, ax, ii, bx, bj)
            callbacks.discard_b(event)
            bj += 1
          end
          bx = string ? b[bj, 1] : b[bj]
          event = Diff::LCS::Event.new(:match, ax, ii, bx, bj)
          callbacks.match(event)
          bj += 1
        end
        ai = ii
      end
      ai += 1

        # The last entry (if any) processed was a match. +ai+ and +bj+ point
        # just past the last matching lines in their sequences.
      while (ai < a_size) or (bj < b_size)
          # last A?
        if ai == a_size and bj < b_size
          if callbacks.respond_to?(:finished_a) and not run_finished_a
            ax = string ? a[-1, 1] : a[-1]
            bx = string ? b[bj, 1] : b[bj]
            event = Diff::LCS::Event.new(:finished_a, ax, a_size - 1, bx, bj)
            callbacks.finished_a(event)
            run_finished_a = true
          else
            ax = string ? a[ai, 1] : a[ai]
            loop do
              bx = string ? b[bj, 1] : b[bj]
              event = Diff::LCS::Event.new(:discard_b, ax, ai, bx, bj)
              callbacks.discard_b(event)
              bj += 1
              break unless bj < b_size
            end
          end
        end

          # last B?
        if bj == b_size and ai < a_size
          if callbacks.respond_to?(:finished_b) and not run_finished_b
            ax = string ? a[ai, 1] : a[ai]
            bx = string ? b[-1, 1] : b[-1]
            event = Diff::LCS::Event.new(:finished_b, ax, ai, bx, b_size - 1)
            callbacks.finished_b(event)
            run_finished_b = true
          else
            bx = string ? b[bj, 1] : b[bj]
            loop do
              ax = string ? a[ai, 1] : a[ai]
              event = Diff::LCS::Event.new(:discard_b, ax, ai, bx, bj)
              callbacks.discard_a(event)
              ai += 1
              break unless bj < b_size
            end
          end
        end

        if ai < a_size
          ax = string ? a[ai, 1] : a[ai]
          bx = string ? b[bj, 1] : b[bj]
          event = Diff::LCS::Event.new(:discard_b, ax, ai, bx, bj)
          callbacks.discard_a(event)
          ai += 1
        end

        if bj < b_size
          ax = string ? a[ai, 1] : a[ai]
          bx = string ? b[bj, 1] : b[bj]
          event = Diff::LCS::Event.new(:discard_b, ax, ai, bx, bj)
          callbacks.discard_b(event)
          bj += 1
        end
      end
    end

      # +traverse_balanced+ is an alternative to +traverse_sequences+. It
      # uses a different algorithm to iterate through the entries in the
      # computed LCS. Instead of sticking to one side and showing element
      # changes as insertions and deletions only, it will jump back and
      # forth between the two sequences and report <em>changes</em>
      # occurring as deletions on one side followed immediatly by an
      # insertion on the other side.
      #
      # In addition to the <tt>:discard_a</tt>, <tt>:discard_b</tt>, and
      # <tt>:match</tt> callbacks supported by +traverse_sequences+,
      # +traverse_balanced+ supports a <tt>:change</tt> callback indicating
      # that one element got +replaced+ by another:
      #
      # traverse_sequences(seq1, seq2,
      #                    :match => $callback_1,
      #                    :discard_a => $callback_2,
      #                    :discard_b => $callback_3,
      #                    :change    => $callback_4,)
      #
      # If no <tt>:change</tt> callback is specified, +traverse_balanced+
      # will map <tt>:change</tt> events to <tt>:discard_a</tt> and
      # <tt>:discard_b</tt> actions, therefore resulting in a similar
      # behaviour as +traverse_sequences+ with different order of events.
      #
      # +traverse_balanced+ might be a bit slower than +traverse_sequences+,
      # noticable only while processing huge amounts of data.
      #
      # The +sdiff+ function of this module is implemented as call to
      # +traverse_balanced+.
    def traverse_balanced(a, b, callbacks = Diff::LCS::BalancedCallbacks)
      matches = Diff::LCS.__lcs(a, b)
      a_size = a.size
      b_size = b.size
      ai = bj = mb = 0
      ma = -1
      string = a.kind_of?(String)

        # Process all the lines in the match vector.
      loop do
          # Find next match indices +ma+ and +mb+
        loop do
          ma += 1
          break unless ma < matches.size and matches[ma].nil?
        end

        break if ma >= matches.size # end of matches?
        mb = matches[ma]

          # Change(s)
        while (ai < ma) or (bj < mb)
          ax = string ? a[ai, 1] : a[ai]
          bx = string ? b[bj, 1] : b[bj]

          case [(ai < ma), (bj < mb)]
          when [true, true]
            if callbacks.respond_to?(:change)
              event = Diff::LCS::Event.new(:change, ax, ai, bx, bj)
              callbacks.change(event)
              ai += 1
              bj += 1
            else
              event = Diff::LCS::Event.new(:discard_a, ax, ai, bx, bj)
              callbacks.discard_a(event)
              ai += 1
              ax = string ? a[ai, 1] : a[ai]
              event = Diff::LCS::Event.new(:discard_b, ax, ai, bx, bj)
              callbacks.discard_b(event)
              bj += 1
            end
          when [true, false]
            event = Diff::LCS::Event.new(:discard_a, ax, ai, bx, bj)
            callbacks.discard_a(event)
            ai += 1
          when [false, true]
            event = Diff::LCS::Event.new(:discard_b, ax, ai, bx, bj)
            callbacks.discard_b(event)
            bj += 1
          end
        end

          # Match
        ax = string ? a[ai, 1] : a[ai]
        bx = string ? b[bj, 1] : b[bj]
        event = Diff::LCS::Event.new(:discard_a, ax, ai, bx, bj)
        callbacks.match(event)
        ai += 1
        bj += 1
      end

      while (ai < a_size) or (bj < b_size)
        ax = string ? a[ai, 1] : a[ai]
        bx = string ? b[bj, 1] : b[bj]

        case [(ai < a_size), (bj < b_size)]
        when [true, true]
          if callbacks.respond_to?(:change)
            event = Diff::LCS::Event.new(:change, ax, ai, bx, bj)
            callbacks.change(event)
            ai += 1
            bj += 1
          else
            event = Diff::LCS::Event.new(:discard_a, a[ai], ai, b[bj], bj)
            callbacks.discard_a(event)
            ai += 1
            ax = string ? a[ai, 1] : a[ai]
            event = Diff::LCS::Event.new(:discard_b, a[ai], ai, b[bj], bj)
            callbacks.discard_b(event)
            bj += 1
          end
        when [true, false]
          event = Diff::LCS::Event.new(:discard_a, a[ai], ai, b[bj], bj)
          callbacks.discard_a(event)
          ai += 1
        when [false, true]
          event = Diff::LCS::Event.new(:discard_b, a[ai], ai, b[bj], bj)
          callbacks.discard_b(event)
          bj += 1
        end
      end
    end

    def __diff_direction(src, diffs)
      left = left_miss = right = right_miss = 0
      string = src.kind_of?(String)

      diffs.each do |change|
        text = string ? src[change.position, 1] : src[change.position]
        case change.action
        when :-
          if text == change.text
            left += 1
          else
            left_miss += 1
          end
        when :+
          if text == change.text
            right += 1
          else
            right_miss += 1
          end
        end
      end

      no_left = (left == 0) and (left_miss >= 0)
      no_right = (right == 0) and (right_miss >= 0)

      case [no_left, no_right]
      when [false, true]
        return :patch
      when [true, false]
        return :unpatch
      else
        raise "The provided diff does not appear to apply to the provided value as either source or destination value."
      end
    end

      # Given a set of diffs, convert the current version to the new version.
    def patch(src, diffs, direction = nil)
      diffs = diffs.flatten
      direction = Diff::LCS.__diff_direction(src, diffs) if direction.nil?
      string = src.kind_of?(String)

      n = src.class.new
      ai = bj = 0

      uses_splat = true

      diffs.each do |change|
        action = change.action

        if direction == :unpatch
          case action
          when :-
            action = :+
          when :+
            action = :-
          end
        end

        case action
        when :- # Delete
          while ai < change.position
            n << (string ? src[ai, 1] : src[ai])
            ai += 1
            bj += 1
          end
          ai += (change.text.kind_of?(String) ? 1 : change.text.size)
        when :+ # Insert
          while bj < change.position
            n << (string ? src[ai, 1]: src[ai])
            ai += 1
            bj += 1
          end

          if change.text.kind_of?(String)
            n << change.text
          else
            n.push(*change.text)
          end

          bj += (change.text.kind_of?(String) ? 1 : change.text.size)
        end
      end

      n
    end

      # Given a set of diffs, convert the current version to the prior
      # version.
    def unpatch(diffs)
      patch(diffs, :unpatch)
    end
  end
end
