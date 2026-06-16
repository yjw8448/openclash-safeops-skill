# Safety Boundaries

Never modify `/etc/config/network`, `/etc/config/dhcp`, or `/etc/config/firewall` during normal repair. Never run network restart, reboot, firstboot, sysupgrade, or firewall flush. Candidate before write, backup before write, user approval before write.
