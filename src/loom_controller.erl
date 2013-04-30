-module(loom_controller).

-behaviour(gen_server).

-include("../include/loom.hrl").

-export([start/0,start/1,start_link/0,start_link/1,get_state/0,get_pid/0,get_connections/0,
	clear_all_flow_mods/0,broadcast_flow_mod/1,broken_call/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

start()->
    start_link().

start(Port)->
    start_link(Port).

start_link()->
    start_link(?DEFAULT_CNTL_PORT).

start_link(Port)->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [{port,Port}], []).

init(State)->
    [{port,Port}]=State,
    {ok,CtrlPid} = of_controller_v4:start(Port),
    NewState = State ++ [{pid,CtrlPid}],
    {ok,NewState}.
    
broken_call()->
    gen_server:call(?MODULE, broken_call).
    
get_pid()->		   
    gen_server:call(?MODULE, get_pid).
    
get_state()->		   
    gen_server:call(?MODULE, get_state).

get_connections()->		   
    gen_server:call(?MODULE, get_connections).

clear_all_flow_mods()->
    gen_server:call(?MODULE, clear_all_flow_mods).

broadcast_flow_mod(Flow)->
    gen_server:call(?MODULE, {broadcast_flow_mod,Flow}).

    
%% callbacks
handle_call(get_state, _From, State) ->
    io:format("Loom controller = ~p~n", [State]),
    {reply, State, State};

handle_call(get_pid, _From, State) ->
    Pid = get_pid(State),
    io:format("Loom controller Pid = ~p~n", [Pid]),
    {reply, Pid, State};

handle_call(get_connections, _From, State) ->
    Connections = get_connections(State),
    io:format("Loom controller Connections = ~p~n", [Connections]),
    {reply, Connections, State};

handle_call({broadcast_flow_mod, FlowMod} , _From, State) ->
    Reply = broadcast_flow_mod(State,FlowMod),
    io:format("Adding a flow mod to all switches!~n"),
    {reply, Reply, State};

handle_call(clear_all_flow_mods, _From, State) ->
    Reply = clear_all_flow_mods(State),
    io:format("Removing all flows from all switches!~n"),
    {reply, Reply, State};

handle_call(broken_call, _From, State) ->
    fake_module:broken_call(),
    {reply, error, State};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% implementaion

get_pid(State)->
    {pid,Pid} = lists:keyfind(pid,1,State),
    Pid.

get_connections(State)->
    CtrlPid = get_pid(State),
    {ok,Connections} = of_controller_v4:get_connections(CtrlPid),
    Connections.

broadcast_flow_mod(State,FlowMod)->
    CtrlPid = get_pid(State),
    Connections = get_connections(State),
    [Conn|_] = Connections,  %% TODO: handle all connections
    of_controller_v4:send(CtrlPid, Conn, FlowMod).


clear_all_flow_mods(State)->
    CtrlPid = get_pid(State),
    Connections = get_connections(State),
    [Conn|_] = Connections,  %% TODO: handle all connections
    FlowMod = loom_flow_lib:clear_all_flows_mod(),
    of_controller_v4:send(CtrlPid, Conn, FlowMod).


    
