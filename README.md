# wivrr

A [rebar3](https://www.rebar3.org) plugin that generates a `Version` file that includes some basic build information, including the current date and time, the SHA1 of the `HEAD` of the git repository, and the application version. This information can be useful when building a release of an Erlang/OTP application.

Note that it requires having a clean working directory, since the theory is that you are building a release based on a known Git commit, and you can't have one of those if you're building with uncommitted changes.

## Usage

First, register the plugin in your `rebar.config` file:

```
{plugins, [
    {wivrr, {git, "https://github.com/nlfiedler/wivrr.git", {tag, "1.0.0"}}}
]}.
```

Then, invoke the `mkversion` command via rebar:

```
$ rebar mkversion
```

There will be a file named `Version` in `_build/default/lib/your-app`. To include this file as part of the release when running `rebar release`, use an overlay, like so.

```
{relx, [
    % ...
    {overlay, [
        % It would be great if there were overlay vars for all of the parts in the
        % path to the generated Version file, but there does not seem to be any.
        {copy, "_build/default/lib/{{release_name}}/Version", "{{output_dir}}/Version"}
    ]}
]}.
```

## About the Name

It is an amusing misspelling by a kindergartner.
