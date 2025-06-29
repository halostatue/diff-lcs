# Licence

- SPDX-License-Identifier: [MIT][mit] OR [GPL-2.0-or-later][gpl2-or-later] OR
  [Artistic-1.0-Perl][artistic-perl]

This software is available under three disjunctive licences: the GNU GPL version
2 (or at your option, a later version), the Perl Artistic license, or the MIT
license. Note that my preference for licensing is the MIT license, but
Algorithm::Diff was dually originally licensed with the Perl Artistic and the
GNU GPL ("the same terms as Perl itself") and given that the Ruby implementation
originally hewed pretty closely to the Perl version, I must maintain the
additional licensing terms.

- Copyright 2004-2025 Austin Ziegler and contributors.
- Adapted from Algorithm::Diff (Perl) by Ned Konz and a Smalltalk version by
  Mario I. Wolczko.

## MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Perl Artistic License

See [licences/artistic.txt](licences/artistic.txt) in the main distribution.

## GNU GPL version 2

See the file [licences/COPYING.txt](licences/COPYING.txt) in the main
distribution.

## Developer Certificate of Origin

All contributors **must** certify they are willing and able to provide their
contributions under the terms of _all_ of this project's licences with the
certification of the [Developer Certificate of Origin (Version 1.1)][dco].

Such certification is provided by ensuring that a `Signed-off-by`
[commit trailer][trailer] is present on every commit:

    Signed-off-by: FirstName LastName <email@example.org>

The `Signed-off-by` trailer can be automatically added by git with the `-s` or
`--signoff` option on `git commit`:

```sh
git commit --signoff
```

[artistic-perl]: https://spdx.org/licenses/Artistic-1.0-Perl.html
[gpl2-or-later]: https://spdx.org/licenses/GPL-2.0-or-later.html
[mit]: https://spdx.org/licenses/MIT.html
[trailer]: https://git-scm.com/docs/git-interpret-trailers
[dco]: licences/dco.txt
