# Contributing

Contribution to diff-lcs is encouraged: bug reports, feature requests, or code
contributions. There are a few DOs and DON'Ts that should be followed.

## DO

- Keep the coding style that already exists for any updated Ruby code (support
  or otherwise). I use [Standard Ruby][standardrb] for linting and formatting.

- Use thoughtfully-named topic branches for contributions. Rebase your commits
  into logical chunks as necessary.

- Use [quality commit messages][qcm].

- Add your name or GitHub handle to `CONTRIBUTORS.md` and a record in the
  `CHANGELOG.md` as a separate commit from your main change. (Follow the style
  in the `CHANGELOG.md` and provide a link to your PR.)

- Add or update tests as appropriate for your change. The test suite is written
  in [RSpec][rspec].

- Add or update documentation as appropriate for your change. The documentation
  is RDoc; diff-lcs does not use extensions that may be present in alternative
  documentation generators.

## DO NOT

- Modify `VERSION` in `lib/diff/lcs/version.rb`. When your patch is accepted and
  a release is made, the version will be updated at that point.

- Modify `diff-lcs.gemspec`; it is a generated file. (You _may_ use
  `rake gemspec` to regenerate it if your change involves metadata related to
  gem itself).

- Modify the `Gemfile`.

## LLM-Generated Contribution Policy

diff-lcs is a library with complex interactions and subtle decisions (some of
them possibly even wrong). It is extremely important that any issues or pull
requests be well understood by the submitter and that, especially for pull
requests, the developer can attest to the [Developer Certificate of Origin][dco]
for each pull request (see [LICENCE](LICENCE.md)).

If LLM assistance is used in writing pull requests, this must be documented in
the commit message and pull request. If there is evidence of LLM assistance
without such declaration, the pull request **will be declined**.

Any contribution (bug, feature request, or pull request) that uses unreviewed
LLM output will be rejected.

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

[dco]: licences/dco.txt
[hoe]: https://github.com/seattlerb/hoe
[qcm]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[rspec]: http://rspec.info/documentation/
[standardrb]: https://github.com/standardrb/standard
