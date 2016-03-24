%% -*- coding: utf-8 -*-
%% -------------------------------------------------------------------
%%
%% Copyright (c) 2016 Nathan Fiedler
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License. You may obtain
%% a copy of the License at
%%
%% http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied. See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------
-module(wivrr_prv).
-behaviour(provider).
-export([init/1, do/1, format_error/1]).

-define(PROVIDER, mkversion).
-define(DEPS, [app_discovery]).

-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    Provider = providers:create([
        {name, ?PROVIDER},
        {module, ?MODULE},
        {bare, true},
        {deps, ?DEPS},
        {example, "rebar3 mkversion"},
        {opts, []},
        {short_desc, "Generates a Version file for the application"},
        {desc, "Ensures git working directory is clean, then generates "
               "a Version file that includes the current date and time, "
               "as well as the Git repository HEAD commit SHA1."}
    ]),
    {ok, rebar_state:add_provider(State, Provider)}.

-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
    lists:foreach(fun check_git_status/1, rebar_state:project_apps(State)),
    {ok, State}.

-spec format_error(any()) -> iolist().
format_error(Reason) ->
    io_lib:format("~p", [Reason]).

% Ensure the git working tree is clean, and then generate the Version file.
check_git_status(App) ->
    case os:cmd("git status --porcelain") of
        [] -> generate_version(App);
        _ ->  rebar_api:abort("mkversion: git working tree must be clean!", [])
    end.

% Generate the Version file so it contains the current date/time and the
% HEAD SHA1 of the git repository containing this application.
generate_version(App) ->
    {{Y, M, D}, {H, Mm, S}} = erlang:localtime(),
    DateTime = io_lib:format("~4.10.0B-~2.10.0B-~2.10.0B ~2.10.0B:~2.10.0B:~2.10.0B",
        [Y, M, D, H, Mm, S]),
    Commit = string:strip(os:cmd("git log --max-count=1 --pretty='%h'"), right, $\n),
    AppDetails = rebar_app_info:app_details(App),
    Version = proplists:get_value(vsn, AppDetails),
    Vsn = io_lib:format("Version: ~s~nBuild Date: ~s~nHEAD Commit: ~s~n",
        [Version, DateTime, Commit]),
    VsnBytes = list_to_binary(lists:flatten(Vsn)),
    OutputDir = rebar_app_info:out_dir(App),
    ok = file:write_file(filename:join(OutputDir, "Version"), VsnBytes),
    ok.
