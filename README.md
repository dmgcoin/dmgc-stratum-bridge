# DMGC Stratum Adapter

This is a lightweight daemon that allows mining to a local (or remote) dmgc node using stratum-base miners.

This daemon is confirmed working with the miners below in both dmgc-only and dual-mining modes (for those that support it) on Windows/MacOs/Linux/HiveOs.
* bzminer
* lolminer
* srbminer
* teamreadminer
* IceRiver ASICs <font size="1">[*(setup details)*](#iceriver-asics-configuration-details)</font>

Hive setup: [detailed instructions here](docs/hive-setup.md) 

Discord discussions/issues: [here](https://discord.com/channels/599153230659846165/1025501807570600027) 

Huge shoutout to https://github.com/KaffinPX/KStratum for the inspiration
  
Tips appreciated: 
- [@onemorebsmith](https://github.com/onemorebsmith): `kaspa:qp9v6090sr8jjlkq7r3f4h9un5rtfhu3raknfg3cca9eapzee57jzew0kxwlp`
- [@rdugan](https://github.com/rdugan): `kaspa:qrkhyhej7h0gmmvsuf8mmufget4n4xnlwx5j360sz70q7xvu0hlaxfmt9p8j8`


# Features:

### Shares-based work allocation with miner-like periodic stat output

```
===============================================================================
  worker name   |  avg hashrate  |   acc/stl/inv  |    blocks    |    uptime   
-------------------------------------------------------------------------------
 octo12_1       |      43.36GH/s |       1183/0/0 |            1 |      53m18s
 pc             |     758.97MH/s |       1017/0/0 |            0 |      52m54s
-------------------------------------------------------------------------------
                |      44.12GH/s |       2200/0/0 |            1 |      53m20s
========================================================== ks_bridge_v1.1.7 ===
```


### Optional monitoring UI

Detailed setup [instructions](/docs/monitoring-setup.md) 

![Monitoring Dashboard](/docs/images/dashboard.png)


### Prometheus API

If the app is run with the `-prom={port}` flag the application will host stats on the port specified by `{port}`, these stats are documented in the file [prom.go](src/dmgcstratum/prom.go). This is intended to be use by prometheus but the stats can be fetched and used independently if desired. `curl http://localhost:2114/metrics | grep ks_` will get a listing of current stats. All published stats have a `ks_` prefix for ease of use.

```
user:~$ curl http://localhost:2114/metrics | grep ks_
# HELP ks_estimated_network_hashrate_gauge Gauge representing the estimated network hashrate
# TYPE ks_estimated_network_hashrate_gauge gauge
ks_estimated_network_hashrate_gauge 2.43428982879776e+14
# HELP ks_network_block_count Gauge representing the network block count
# TYPE ks_network_block_count gauge
ks_network_block_count 271966
# HELP ks_network_difficulty_gauge Gauge representing the network difficulty
# TYPE ks_network_difficulty_gauge gauge
ks_network_difficulty_gauge 1.2526479386202519e+14
# HELP ks_valid_share_counter Number of shares found by worker over time
# TYPE ks_valid_share_counter counter
ks_valid_share_counter{ip="192.168.0.17",miner="SRBMiner-MULTI/1.0.8",wallet="dmg:qzk3uh2twkhu0fmuq50mdy3r2yzuwqvstq745hxs7tet25hfd4egcafcdmpdl",worker="002"} 276
ks_valid_share_counter{ip="192.168.0.24",miner="BzMiner-v11.1.0",wallet="dmg:qzk3uh2twkhu0fmuq50mdy3r2yzuwqvstq745hxs7tet25hfd4egcafcdmpdl",worker="003"} 43
ks_valid_share_counter{ip="192.168.0.65",miner="BzMiner-v11.1.0",wallet="dmg:qzk3uh2twkhu0fmuq50mdy3r2yzuwqvstq745hxs7tet25hfd4egcafcdmpdl",worker="001"} 307
# HELP ks_worker_job_counter Number of jobs sent to the miner by worker over time
# TYPE ks_worker_job_counter counter
ks_worker_job_counter{ip="192.168.0.17",miner="SRBMiner-MULTI/1.0.8",wallet="dmg:qzk3uh2twkhu0fmuq50mdy3r2yzuwqvstq745hxs7tet25hfd4egcafcdmpdl",worker="002"} 3471
ks_worker_job_counter{ip="192.168.0.24",miner="BzMiner-v11.1.0",wallet="dmg:qzk3uh2twkhu0fmuq50mdy3r2yzuwqvstq745hxs7tet25hfd4egcafcdmpdl",worker="003"} 3399
ks_worker_job_counter{ip="192.168.0.65",miner="BzMiner-v11.1.0",wallet="dmg:qzk3uh2twkhu0fmuq50mdy3r2yzuwqvstq745hxs7tet25hfd4egcafcdmpdl",worker="001"} 3425

```

# Installation

## Build from source (native executable)

Install go 1.18 using whatever package manager is approprate for your system.

run `cd cmd/dmgcbridge;go build .`

Modify the config file in ./cmd/bridge/config.yaml with your setup, the file comments explain the various flags

run `./dmgcbridge` in the `cmd/dmgcbridge` directory

all-in-one (build + run) `cd cmd/dmgcbridge/;go build .;./dmgcbridge`

## Docker all-in-one

*Note: Best option for users who want access to reporting, and aren't already using Grafana/Prometheus.  Requires a local copy of this repository, and docker installation.*
  

`docker compose -f docker-compose-all-src.yml up -d --build` [^1] will run the bridge assuming a local dmgc node with default port settings, and expose port 5555 to incoming stratum connections.  These settings can be overridden by modifying/adding/deleting the parameters in the 'command' section of the [docker-compose-all-src.yml](docker-compose-all-src.yml) file.  Additionally, Prometheus (the stats database) and Grafana (the dashboard) will be started and accessible on ports 9090 and 3000 respectively.  Once all services are running, the dashboard should be reachable at <http://127.0.0.1:3000/d/x7cE7G74k1/ksb-monitoring> with default user/pass: admin/admin

[^1]: This command builds the bridge component from source, rather than the previous behavior of pulling down a pre-built image.  You may still use the pre-built image by replacing 'docker-compose-all-src.yml' with 'docker-compose-all.yml', but it is not guaranteed to be up to date, so compiling from source is the better alternative.

Many of the stats on the graph are averaged over a configurable time period (24hr default - use the 'resolution' dropdown to change this), so keep in mind that the metrics might be incomplete during this initial period.


## Docker bridge only

*Note: Best option for users who want docker encapsulation, and don't need reporting, or are already using Grafana/Prometheus.  Requires a local copy of this repository, and docker installation.*

`docker compose -f docker-compose-bridge-src.yml up -d --build` [^2] will run the bridge assuming a local dmgc node with default port settings, and expose port 5555 to incoming stratum connections.  These settings can be overridden by modifying/adding/deleting the parameters in the 'command' section of the [docker-compose-bridge-src.yml](docker-compose-bridge-src.yml) file.  No further services will be enabled.

[^2]: This command builds the bridge component from source, rather than the previous behavior of pulling down a pre-built image.  You may still use the pre-built image by issuing the command `docker run -p 5555:5555 dmgcoin/dmgc_bridge:latest`, but it is not guaranteed to be up to date, so compiling from source is the better alternative.


# Configuration

## Native

Configuration for the bridge running as a native service/executable is done via the [config.yaml](cmd/dmgcbridge/config.yaml) file in the same directory as the executable (`./cmd/dmgcbridge` from the project root if building from source.)  Available parameters are as follows (note that some parameters are commented out - please uncomment to modify):


```
# stratum_listen_port: the port that will be listening for incoming stratum 
# traffic
# Note `:PORT` format is needed if not specifiying a specific ip range 
stratum_port: :5555

# dmgc_address: address/port of the rpc server for dmgc, typically 16110
# For a list of public nodes, run `nslookup mainnet-dnsseed.daglabs-dev.com` 
# uncomment for to use a public node
# dmgc_address: 46.17.104.200:16110
dmgc_address: localhost:16110

# min_share_diff: only accept shares of the specified difficulty (or higher) 
# from the miner(s).  Higher values will reduce the number of shares submitted, 
# thereby reducing network traffic and server load, while lower values will 
# increase the number of shares submitted, thereby reducing the amount of time 
# needed for accurate hashrate measurements
# min_share_diff: 4

# block_wait_time: time to wait since last new block message from dmgc before
# manually requesting a new block
# block_wait_time: 500ms

# extranonce_size: size in bytes of extranonce, from 0 (no extranonce) to 3. 
# With no extranonce (0), all clients will search through the same nonce-space,
# therefore performing duplicate work unless the miner(s) implement client
# side nonce randomizing.  More bytes allow for more clients with unique 
# nonce-spaces (i.e. no overlapping work), but reduces the per client 
# overall nonce-space (though with 1s block times, this shouldn't really
# be a concern). 
# 1 byte = 256 clients, 2 bytes = 65536, 3 bytes = 16777216.
# extranonce_size: 0

# print_stats: if true will print stats to the console, false just workers
# joining/disconnecting, blocks found, and errors will be printed
print_stats: true

# log_to_file: if true logs will be written to a file local to the executable
log_to_file: true

# prom_port: if specified, prometheus will serve stats on the port provided
# see readme for summary on how to get prom up and running using docker
# you can get the raw metrics (along with default golang metrics) using
# `curl http://localhost:{prom_port}/metrics`
# Note `:PORT` format is needed if not specifiying a specific ip range 
prom_port: :2114

```

## Docker

Configuration for the bridge running in a docker container is done via command line arguments, which are listed one per line in the 'command' section under the 'ks_bridge' section of the relevant docker compose file ([docker-compose-all-src.yml](docker-compose-all-src.yml) if running all services, or [docker-compose-bridge-src.yml](docker-compose-bridge-src.yml) if running the bridge only).  Parameters are the same as above, although naming is different (sorry).  

Default settings are as follows:

```
command:
  - '-log=true' # enable/disable logging
  - '-stats=false' # include stats readout every 10s in log
  - '-stratum=:5555' # port to which miners should connect
  - '-prom=:2114' # port at which raw prometheus stats will be available
  - '-dmgc=host.docker.internal:16110' # host/port at which dmgc node is running
```

with the following additional options available (shown with implicit defaults):

```
  - '-diff=4' # minimum share difficulty to accept from miner(s)
  - '-extranonce=0' # size in bytes of extranonce
  - '-blockwait=500ms' # time in to wait before manually requesting new block
  - '-hcp=' # port at which healthcheck is exposed (at path '/readyz')
```

## IceRiver ASICs configuration details

IceRiver ASICs require a 2 byte extranonce, as well as an increased minimum share difficulty.  Without these settings, you may experience lower than expected hashrates.  Recommended minimum difficulty settings for each of the different devices are as follows (should produce roughly 20 shares/min):

|ASIC | Min Diff |
| --- | ---- |
|KS0  | 65   |
|KS1  | 650  |
|KS2  | 1300 |
|KS3L | 3250 |
|KS3  | 5200 |

See previous sections for details on setting these parameters for your particular installation.