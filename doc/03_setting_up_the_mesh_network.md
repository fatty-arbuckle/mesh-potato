# mesh-potato

## Setting Up the Mesh Network

This document covers the creation of the mesh netwok once the Pi is up
and through its [02_first_boot.md)[first boot].

### Assumptions

### Scripted Setup

TODO

This should be taken 

### Manual Instructions

1. `iw dev wlan0 interface add mesh0 type mp`

2. `ifconfig mesh0 up`

3. `iw dev mesh0 join meshpotato`

