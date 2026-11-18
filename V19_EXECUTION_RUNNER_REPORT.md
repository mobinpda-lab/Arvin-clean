# V19 Execution Runner Report

**Runner workflow:** `.github/workflows/command-48-r-v19-compatibility.yml`  
**Execution status:** PENDING GitHub Actions run.

The runner:
1. Checks out exact approved source ref `310c0e20e3447c488c1e1c102c38bea5040708ca`.
2. Asserts the exact installer blob SHA `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`.
3. Resolves the historical lockfile without changing it.
4. extracts the immutable fixture from its source commit, verifies SHA-256, and copies it to a separate writable file.
5. Opens the working copy with a v7 read-only inspector and snapshots it.
6. Closes and reopens the same copy with the original v19 `G1DriftSchema.install` method.
7. Captures the post-install snapshot, schema objects, IDs, integrity and FK results.
8. Uploads logs and snapshots as a 90-day artifact.

The runner does not execute v20, change `user_version`, synthesize tables, replace SQL, or write to the tracked fixture.
