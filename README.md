# crowsnest-toolbox
A toolbox for handling of streaming data within a crowsnest setup.

## Recipes

* Recording data
  ```
  mosquitto_sub -t <topic_1> -t <topic_2> -F "%U %t %v" >> crowsnest.log
  ```
  Produces output as:
  ```
  <Unix timestamp> <Receive topic> <Message payload>
  <Unix timestamp> <Receive topic> <Message payload>
  ...
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

* Bridge (one-way) textual (newline separated) multicast traffic via a MQTT broker
  
  On sender side:
  ```
  socat UDP4-RECV:<MULTICAST_PORT>,reuseaddr,ip-add-membership=<MULTICAST_GROUP_IP>:<INTERFACE_IP_OR_NAME> STDOUT | mosquitto_pub -l -t <TOPIC>
  ```

  On receiver side:
  ```
  mosquitto_sub -t <TOPIC> -N | socat STDIN UDP4-DATAGRAM:<MULTICAST_GROUP_IP>:<MULTICAST_PORT>
  ```

* Chunkify and base64 encode binary data stream to enable bridging over MQTT
  ```
  TODO: Requires scripting
  ```
  
