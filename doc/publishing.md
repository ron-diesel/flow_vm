# Publishing

Stable releases are published by `.github/workflows/publish.yml` when a tag
such as `v1.2.3` is pushed. Ordinary branch pushes do not publish a package.
The official Dart workflow installs Flutter, resolves dependencies, checks the
package with a dry run, and publishes using a temporary GitHub OIDC token.
No pub.dev credentials need to be stored in GitHub secrets.

## One-time setup

1. Commit the workflow and push it to GitHub.
2. Open https://pub.dev/packages/flow_vm/admin as a package administrator.
3. Under **Automated publishing**, enable publishing from GitHub Actions:
   - Repository: `ron-diesel/flow_vm`
   - Tag pattern: `v{{version}}`
   - Leave the optional GitHub Actions environment requirement unset.

## Release a version

1. Update `version` in `pubspec.yaml` and add a matching `CHANGELOG.md` entry.
   Use a new version; pub.dev does not allow replacing an existing version.
2. Run `flutter test` and `flutter pub publish --dry-run`.
3. Review the files to be published, commit the release changes, and push them.
4. Tag that commit with the exact version from `pubspec.yaml` and push the tag:

   ```sh
   # Example only: pubspec.yaml must contain version: 1.1.2 first.
   git tag v1.1.2
   git push origin v1.1.2
   ```

5. Check https://github.com/ron-diesel/flow_vm/actions for the publishing result.

Only files in the tagged commit are published by CI. Local uncommitted files
are not included. The trigger above covers stable versions, not prereleases.

See the [Dart automated publishing documentation](https://dart.dev/tools/pub/automated-publishing).
