%%----------------------------------------------------------------
%% Copyright (c) 2020 Faceplate
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%----------------------------------------------------------------

-module(dlss_schema_sup).

-include("dlss.hrl").

-behaviour(supervisor).

%%=================================================================
%%	API
%%=================================================================
-export([
  start_link/0,
  start_segment/1,
  stop_segment/1
]).

%%=================================================================
%%	OTP
%%=================================================================
-export([init/1]).

-define(SERVER, ?MODULE).

-define(MAX_RESTARTS,10).
-define(MAX_PERIOD,1000).
-define(DEFAULT_SCAN_CYCLE,1000).
-define(DEFAULT_STOP_TIMEOUT,60000). % 1 min.

%%=================================================================
%%	API
%%=================================================================
start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_segment(Segment)->
  supervisor:start_child(?SERVER,[Segment]).

stop_segment(Segment)->
  supervisor:terminate_child(?SERVER,Segment).

%%=================================================================
%%	OTP
%%=================================================================
init([]) ->

  ?LOGINFO("starting schema supervisor",[self()]),

  ChildConfig = #{
    id=>dlss_segment,
    start=>{dlss_segment,start_link,[]},
    restart=>transient,
    shutdown=>?ENV(segment_stop_timeout, ?DEFAULT_STOP_TIMEOUT),
    type=>worker,
    modules=>[dlss_segment]
  },

  Supervisor=#{
    strategy=>simple_one_for_one,
    intensity=>?ENV(segemnt_max_restarts, ?MAX_RESTARTS),
    period=>?ENV(segemnt_max_period, ?MAX_PERIOD)
  },

  {ok, {Supervisor, [ChildConfig]}}.
