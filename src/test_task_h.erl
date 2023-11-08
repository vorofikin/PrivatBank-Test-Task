-module(test_task_h).

-export([init/2]).

init(#{method := <<"GET">>} = Req, Opts) ->
	B = <<"[{\"ccy\":\"EUR\",\"base_ccy\":\"UAH\",\"buy\":\"39.40000\",\"sale\":\"40.40000\"},{\"ccy\":\"USD\",\"base_ccy\":\"UAH\",\"buy\":\"36.80000\",\"sale\":\"37.40000\"}]"/utf8>>,
%%	A = jsx:decode(B),
%%	io:format("~p~n", [xmerl:export_simple(B, xmerl_xml)]),
	io:format("1~p~n", [exomler:encode(B)]),
	{ok, Body, _Req1} = cowboy_req:read_body(Req),
	Pid = proplists:get_value(pid, Opts),
	Result = request_handler(Pid),
	io:format("6"),
	Response = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/plain">>
	}, jsx:encode(Result), Req),
	io:format("7"),
	io:format("~p~n", [jsx:decode(<<Result/utf8>>, [return_maps])]),
	{ok, Response, Opts}.

request_handler(Pid) ->
	io:format("2~n"),
	Result = gen_server:call(Pid, currency),
	Result.