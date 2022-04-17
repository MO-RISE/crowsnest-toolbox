# crowsnest-toolbox
A toolbox for handling of streaming data within a crowsnest setup.

It is packaged as a docker image, available here: https://github.com/orgs/MO-RISE/packages

The image expects a "run" command inputted on startup. Using docker run, this would manifest as such:
```
docker run crowsnest-toolbox "<command>"
```

Using docker-compose it would look like this:
```
version: '3'
services:
    recorder:
        image: ghcr.io/mo-rise/crowsnest-toolbox:v0.3.0
        restart: always
        command: ["<command>"]
```
## Binaries

The following "special" binaries are included in the toolbox:
* **b64_decode**
  Processes each line of stdin and base64 decodes it
* **b64_encode**
  Processes each line of stdin and base64 encodes it
* **raw_to_brefv**
  Processes each line of stdin and puts it into a timestamped brefv envelope
* **prepend_timestamp**
  Prepend a RFC3339 timestamp of microsecond resolution to each line on stdin
* **to_csv**
  Processes a crowsnest log file into a set of "topic-specific" csv files
* **udp_listen**
  Eavesdrop onto UDP traffic and output to stdout, currently only supports multicast.


## Recipes

The following are "recipes" for "run" commands that can be used with this image.

* Injecting data from "any" source into a mqtt broker using the standard brefv format (examplified by a multicast stream). Every UDP packet gets base64-encoded and packaged into a brefv envelope and then published to the broker:
  ```
  udp_listen --encode multicast 239.192.0.2 60002 --interface=172.16.6.1 \
  | raw_to_brefv \
  | mosquitto_pub -l -t '<topic>'
  ```

* Recording brefv data from a mqtt broker
  ```
  mosquitto_sub -v -t <topic_1> -t <topic_2> | prepend_timestamp >> crowsnest.log
  ```
  Produces output as:
  ```
  <RFC3339 timestamp> <Receive topic> <Message payload>
  <RFC3339 timestamp> <Receive topic> <Message payload>
  ...
  ```

* Subscribe to a topic and extract the message payload in realtime
  ```
  mosquitto_sub -t <topic_1> | jq -r --unbuffered .message
  ```

* Convert recorded data files to topic-specific csv format
  ```
  cat *.log | to_csv --output-path <OUTPUT DIRECTORY PATH>
  ```

* Replay recorded data (assuming the format specified above)
  ```
  TODO: Requires scripting
  ```

* Concatenating (and sorting) multiple recordings
  ```
  cat first.log second.log third.log | sort -k 1 | (replay?)
  ```

### socat-specific magic

In general, this one is good: https://gist.github.com/jdimpson/6ae2f91ec133da8453b0198f9be05bd5

More specifically for multicast:
```
socat UDP4-RECV:<MULTICAST_PORT>,reuseaddr,ip-add-membership=<MULTICAST_GROUP_IP>:<INTERFACE_IP_OR_NAME> STDOUT
```
```
socat UDP4-RECVFROM:<MULTICAST_PORT>,fork,reuseaddr,ip-add-membership=<MULTICAST_GROUP_IP>:<INTERFACE_IP_OR_NAME> STDOUT
```
```
socat STDIN UDP4-DATAGRAM:<MULTICAST_GROUP_IP>:<MULTICAST_PORT>,ip-multicast-if=<INTERFACE_IP_OR_NAME>
```

