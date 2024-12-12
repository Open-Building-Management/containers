# automated builds

more about github matrix :

https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs#example-adding-configurations


# distribute builds across multiple runners

When you have different Dockerfilen one for armv7 and one for amd64 or arm64, the solution is to distribute works to multiple runners, to push using `push-by-digest=true` and then to use `docker buildx imagetools create` to create a manifest to regroup the different images produced

https://docs.docker.com/build/ci/github-actions/multi-platform/

The metadata action permits to tag properly as the docs.docker example uses the branch name as tag

https://github.com/docker/metadata-action?tab=readme-ov-file#typeraw

More info about labels and tags : https://www.docker.com/blog/docker-best-practices-using-tags-and-labels-to-manage-docker-image-sprawl/

Creating a reusable workflow using the inputs context may also be helping to create elaborated tags.

https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs#example-usage-of-the-inputs-context-in-a-manually-triggered-workflow

Finally, there is a simple way to pass information between jobs

https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/passing-information-between-jobs

## multistages docker

https://github.com/docker/buildx/issues/805

Some says to use mutistages build but I could not get this working properly



