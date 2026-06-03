# attach.bat

Attach.bat is the most straight forward,
It attempted to Use Java Agents to attach YPP-Gizmo to a live running version of YPP (either at application start, or an application that was Already existing)

It would attempt to find an Open YPP Instance via the PID  and other factors, 
And used both JPS and JCMD to create the bridge.

However future iterations by me would entirely remove the need for a bat to do the connection, as better soloutions were found to make it automatic.