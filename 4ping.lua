#!/usr/bin/env lua

-- Import the nixio library for network I/O
local nixio = require('nixio')

-- Import the io library for general I/O
local io = require('io')

-- Function to find networks
function find_networks()
    -- Get network interface addresses
    local interfaces = nixio.getifaddrs()
    
    -- Initialize an empty table for networks
    local networks = {}
    
    -- Iterate over each interface
    for _, interface in pairs(interfaces) do
        -- If the interface has an address and it matches the pattern
        if interface.addr and interface.addr:match('(%d+.%d+.%d+.).*') then
            -- Assume a /24 subnet and extract the network address
            local network = interface.addr:match('(%d+.%d+.%d+.).*') .. '0/24'
            
            -- Add the network to the networks table
            networks[network] = true
        end
    end
    
    -- Return the networks table
    return networks
end

-- Function to find hosts in the networks
function find_hosts(networks)
    -- Initialize an empty table for hosts
    local hosts = {}
    
    -- Iterate over each network
    for network in pairs(networks) do
        -- Ignore the loopback network
        if network ~= '127.0.0.0/24' then
            -- Print a message indicating the network being scanned
            print('Scanning network ' .. network .. ' with nmap...')
            
            -- Open a process to run nmap on the network
            local process = io.popen('nmap -sn ' .. network, 'r')
            
            -- Iterate over each line of the nmap output
            for line in process:lines() do
                -- Print the current line of the nmap output
                print('nmap: ' .. line)
                
                -- Try to match an IP address in the current line
                local ip = string.match(line, '(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)')
                
                -- If an IP address was found
                if ip then
                    -- Print a message indicating the found host
                    print('Found host: ' .. ip)
                    
                    -- Add the host to the hosts table
                    hosts[ip] = true
                end
            end
            
            -- Close the nmap process
            process:close()
        end
    end
    
    -- Return the hosts table
    return hosts
end

-- Function to ping a host
function ping(host)
    -- Open a process to ping the host
    local process = io.popen('ping -c 1 -W 1 ' .. host)
    
    -- Read the entire output of the ping process
    local result = process:read('*all')
    
    -- Close the ping process
    process:close()

    -- Try to match the time from the ping output
    local time = result:match('time=(%d+.%d+)')
    
    -- If a time was found
    if time then
        -- Return that the host is alive and the ping time
        return true, time
    else
        -- Return that the host is not alive
        return false
    end
end

-- Call the find_networks function and store the result in networks
local networks = find_networks()

-- Call the find_hosts function with the found networks and store the result in hosts
local hosts = find_hosts(networks)

-- Iterate over each host
for host in pairs(hosts) do
    -- Ping the host and store whether it's alive and the ping time
    local alive, time = ping(host)
    
    -- If the host is alive
    if alive then
        -- Print the host's IP address and ping time
        print('Host ' .. host .. ', time: ' .. time .. ' ms')
    else
        -- Print a message indicating that the ping failed
        print('Failed to ping host ' .. host)
    end
end