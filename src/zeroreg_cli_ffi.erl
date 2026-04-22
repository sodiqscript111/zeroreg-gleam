-module(zeroreg_cli_ffi).
-export([argv/0]).

argv() ->
    init:get_plain_arguments().
