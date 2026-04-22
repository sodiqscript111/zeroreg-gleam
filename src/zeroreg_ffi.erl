-module(zeroreg_ffi).
-export([escape/1, test/2, match/2, match_all/2, replace/3]).

escape(String) when is_binary(String) ->
    iolist_to_binary(quote_meta(binary_to_list(String))).

test(Source, Input) ->
    case compile(Source) of
        {ok, Regex} ->
            case re:run(Input, Regex, [{capture, none}]) of
                match -> true;
                nomatch -> false
            end;
        {error, _} ->
            false
    end.

match(Source, Input) ->
    case compile(Source) of
        {ok, Regex} ->
            case re:run(Input, Regex, [{capture, all, binary}]) of
                {match, Captures} -> {some, Captures};
                nomatch -> none
            end;
        {error, _} ->
            none
    end.

match_all(Source, Input) ->
    case compile(Source) of
        {ok, Regex} ->
            case re:run(Input, Regex, [global, {capture, all, binary}]) of
                {match, Captures} -> Captures;
                nomatch -> []
            end;
        {error, _} ->
            []
    end.

replace(Source, Input, Replacement) ->
    case compile(Source) of
        {ok, Regex} ->
            re:replace(Input, Regex, Replacement, [global, {return, binary}]);
        {error, _} ->
            Input
    end.

compile(Source) ->
    re:compile(Source, [unicode]).

quote_meta([]) ->
    [];
quote_meta([$\\ | Rest]) ->
    [$\\, $\\ | quote_meta(Rest)];
quote_meta([$. | Rest]) ->
    [$\\, $. | quote_meta(Rest)];
quote_meta([$^ | Rest]) ->
    [$\\, $^ | quote_meta(Rest)];
quote_meta([$$ | Rest]) ->
    [$\\, $$ | quote_meta(Rest)];
quote_meta([$* | Rest]) ->
    [$\\, $* | quote_meta(Rest)];
quote_meta([$+ | Rest]) ->
    [$\\, $+ | quote_meta(Rest)];
quote_meta([$? | Rest]) ->
    [$\\, $? | quote_meta(Rest)];
quote_meta([$( | Rest]) ->
    [$\\, $( | quote_meta(Rest)];
quote_meta([$) | Rest]) ->
    [$\\, $) | quote_meta(Rest)];
quote_meta([$[ | Rest]) ->
    [$\\, $[ | quote_meta(Rest)];
quote_meta([$] | Rest]) ->
    [$\\, $] | quote_meta(Rest)];
quote_meta([${ | Rest]) ->
    [$\\, ${ | quote_meta(Rest)];
quote_meta([$} | Rest]) ->
    [$\\, $} | quote_meta(Rest)];
quote_meta([$| | Rest]) ->
    [$\\, $| | quote_meta(Rest)];
quote_meta([Char | Rest]) ->
    [Char | quote_meta(Rest)].
