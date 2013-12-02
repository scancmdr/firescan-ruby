var search_data = {"index":{"searchIndex":["example","firebind","client","portspec","scan","scanerror","scanstate","simpleprotocol","tcptransport","transport","udptransport","tools","arguments_valid?()","big_endian()","close()","closed_ports()","connect()","connect()","debug()","description()","do_output()","do_scan_output()","echo()","new()","new()","new()","new()","new()","new()","new()","new()","new()","on_error()","on_port_complete()","on_port_start()","on_port_tick()","on_scan_complete()","on_scan_start()","on_scan_stop()","on_start_failure()","open_ports()","out()","output_options()","parsed_options?()","percent_complete()","port_delay_seconds()","port_duration()","receive()","receive()","run()","scan()","send()","send()","size()","stop()","to_s()","to_s()","to_s()","update()","update()","verbose()","license","usage","version","created.rid"],"longSearchIndex":["example","firebind","firebind::client","firebind::portspec","firebind::scan","firebind::scanerror","firebind::scanstate","firebind::simpleprotocol","firebind::tcptransport","firebind::transport","firebind::udptransport","tools","firebind::client#arguments_valid?()","tools#big_endian()","firebind::transport#close()","firebind::scanstate#closed_ports()","firebind::tcptransport#connect()","firebind::udptransport#connect()","tools#debug()","firebind::scanstate#description()","firebind::client#do_output()","firebind::client#do_scan_output()","firebind::simpleprotocol#echo()","firebind::client::new()","firebind::portspec::new()","firebind::scan::new()","firebind::scanerror::new()","firebind::scanstate::new()","firebind::simpleprotocol::new()","firebind::tcptransport::new()","firebind::transport::new()","firebind::udptransport::new()","firebind::scanstate#on_error()","firebind::scanstate#on_port_complete()","firebind::scanstate#on_port_start()","firebind::scanstate#on_port_tick()","firebind::scanstate#on_scan_complete()","firebind::scanstate#on_scan_start()","firebind::scanstate#on_scan_stop()","firebind::scanstate#on_start_failure()","firebind::scanstate#open_ports()","tools#out()","firebind::client#output_options()","firebind::client#parsed_options?()","firebind::scanstate#percent_complete()","firebind::scanstate#port_delay_seconds()","firebind::scanstate#port_duration()","firebind::tcptransport#receive()","firebind::udptransport#receive()","firebind::client#run()","firebind::scan#scan()","firebind::tcptransport#send()","firebind::udptransport#send()","firebind::portspec#size()","firebind::scan#stop()","firebind::portspec#to_s()","firebind::scanerror#to_s()","firebind::scanstate#to_s()","example#update()","firebind::client#update()","tools#verbose()","","","",""],"info":[["Example","","Example.html","",""],["Firebind","","Firebind.html","","<p>Firebind – Path Scan Client Software Copyright (C) 2013 Firebind Inc. All\nrights reserved. Authors - …\n"],["Firebind::Client","","Firebind/Client.html","","<p>Firescan command line Ruby client for path scanning to a Firebind server\n"],["Firebind::Portspec","","Firebind/Portspec.html","","<p>This data structure encapsulates the properties and operations of a port\nlist. Arbitrary lists of comma …\n"],["Firebind::Scan","","Firebind/Scan.html","","<p>This is the primary API object for performing scans. Simply supply the\nnecessary arguments to create …\n"],["Firebind::ScanError","","Firebind/ScanError.html","",""],["Firebind::ScanState","","Firebind/ScanState.html","","\n<pre>Scan lifecycle states\n SCAN_SETUP\n SCAN_START\n PORT_START\n PORT_TICK\n PORT_COMPLETE\n  ...\n SCAN_STOP ...</pre>\n"],["Firebind::SimpleProtocol","","Firebind/SimpleProtocol.html","","<p>Simplest of all echo protocols. This simply sends and receives an 8-byte\npayload representing the ID …\n"],["Firebind::TcpTransport","","Firebind/TcpTransport.html","","<p>Send and receive echo using TCP transport.\n"],["Firebind::Transport","","Firebind/Transport.html","",""],["Firebind::UdpTransport","","Firebind/UdpTransport.html","","<p>Send and receive echo using UDP transport.\n"],["Tools","","Tools.html","","<p>Utility module for translating socket and result codes.\n"],["arguments_valid?","Firebind::Client","Firebind/Client.html#method-i-arguments_valid-3F","()","<p>True if required arguments were provided\n"],["big_endian","Tools","Tools.html#method-i-big_endian","(a_number)",""],["close","Firebind::Transport","Firebind/Transport.html#method-i-close","()",""],["closed_ports","Firebind::ScanState","Firebind/ScanState.html#method-i-closed_ports","()","<p>return a Portspec of the closed ports for this scan\n"],["connect","Firebind::TcpTransport","Firebind/TcpTransport.html#method-i-connect","(port)","<p>establish connection to echo server on port\n"],["connect","Firebind::UdpTransport","Firebind/UdpTransport.html#method-i-connect","(port)",""],["debug","Tools","Tools.html#method-i-debug","(msg)",""],["description","Firebind::ScanState","Firebind/ScanState.html#method-i-description","(port_result_code)",""],["do_output","Firebind::Client","Firebind/Client.html#method-i-do_output","()",""],["do_scan_output","Firebind::Client","Firebind/Client.html#method-i-do_scan_output","(state)","<p>command line output formatting helpers\n"],["echo","Firebind::SimpleProtocol","Firebind/SimpleProtocol.html#method-i-echo","(port)",""],["new","Firebind::Client","Firebind/Client.html#method-c-new","(arguments)",""],["new","Firebind::Portspec","Firebind/Portspec.html#method-c-new","(port_list)","<p>Supply either a string or int array examples: 1,2,3,55,10-20 or\n[56,34,443,25,6000]\n"],["new","Firebind::Scan","Firebind/Scan.html#method-c-new","(command_server, ports, transport, timeout=5000, protocol=:SimpleProtocol, username=NIL, password=NIL)","<p>Create a new Scan\n"],["new","Firebind::ScanError","Firebind/ScanError.html#method-c-new","(status_code, error=nil)",""],["new","Firebind::ScanState","Firebind/ScanState.html#method-c-new","(command_server,protocol,transport,portspec,timeout)","<p>@param [Firebind::Portspec] portspec\n"],["new","Firebind::SimpleProtocol","Firebind/SimpleProtocol.html#method-c-new","(guid,echo_host,transport,timeout,state=NIL)","<p>@param [Object] transport\n"],["new","Firebind::TcpTransport","Firebind/TcpTransport.html#method-c-new","(echo_server,timeout)",""],["new","Firebind::Transport","Firebind/Transport.html#method-c-new","(echo_server, timeout)",""],["new","Firebind::UdpTransport","Firebind/UdpTransport.html#method-c-new","(echo_server,timeout)",""],["on_error","Firebind::ScanState","Firebind/ScanState.html#method-i-on_error","(status_code)",""],["on_port_complete","Firebind::ScanState","Firebind/ScanState.html#method-i-on_port_complete","(port,port_result_code)","<p>@param [Object] port\n"],["on_port_start","Firebind::ScanState","Firebind/ScanState.html#method-i-on_port_start","(port)",""],["on_port_tick","Firebind::ScanState","Firebind/ScanState.html#method-i-on_port_tick","()",""],["on_scan_complete","Firebind::ScanState","Firebind/ScanState.html#method-i-on_scan_complete","(status_code)",""],["on_scan_start","Firebind::ScanState","Firebind/ScanState.html#method-i-on_scan_start","(guid,echo_server,port_delay)","<p>lifecycle methods\n"],["on_scan_stop","Firebind::ScanState","Firebind/ScanState.html#method-i-on_scan_stop","()",""],["on_start_failure","Firebind::ScanState","Firebind/ScanState.html#method-i-on_start_failure","(status_code)",""],["open_ports","Firebind::ScanState","Firebind/ScanState.html#method-i-open_ports","()","<p>return a Portspec of the open ports for this scan\n"],["out","Tools","Tools.html#method-i-out","(msg)",""],["output_options","Firebind::Client","Firebind/Client.html#method-i-output_options","()",""],["parsed_options?","Firebind::Client","Firebind/Client.html#method-i-parsed_options-3F","()","<p>figure what arguments we have to work with\n"],["percent_complete","Firebind::ScanState","Firebind/ScanState.html#method-i-percent_complete","()",""],["port_delay_seconds","Firebind::ScanState","Firebind/ScanState.html#method-i-port_delay_seconds","()",""],["port_duration","Firebind::ScanState","Firebind/ScanState.html#method-i-port_duration","()","<p>data methods\n"],["receive","Firebind::TcpTransport","Firebind/TcpTransport.html#method-i-receive","()","<p>Receive echo response from server.\n<p>PAYLOAD_REFUSED_ON_RECV PAYLOAD_ERROR_ON_RECV PAYLOAD_TIMED_OUT_ON_RECV …\n"],["receive","Firebind::UdpTransport","Firebind/UdpTransport.html#method-i-receive","()","<p>Receive echo response from server. Partway through the timeout we’ll call\nsend() again to send more datagrams …\n"],["run","Firebind::Client","Firebind/Client.html#method-i-run","()","<p>Parse options, check arguments, then process the command\n"],["scan","Firebind::Scan","Firebind/Scan.html#method-i-scan","()","<p>Perform the path scan\n"],["send","Firebind::TcpTransport","Firebind/TcpTransport.html#method-i-send","(payload)","<p>Send data to the echo server\n<p>@param [Array payload - array of bytes\n"],["send","Firebind::UdpTransport","Firebind/UdpTransport.html#method-i-send","(payload,num_payloads = 10)","<p>Send data to the echo server, we’ll send multiple copies of the same data.\nSo long as the echo server …\n"],["size","Firebind::Portspec","Firebind/Portspec.html#method-i-size","()",""],["stop","Firebind::Scan","Firebind/Scan.html#method-i-stop","()",""],["to_s","Firebind::Portspec","Firebind/Portspec.html#method-i-to_s","()",""],["to_s","Firebind::ScanError","Firebind/ScanError.html#method-i-to_s","()",""],["to_s","Firebind::ScanState","Firebind/ScanState.html#method-i-to_s","()",""],["update","Example","Example.html#method-i-update","(state)",""],["update","Firebind::Client","Firebind/Client.html#method-i-update","(state)","<p>scan callback interface @param [Object] state\n"],["verbose","Tools","Tools.html#method-i-verbose","(msg)",""],["LICENSE","","LICENSE_txt.html","","\n<pre>         Apache License\n   Version 2.0, January 2004\nhttp://www.apache.org/licenses/</pre>\n<p>TERMS AND CONDITIONS …\n"],["USAGE","","USAGE_txt.html","","<p>Synopsis\n\n<pre>This is the Ruby reference implementation for the Firebind Firescan\npath scanner client.</pre>\n<p>Examples …\n"],["VERSION","","VERSION_txt.html","","<p>Firescan Versioning\n"],["created.rid","","doc/created_rid.html","",""]]}}