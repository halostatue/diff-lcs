var search_data = {"index":{"searchIndex":["array","diff","diff::lcs::internals","diff::lcs::ldiff","fixnum","lcs","balancedcallbacks","block","change","contextchange","contextdiffcallbacks","defaultcallbacks","diffcallbacks","htmldiff","hunk","sdiffcallbacks","sequencecallbacks","string","<=>()","<=>()","==()","==()","lcs()","adding?()","analyze_patchset()","callbacks_for()","change()","change()","change()","change()","change()","changed?()","deleting?()","diff()","diff()","diff()","diff_size()","discard_a()","discard_a()","discard_a()","discard_a()","discard_a()","discard_a()","discard_b()","discard_b()","discard_b()","discard_b()","discard_b()","discard_b()","finish()","finished_a?()","finished_b?()","from_a()","from_a()","inspect()","intuit_diff_direction()","lcs()","lcs()","lcs()","match()","match()","match()","match()","match()","merge()","missing_last_newline?()","new()","new()","new()","new()","new()","new()","new()","op()","overlaps?()","patch()","patch()","patch!()","patch!()","patch_me()","positive?()","run()","sdiff()","sdiff()","simplify()","to_a()","to_a()","to_ary()","to_ary()","traverse_balanced()","traverse_balanced()","traverse_sequences()","traverse_sequences()","unchanged?()","unpatch()","unpatch!()","unpatch!()","unpatch_me()","unshift()","valid_action?()","code-of-conduct","contributing","history","license","manifest","readme","copying","artistic"],"longSearchIndex":["array","diff","diff::lcs::internals","diff::lcs::ldiff","fixnum","lcs","lcs::balancedcallbacks","lcs::block","lcs::change","lcs::contextchange","lcs::contextdiffcallbacks","lcs::defaultcallbacks","lcs::diffcallbacks","lcs::htmldiff","lcs::hunk","lcs::sdiffcallbacks","lcs::sequencecallbacks","string","lcs::change#<=>()","lcs::contextchange#<=>()","lcs::change#==()","lcs::contextchange#==()","lcs::lcs()","lcs::change#adding?()","diff::lcs::internals::analyze_patchset()","lcs::callbacks_for()","lcs::contextdiffcallbacks#change()","lcs::defaultcallbacks::change()","lcs::defaultcallbacks::change()","lcs::defaultcallbacks::change()","lcs::sdiffcallbacks#change()","lcs::change#changed?()","lcs::change#deleting?()","lcs::diff()","lcs#diff()","lcs::hunk#diff()","lcs::block#diff_size()","lcs::contextdiffcallbacks#discard_a()","lcs::defaultcallbacks::discard_a()","lcs::defaultcallbacks::discard_a()","lcs::defaultcallbacks::discard_a()","lcs::diffcallbacks#discard_a()","lcs::sdiffcallbacks#discard_a()","lcs::contextdiffcallbacks#discard_b()","lcs::defaultcallbacks::discard_b()","lcs::defaultcallbacks::discard_b()","lcs::defaultcallbacks::discard_b()","lcs::diffcallbacks#discard_b()","lcs::sdiffcallbacks#discard_b()","lcs::diffcallbacks#finish()","lcs::change#finished_a?()","lcs::change#finished_b?()","lcs::change::from_a()","lcs::contextchange::from_a()","lcs::change#inspect()","diff::lcs::internals::intuit_diff_direction()","diff::lcs::internals::lcs()","lcs::lcs()","lcs#lcs()","lcs::defaultcallbacks::match()","lcs::defaultcallbacks::match()","lcs::defaultcallbacks::match()","lcs::diffcallbacks#match()","lcs::sdiffcallbacks#match()","lcs::hunk#merge()","lcs::hunk#missing_last_newline?()","lcs::block::new()","lcs::change::new()","lcs::contextchange::new()","lcs::diffcallbacks::new()","lcs::htmldiff::new()","lcs::hunk::new()","lcs::sdiffcallbacks::new()","lcs::block#op()","lcs::hunk#overlaps?()","lcs#patch()","lcs::patch()","lcs::patch!()","lcs#patch!()","lcs#patch_me()","fixnum#positive?()","lcs::htmldiff#run()","lcs#sdiff()","lcs::sdiff()","lcs::contextchange::simplify()","lcs::change#to_a()","lcs::contextchange#to_a()","lcs::change#to_ary()","lcs::contextchange#to_ary()","lcs::traverse_balanced()","lcs#traverse_balanced()","lcs::traverse_sequences()","lcs#traverse_sequences()","lcs::change#unchanged?()","lcs#unpatch()","lcs#unpatch!()","lcs::unpatch!()","lcs#unpatch_me()","lcs::hunk#unshift()","lcs::change::valid_action?()","","","","","","","",""],"info":[["Array","","Array.html","",""],["Diff","","Diff.html","",""],["Diff::LCS::Internals","","Diff/LCS/Internals.html","",""],["Diff::LCS::Ldiff","","Diff/LCS/Ldiff.html","",""],["Fixnum","","Fixnum.html","",""],["LCS","","LCS.html","","<p>How Diff Works (by Mark-Jason Dominus)\n<p>I once read an article written by the authors of <code>diff</code>; they said …\n"],["LCS::BalancedCallbacks","","LCS/DefaultCallbacks.html","","<p>This callback object implements the default set of callback events, which only returns the event itself. …\n"],["LCS::Block","","LCS/Block.html","","<p>A block is an operation removing, adding, or changing a group of items. Basically, this is just a list …\n"],["LCS::Change","","LCS/Change.html","","<p>Represents a simplistic (non-contextual) change. Represents the removal or addition of an element from …\n"],["LCS::ContextChange","","LCS/ContextChange.html","","<p>Represents a contextual change. Contains the position and values of the elements in the old and the new …\n"],["LCS::ContextDiffCallbacks","","LCS/ContextDiffCallbacks.html","","<p>This will produce a compound array of contextual diff change objects. Each element in the #diffs array …\n"],["LCS::DefaultCallbacks","","LCS/DefaultCallbacks.html","","<p>This callback object implements the default set of callback events, which only returns the event itself. …\n"],["LCS::DiffCallbacks","","LCS/DiffCallbacks.html","","<p>This will produce a compound array of simple diff change objects. Each element in the #diffs array is …\n"],["LCS::HTMLDiff","","LCS/HTMLDiff.html","","<p>Produce a simple HTML diff view.\n"],["LCS::Hunk","","LCS/Hunk.html","","<p>A Hunk is a group of Blocks which overlap because of the context surrounding each block. (So if we’re …\n"],["LCS::SDiffCallbacks","","LCS/SDiffCallbacks.html","","<p>This will produce a simple array of diff change objects. Each element in the #diffs array is a single …\n"],["LCS::SequenceCallbacks","","LCS/DefaultCallbacks.html","","<p>This callback object implements the default set of callback events, which only returns the event itself. …\n"],["String","","String.html","",""],["<=>","LCS::Change","LCS/Change.html#method-i-3C-3D-3E","(other)",""],["<=>","LCS::ContextChange","LCS/ContextChange.html#method-i-3C-3D-3E","(other)",""],["==","LCS::Change","LCS/Change.html#method-i-3D-3D","(other)",""],["==","LCS::ContextChange","LCS/ContextChange.html#method-i-3D-3D","(other)",""],["LCS","LCS","LCS.html#method-c-LCS","(seq1, seq2)",""],["adding?","LCS::Change","LCS/Change.html#method-i-adding-3F","()",""],["analyze_patchset","Diff::LCS::Internals","Diff/LCS/Internals.html#method-c-analyze_patchset","(patchset, depth = 0)","<p>This method will analyze the provided patchset to provide a single-pass normalization (conversion of …\n"],["callbacks_for","LCS","LCS.html#method-c-callbacks_for","(callbacks)",""],["change","LCS::ContextDiffCallbacks","LCS/ContextDiffCallbacks.html#method-i-change","(event)",""],["change","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-change","(event)","<p>Called when both the old and new values have changed.\n"],["change","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-change","(event)","<p>Called when both the old and new values have changed.\n"],["change","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-change","(event)","<p>Called when both the old and new values have changed.\n"],["change","LCS::SDiffCallbacks","LCS/SDiffCallbacks.html#method-i-change","(event)",""],["changed?","LCS::Change","LCS/Change.html#method-i-changed-3F","()",""],["deleting?","LCS::Change","LCS/Change.html#method-i-deleting-3F","()",""],["diff","LCS","LCS.html#method-c-diff","(seq1, seq2, callbacks = nil)","<p>#diff computes the smallest set of additions and deletions necessary to turn the first sequence into …\n"],["diff","LCS","LCS.html#method-i-diff","(other, callbacks = nil, &block)","<p>Returns the difference set between <code>self</code> and <code>other</code>. See Diff::LCS#diff.\n"],["diff","LCS::Hunk","LCS/Hunk.html#method-i-diff","(format, last = false)","<p>Returns a diff string based on a format.\n"],["diff_size","LCS::Block","LCS/Block.html#method-i-diff_size","()",""],["discard_a","LCS::ContextDiffCallbacks","LCS/ContextDiffCallbacks.html#method-i-discard_a","(event)",""],["discard_a","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-discard_a","(event)","<p>Called when the old value is discarded in favour of the new value.\n"],["discard_a","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-discard_a","(event)","<p>Called when the old value is discarded in favour of the new value.\n"],["discard_a","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-discard_a","(event)","<p>Called when the old value is discarded in favour of the new value.\n"],["discard_a","LCS::DiffCallbacks","LCS/DiffCallbacks.html#method-i-discard_a","(event)",""],["discard_a","LCS::SDiffCallbacks","LCS/SDiffCallbacks.html#method-i-discard_a","(event)",""],["discard_b","LCS::ContextDiffCallbacks","LCS/ContextDiffCallbacks.html#method-i-discard_b","(event)",""],["discard_b","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-discard_b","(event)","<p>Called when the new value is discarded in favour of the old value.\n"],["discard_b","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-discard_b","(event)","<p>Called when the new value is discarded in favour of the old value.\n"],["discard_b","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-discard_b","(event)","<p>Called when the new value is discarded in favour of the old value.\n"],["discard_b","LCS::DiffCallbacks","LCS/DiffCallbacks.html#method-i-discard_b","(event)",""],["discard_b","LCS::SDiffCallbacks","LCS/SDiffCallbacks.html#method-i-discard_b","(event)",""],["finish","LCS::DiffCallbacks","LCS/DiffCallbacks.html#method-i-finish","()","<p>Finalizes the diff process. If an unprocessed hunk still exists, then it is appended to the diff list. …\n"],["finished_a?","LCS::Change","LCS/Change.html#method-i-finished_a-3F","()",""],["finished_b?","LCS::Change","LCS/Change.html#method-i-finished_b-3F","()",""],["from_a","LCS::Change","LCS/Change.html#method-c-from_a","(arr)",""],["from_a","LCS::ContextChange","LCS/ContextChange.html#method-c-from_a","(arr)",""],["inspect","LCS::Change","LCS/Change.html#method-i-inspect","(*_args)",""],["intuit_diff_direction","Diff::LCS::Internals","Diff/LCS/Internals.html#method-c-intuit_diff_direction","(src, patchset, limit = nil)","<p>Examine the patchset and the source to see in which direction the patch should be applied.\n<p>WARNING: By …\n"],["lcs","Diff::LCS::Internals","Diff/LCS/Internals.html#method-c-lcs","(a, b)","<p>Compute the longest common subsequence between the sequenced Enumerables <code>a</code> and <code>b</code>. The result is an array …\n"],["lcs","LCS","LCS.html#method-c-lcs","(seq1, seq2)",""],["lcs","LCS","LCS.html#method-i-lcs","(other)","<p>Returns an Array containing the longest common subsequence(s) between <code>self</code> and <code>other</code>. See Diff::LCS#lcs …\n"],["match","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-match","(event)","<p>Called when two items match.\n"],["match","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-match","(event)","<p>Called when two items match.\n"],["match","LCS::DefaultCallbacks","LCS/DefaultCallbacks.html#method-c-match","(event)","<p>Called when two items match.\n"],["match","LCS::DiffCallbacks","LCS/DiffCallbacks.html#method-i-match","(_event)",""],["match","LCS::SDiffCallbacks","LCS/SDiffCallbacks.html#method-i-match","(event)",""],["merge","LCS::Hunk","LCS/Hunk.html#method-i-merge","(hunk)","<p>Merges this hunk and the provided hunk together if they overlap. Returns a truthy value so that if there …\n"],["missing_last_newline?","LCS::Hunk","LCS/Hunk.html#method-i-missing_last_newline-3F","(data)",""],["new","LCS::Block","LCS/Block.html#method-c-new","(chunk)",""],["new","LCS::Change","LCS/Change.html#method-c-new","(*args)",""],["new","LCS::ContextChange","LCS/ContextChange.html#method-c-new","(*args)",""],["new","LCS::DiffCallbacks","LCS/DiffCallbacks.html#method-c-new","()",""],["new","LCS::HTMLDiff","LCS/HTMLDiff.html#method-c-new","(left, right, options = nil)",""],["new","LCS::Hunk","LCS/Hunk.html#method-c-new","(data_old, data_new, piece, flag_context, file_length_difference)","<p>Create a hunk using references to both the old and new data, as well as the piece of data.\n"],["new","LCS::SDiffCallbacks","LCS/SDiffCallbacks.html#method-c-new","()",""],["op","LCS::Block","LCS/Block.html#method-i-op","()",""],["overlaps?","LCS::Hunk","LCS/Hunk.html#method-i-overlaps-3F","(hunk)","<p>Determines whether there is an overlap between this hunk and the provided hunk. This will be true if …\n"],["patch","LCS","LCS.html#method-i-patch","(patchset)","<p>Attempts to patch <code>self</code> with the provided <code>patchset</code>. A new sequence based on <code>self</code> and the <code>patchset</code> will …\n"],["patch","LCS","LCS.html#method-c-patch","(src, patchset, direction = nil)","<p>Applies a <code>patchset</code> to the sequence <code>src</code> according to the <code>direction</code> (<code>:patch</code> or <code>:unpatch</code>), producing a new …\n"],["patch!","LCS","LCS.html#method-c-patch-21","(src, patchset)","<p>Given a set of patchset, convert the current version to the next version. Does no auto-discovery.\n"],["patch!","LCS","LCS.html#method-i-patch-21","(patchset)","<p>Attempts to patch <code>self</code> with the provided <code>patchset</code>. A new sequence based on <code>self</code> and the <code>patchset</code> will …\n"],["patch_me","LCS","LCS.html#method-i-patch_me","(patchset)","<p>Attempts to patch <code>self</code> with the provided <code>patchset</code>, using #patch!. If the sequence this is used on supports …\n"],["positive?","Fixnum","Fixnum.html#method-i-positive-3F","()",""],["run","LCS::HTMLDiff","LCS/HTMLDiff.html#method-i-run","()",""],["sdiff","LCS","LCS.html#method-i-sdiff","(other, callbacks = nil, &block)","<p>Returns the balanced (“side-by-side”) difference set between <code>self</code> and <code>other</code>. See Diff::LCS#sdiff …\n"],["sdiff","LCS","LCS.html#method-c-sdiff","(seq1, seq2, callbacks = nil)","<p>#sdiff computes all necessary components to show two sequences and their minimized differences side by …\n"],["simplify","LCS::ContextChange","LCS/ContextChange.html#method-c-simplify","(event)","<p>Simplifies a context change for use in some diff callbacks. ‘&lt;’ actions are converted to ‘-’ …\n"],["to_a","LCS::Change","LCS/Change.html#method-i-to_a","()",""],["to_a","LCS::ContextChange","LCS/ContextChange.html#method-i-to_a","()",""],["to_ary","LCS::Change","LCS/Change.html#method-i-to_ary","()",""],["to_ary","LCS::ContextChange","LCS/ContextChange.html#method-i-to_ary","()",""],["traverse_balanced","LCS","LCS.html#method-c-traverse_balanced","(seq1, seq2, callbacks = Diff::LCS::BalancedCallbacks)","<p>#traverse_balanced is an alternative to #traverse_sequences. It uses a different algorithm to iterate …\n"],["traverse_balanced","LCS","LCS.html#method-i-traverse_balanced","(other, callbacks = nil, &block)","<p>Traverses the discovered longest common subsequences between <code>self</code> and <code>other</code> using the alternate, balanced …\n"],["traverse_sequences","LCS","LCS.html#method-c-traverse_sequences","(seq1, seq2, callbacks = Diff::LCS::SequenceCallbacks)","<p>#traverse_sequences is the most general facility provided by this module; #diff and #lcs are implemented …\n"],["traverse_sequences","LCS","LCS.html#method-i-traverse_sequences","(other, callbacks = nil, &block)","<p>Traverses the discovered longest common subsequences between <code>self</code> and <code>other</code>. See Diff::LCS#traverse_sequences …\n"],["unchanged?","LCS::Change","LCS/Change.html#method-i-unchanged-3F","()",""],["unpatch","LCS","LCS.html#method-i-unpatch","(patchset)",""],["unpatch!","LCS","LCS.html#method-i-unpatch-21","(patchset)","<p>Attempts to unpatch <code>self</code> with the provided <code>patchset</code>. A new sequence based on <code>self</code> and the <code>patchset</code> will …\n"],["unpatch!","LCS","LCS.html#method-c-unpatch-21","(src, patchset)","<p>Given a set of patchset, convert the current version to the prior version. Does no auto-discovery.\n"],["unpatch_me","LCS","LCS.html#method-i-unpatch_me","(patchset)","<p>Attempts to unpatch <code>self</code> with the provided <code>patchset</code>, using #unpatch!. If the sequence this is used on …\n"],["unshift","LCS::Hunk","LCS/Hunk.html#method-i-unshift","(hunk)",""],["valid_action?","LCS::Change","LCS/Change.html#method-c-valid_action-3F","(action)",""],["Code-of-Conduct","","Code-of-Conduct_md.html","","<p>Contributor Covenant Code of Conduct\n<p>Our Pledge\n<p>In the interest of fostering an open and welcoming environment, …\n"],["Contributing","","Contributing_md.html","","<p>Contributing\n<p>I value any contribution to Diff::LCS you can provide: a bug report, a\nfeature request, or ...\n"],["History","","History_md.html","","<p>History\n<p>1.5.1 / 2024-01-31\n<p>Peter Goldstein updated CI configuration to add Ruby 3.1 and Masato Nakamura ...\n"],["License","","License_md.html","","<p>License\n<p>This software is available under three licenses: the GNU GPL version 2 (or at\nyour option, a later ...\n"],["Manifest","","Manifest_txt.html","","<p>.rspec Code-of-Conduct.md Contributing.md History.md License.md Manifest.txt README.rdoc Rakefile bin/htmldiff …\n"],["README","","README_rdoc.html","","<p>Diff::LCS\n<p>home  &mdash; github.com/halostatue/diff-lcs\n<p>code  &mdash; github.com/halostatue/diff-lcs\n"],["COPYING","","docs/COPYING_txt.html","","\n<pre>                   GNU GENERAL PUBLIC LICENSE\n                      Version 2, June 1991\n\nCopyright (C) ...</pre>\n"],["artistic","","docs/artistic_txt.html","","<p>The “Artistic License”\n\n<pre class=\"ruby\"><span class=\"ruby-constant\">Preamble</span>\n</pre>\n<p>The intent of this document is to state the conditions under …\n"]]}}