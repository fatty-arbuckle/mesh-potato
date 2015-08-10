<h3>First Boot of the Pi</h3>

<h4>Assumptions</h4>

<h4>Scripted Setup</h4>

<h4>Manual Instructions</h4>

<ol>
<li><p>Insert the SD card into the Pi, connect ethernet, and apply 5V power.</p></li>
<li><p>Find the link local address of the Pi</p>

<p>a. enable your ethernet interface if needed</p>

<pre><code>[phatty@arbuckle mesh-potato]$ ip link
1: lo: &lt;LOOPBACK,UP,LOWER_UP&gt; mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: wlp2s0: &lt;BROADCAST,MULTICAST,UP,LOWER_UP&gt; mtu 1500 qdisc mq state UP mode DORMANT group default qlen 1000
    link/ether 34:02:86:60:e0:55 brd ff:ff:ff:ff:ff:ff
3: enp0s20u2: &lt;BROADCAST,MULTICAST&gt; mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 9c:eb:e8:20:49:20 brd ff:ff:ff:ff:ff:ff


[phatty@arbuckle mesh-potato]$ sudo ip link set enp0s20u2 up
</code></pre>

<p>b. Ping the link local addresses,</p>

<pre><code>[phatty@arbuckle mesh-potato]$ ping6 ff02::01%enp0s20u2
PING ff02::01%enp0s20u2(ff02::1) 56 data bytes
64 bytes from fe80::9eeb:e8ff:fe20:4920: icmp_seq=1 ttl=64 time=0.019 ms
64 bytes from fe80::ba27:ebff:feff:1f76: icmp_seq=1 ttl=64 time=1.49 ms (DUP!)
64 bytes from fe80::9eeb:e8ff:fe20:4920: icmp_seq=2 ttl=64 time=0.031 ms
64 bytes from fe80::ba27:ebff:feff:1f76: icmp_seq=2 ttl=64 time=0.704 ms (DUP!)
^C
--- ff02::01%enp0s20u2 ping statistics ---
2 packets transmitted, 2 received, +2 duplicates, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.019/0.562/1.494/0.605 ms
[phatty@arbuckle mesh-potato]$
</code></pre></li>
<li><p>SSH to the IP address found above. The default root password is 'root'.</p>

<pre><code>[phatty@arbuckle mesh-potato]$ ssh -6 root@fe80::ba27:ebff:feff:1f76%enp0s20u2
The authenticity of host 'fe80::ba27:ebff:feff:1f76%enp0s20u2 (fe80::ba27:ebff:feff:1f76%enp0s20u2)' can't be established.
ECDSA key fingerprint is SHA256:xMb2Yrr7pJ/uJRm3sbc37UkqNuIOAX7Igd8WJQ+SOtg.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'fe80::ba27:ebff:feff:1f76%enp0s20u2' (ECDSA) to the list of known hosts.
root@fe80::ba27:ebff:feff:1f76%enp0s20u2's password: 
Welcome to Arch Linux ARM


<pre><code> Website: http://archlinuxarm.org
   Forum: http://archlinuxarm.org/forum
     IRC: #archlinux-arm on irc.Freenode.net
</code></pre>

[root@alarmpi ~]#
</code></pre></li>
</ol>
