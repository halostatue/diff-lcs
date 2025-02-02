# Contributing

Contribution to diff-lcs is encouraged in any form: a bug report, a feature
request, or code contributions. There are a few DOs and DON'Ts for

- DO:

  - Keep the coding style that already exists for any updated Ruby code (support
    or otherwise). I use [Standard Ruby][standardrb] for linting and formatting.

  - Use thoughtfully-named topic branches for contributions. Rebase your commits
    into logical chunks as necessary.

  - Use [quality commit messages][qcm].

  - Add your name or GitHub handle to `CONTRIBUTORS.md` and a record in the
    `CHANGELOG.md` as a separate commit from your main change. (Follow the style
    in the `CHANGELOG.md` and provide a link to your PR.)

  - Add or update tests, written in [RSpec][rspec], as appropriate.

  - Add or update documentation, as appropriate.

- DO NOT:

  - Modify `VERSION` in `lib/diff/lcs.rb`. When your patch is accepted and a
    release is made, the version will be updated at that point.

  - Modify `diff-lcs.gemspect`; it is a generated file. (You _may_ use
    `rake gemspec` to regenerate it if your change involves metadata related to
    gem itself).

  - Modify the `Gemfile`.

## Test Dependencies

diff-lcs uses Ryan Davis's [Hoe][Hoe] to manage the release process, and it adds
a number of rake tasks. You will mostly be interested in `rake`, which runs
tests in the same way that `rake spec` does.

To assist with the installation of the development dependencies for diff-lcs, I
have provided a Gemfile pointing to the (generated) `diff-lcs.gemspec` file.
`minitar.gemspec` file. This will permit you to use `bundle install` to install
the dependencies.

You can run tests with code coverage analysis by running `rake spec:coverage`.

## Workflow

Here's the most direct way to get your work merged into the project:

- Fork the project.
- Clone your fork (`git clone git://github.com/<username>/diff-lcs.git`).
- Create a topic branch to contain your change
  (`git checkout -b my_awesome_feature`).
- Hack away, add tests. Not necessarily in that order.
- Make sure everything still passes by running `rake`.
- If necessary, rebase your commits into logical chunks, without errors.
- Push the branch up (`git push origin my_awesome_feature`).
- Create a pull request against halostatue/diff-lcs and describe what your
  change does and the why you think it should be merged.

### Help Wanted

I want to automated the releases. I am **not** switching from Hoe for release
management, so the use of [rubygems/release-gem][release-gem] requires some care
(perhaps by exporting `VERSION=$(rake version)` to the job), but assistance in
getting this action going for an automated release would be greatly appreciated.

[hoe]: https://github.com/seattlerb/hoe
[qcm]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[release-gem]: https://github.com/rubygems/release-gem
[rspec]: http://rspec.info/documentation/
[standardrb]: https://github.com/standardrb/standard
