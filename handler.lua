-- flood-control plugin configuration code
local kong = kong
local ngx = ngx
local ngx_shared = ngx.shared

local FloodControlHandler = {}

FloodControlHandler.VERSION = "1.0.0"
FloodControlHandler.PRIORITY = 1200

-- Access phase logic
function FloodControlHandler:access(conf)
	
    -- Determine identifier based on configuration
    local identifier
    if conf.identifier_type == "ip" then
        identifier = kong.client.get_forwarded_ip()
    elseif conf.identifier_type == "consumer" then
        identifier = (kong.client.get_consumer() or kong.client.get_credential()).id
    else
        identifier = kong.client.get_forwarded_ip()
    end

    -- Calculate interval per request
    local rate = conf.rate
    local unit = conf.unit
    local interval
    if unit == "second" then
        interval = 1 / rate -- Convert to seconds
    elseif unit == "minute" then
        interval = 60 / rate -- Convert to seconds
    else
        return kong.response.exit(400, {message = "Invalid Rate Unit. Use 'second', or 'minute'."})
    end
	
    -- Use shared memory to track request timestamps
    local last_time = ngx_shared.flood_control:get(identifier) -- Get last request time for this identifier
    local now = ngx.now() -- Get current time in seconds with millisecond precision
    if last_time then
        local elapsed = now - last_time
        if elapsed < interval then
            return kong.response.exit(
                429,
                {
                    message = "Flood Control: Too many requests within the allowed rate."
                }
            )
        end
    end
	
    ngx_shared.flood_control:set(identifier, now)
end
return FloodControlHandler