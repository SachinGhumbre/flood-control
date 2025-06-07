-- Define the plugin configuration schema
local typedefs = require "kong.db.schema.typedefs"
return {
    name = "flood-control",
    fields = {
        {protocols = typedefs.protocols_http},
        {
            config = {
                type = "record",
                fields = {
                    -- Required rate field (requests per second, or minute)
                    {
                        rate = {
                            type = "integer",
                            description = "The number HTTP requests that can be made per time unit.",
                            required = true,
                            gt = 0
                        }
                    },
					
                    -- Unit of rate (second, or minute)
                    {
                        unit = {
                            type = "string",
                            description = "The time unit for which the number of HTTP requests can be made",
                            required = true,
                            one_of = {"second", "minute"}
                        }
                    },
                    -- Identifier type (ip, consumer)
                    {
                        identifier_type = {
                            type = "string",
                            description = "Identifier whose HTTP requests can be throttled.",
                            required = true,
                            one_of = {"ip", "consumer"},
                            default = "ip"
                        }
                    },
                    {
                        error_code = {
                            description = "Set a custom error code to return when the rate limit is exceeded.",
                            type = "number",
                            default = 429,
                            gt = 0
                        }
                    },
                    {
                        error_message = {
                            description = "Set a custom error message to return when the rate limit is exceeded.",
                            type = "string",
                            default = "Flood Control Policy Voilation: Allowed rate exceeded."
                        }
                    }
                }
            }
        }
    }
}
