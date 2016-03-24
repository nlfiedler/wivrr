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

There will be a file named `Version` in `_build/default/lib/your-app`.

A more convenient means of running the `mkversion` is to use a provider hook. For example, to have the file generated when a release is built, add the following to your `rebar.config` file.

```
{provider_hooks, [{pre, [{release, mkversion}]}]}.
```

However, the file will not be in the release directory, so to include it in the release when running `rebar release`, use an overlay, like so.

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

## Development and Testing

Use the rebar3 [checkouts](http://blog.erlware.org/rebar3-features-part-6-_checkouts-2/
) feature to make developing and testing the plugin much easier. An abbreviated recipe is outlined below.

1. Add the plugin to the project in question (e.g. [kitsune](https://github.com/nlfiedler/kitsune))
1. Make a directory at the root of the project named `_checkouts`
1. Make a symlink to the original `wivrr` clone in `_checkouts`
1. Edit the wivrr source code as needed
1. Run the `rebar3 mkversion` command to test
1. Repeat those two previous steps as often as needed

## About the Name

It is an amusing misspelling by a certain former kindergartner.
