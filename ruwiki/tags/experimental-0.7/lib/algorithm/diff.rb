#
# algorith/diff - a Ruby module to compute difference sets between two
# objects. Copyright (c) 2001-2002 Lars Christensen.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.
#

module Diff

  VERSION = 0.4

  attr_reader :diffs

  def Diff.lcs(a, b)
    astart = 0
    bstart = 0
    afinish = a.length-1
    bfinish = b.length-1
    mvector = []
    
    # First we prune off any common elements at the beginning
    while (astart <= afinish && bstart <= afinish && a[astart] == b[bstart])
      mvector[astart] = bstart
      astart += 1
      bstart += 1
    end
    
    # now the end
    while (astart <= afinish && bstart <= bfinish && a[afinish] == b[bfinish])
      mvector[afinish] = bfinish
      afinish -= 1
      bfinish -= 1
    end

    bmatches = b.reverse_hash(bstart..bfinish)
    thresh = []
    links = []
    
    (astart..afinish).each { |aindex|
      aelem = a[aindex]
      next unless bmatches.has_key? aelem
      k = nil
      bmatches[aelem].reverse_each { |bindex|
	if k && (thresh[k] > bindex) && (thresh[k-1] < bindex)
	  thresh[k] = bindex
	else
	  k = thresh.replacenextlarger(bindex, k)
	end
	links[k] = [ k!=0 && links[k-1], aindex, bindex ] if k
      }
    }

    if !thresh.empty?
      link = links[thresh.length-1]
      while link
	mvector[link[1]] = link[2]
	link = link[0]
      end
    end

    return mvector
  end

  def Diff.makediff(a, b)
    mvector = Diff.lcs(a, b)
    ai = bi = 0
    while ai < mvector.length
      bline = mvector[ai]
      if bline
	while bi < bline
	  yield :+, bi, b[bi]
	  bi += 1
	end
	bi += 1
      else
	yield :-, ai, a[ai]
      end
      ai += 1
    end
    while ai < a.length
      yield :-, ai, a[ai]
      ai += 1
    end
    while bi < b.length
      yield :+, bi, b[bi]
      bi += 1
    end
    1
  end

  def Diff.diff(a, b, &block)
    isstring = b.kind_of? String
    diffs = []

    block ||= proc { |action, index, element|
      prev = diffs[-1]
      if prev && prev[0] == action && 
	  prev[1] + prev[2].length == index
	prev[2] << element
      else
	diffs.push [ action, index, isstring ? element.chr : [element] ]
      end
    }

    Diff.makediff(a, b, &block)

    return diffs
  end

end

module Diffable
  def diff(b)
    Diff.diff(self, b)
  end

  # Create a hash that maps elements of the array to arrays of indices
  # where the elements are found.

  def reverse_hash(range = (0...self.length))
    revmap = {}
    range.each { |i|
      elem = self[i]
      if revmap.has_key? elem
	revmap[elem].push i
      else
	revmap[elem] = [i]
      end
    }
    return revmap
  end

  # Replace the first element which is larger than value. Assumes that
  # the element indexed by high, if given is larger than value.

  def replacenextlarger(value, high = nil)
    high ||= length
    low = 0
    index = found = nil
    while low < high
      index = (high+low) >> 1
      found = self[index]
      if value > found		# this first, most common case
	low = index + 1
      elsif value == found
	return nil
      else
	high = index
      end
    end
    self[low] = value
    return low
  end

  # Patches self with the given set of differences.

  def patch(diffs)
    newary = nil
    kindofstring = kind_of? String
    if kindofstring
      newary = self.class.new('')
    else
      newary = self.class.new
    end
    ai = 0
    bi = 0
    diffs.each { |action,position,elements|
      case action
      when :-
	while ai < position
	  newary << self[ai]
	  ai += 1
	  bi += 1
	end
	ai += elements.length
      when :+
	while bi < position
	  newary << self[ai]
	  ai += 1
	  bi += 1
	end
	if kindofstring
	  newary << elements
	else
	  newary.push *elements
	end
	bi += elements.length
      else
	raise "Unknown diff action"
      end
    }
    while ai < self.length
      newary << self[ai]
      ai += 1
      bi += 1
    end
    return newary
  end
end

class Array
  include Diffable
end

class String
  include Diffable
end
