<h3>Setting Up the Mesh Network</h3>

<p>This document covers the creation of the mesh netwok once the Pi is up
and through its [02<em>first</em>boot.md)[first boot].</p>

<h4>Assumptions</h4>

<h4>Scripted Setup</h4>

<h4>Manual Instructions</h4>

<ol>
<li><p><code>iw dev wlan0 interface add mesh0 type mp</code></p></li>
<li><p><code>ifconfig mesh0 up</code></p></li>
<li><p><code>iw dev mesh0 join meshpotato</code></p></li>
</ol>
