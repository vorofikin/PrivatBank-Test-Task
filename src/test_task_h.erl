-module(test_task_h).

-export([init/2]).

init(#{method := <<"GET">>} = Req, Opts) ->
	{ok, _Body, _Req1} = cowboy_req:read_body(Req),
	Pid = proplists:get_value(pid, Opts),
	Result = request_handler(Pid),
	Response = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/xml">>
	}, Result, Req),
	{ok, Response, Opts}.

request_handler(Pid) ->
	io:format("2~n"),
	Result = gen_server:call(Pid, currency),
	Result.