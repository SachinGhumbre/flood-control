# flood-control Kong Custom Plugin
Secure your API proxy's target backend against severe traffic spikes and denial of service attacks.

---
## Summary Of Files
| Section                           | Belongs in        | Purpose                                         |
| --------------------------------- | ----------------- | ----------------------------------------------- |
| Plugin overview                   | `README.md`       | Explains what the plugin does and how to use it |
| How to use flood-control plugin   | `README.md`       | Explains how to setup and use custom plugin     |
| How to run Kong locally           | `CONTRIBUTING.md` | Helps contributors test the plugin              |
| Development guidelines            | `CONTRIBUTING.md` | Defines coding practices and standards          |
| How to submit a PR                | `CONTRIBUTING.md` | Guides on forking, branching, and creating PRs  |


---
## What is the Flood Control Plugin?

The **Flood Control Plugin** is a custom Kong plugin designed to control sudden bursts of traffic, similar to the **Spike Arrest** policy in Apigee or **Spike Control** policy in Mulesoft. It limits the rate of incoming requests based on either the **client IP address** or the **authenticated consumer**, helping to smooth out traffic spikes and protect backend services from overload.

Unlike traditional rate limiting, which counts requests over a fixed time window, **Flood Control** focuses on **smoothing the rate of traffic flow** in real-time.

---

## What Can We Achieve Using the Flood Control Plugin?

By using this plugin, you can:

- **Protect APIs from DDoS attacks** and malicious traffic bursts.
- **Prevent backend system overload** due to sudden spikes in traffic.
- **Reduce the risk of system downtime** by smoothing out request rates.
- **Improve overall API reliability and performance** under load.

---

## How to Deploy It?

You can deploy the Flood Control plugin using one of the following methods:

### Manual Installation of Custom Plugin
1. Copy your plugin code (schema.lua and handler.lua) to the Kong node under:
   ```
   /usr/local/share/lua/5.1/kong/plugins/flood-control
   ```
   Make sure to give appropriate file permissions to the plugin directory and all files in it.

   e.g. In Unix, chmod 777 *.lua
   
3. Update the `KONG_PLUGINS` environment variable or kong.conf file:
   This enables use of flood-control plugin
   ```bash
   export KONG_PLUGINS=bundled,flood-control
   ```
4. Allocate shared memory:
   This enables to store Identifier and the time when last API call was made by this identifier
   ```bash
   vi /usr/local/share/lua/5.1/kong/templates/nginx_kong.lua
   ## add below line near similar lines
   lua_shared_dict flood_control 10m;
   ```
5. Restart Kong.
   ```bash
   kong restart -c /etc/kong/kong.conf
   ```
### Docker-Based Installation
Follow the official Kong guide to build a Docker image with your plugin:
👉 [Deploy Plugins - Kong Docs](https://docs.konghq.com/gateway/latest/plugin-development/get-started/deploy/)

### LuaRocks Packaging
Package and install your plugin using LuaRocks:
👉 [Installation and Distribution - Kong Docs](https://docs.konghq.com/gateway/latest/plugin-development/distribution/)

---

## How to Use It?

To use the plugin in sevice, route or global:

1. Enable the plugin on a **Service**, **Route** or **Global**.
2. Select the **Identifier Type**: `ip` or `consumer`.
2. Enter the **Rate**: The number of API requests that can be made per time unit (second/minute).
3. Select the **Unit**: `second` or `minute`.

Example configuration:
```bash
curl -i -X POST http://localhost:8001/services/my-service/plugins \
  --data "name=flood-control" \
  --data "config.identifier_type=ip" \
  --data "config.rate=5" \
  --data "config.interval=minute"
```

---

## How to Test It?

Here are some test scenarios:

### Test Cases

To ensure simplicity in understanding the plungi behaviour, I added below simple test cases.

| Identifier Type       | Rate Limit          | Expected Behavior                              								 |
|-----------------------|-------------------- |------------------------------------------------------------------------------|
| ip                    | 2 reqs/min          | Only 1 request every 30 seconds should be succeessful for a client IP.       |
| consumer              | 2 reqs/min          | Only 1 request every 30 seconds should be succeessful for a consumer.        |
| ip                    | 2 reqs/sec          | Only 1 request every 500 miliseconds should be succeessful for a client IP.  |
| consumer              | 2 reqs/sec          | Only 1 request every 500 miliseconds should be succeessful for a consumer.   |

Use tools like `curl`, `insomnia` or `postman` to simulate the traffic and observe plugin behavior.

---

## What’s the Difference Between Flood Control and Rate Limiting?

| Feature              | Flood Control                             | Rate Limiting                              			|
|----------------------|-------------------------------------------|--------------------------------------------------------|
| Purpose              | Smooth out traffic spikes                 | Enforce strict request quotas              			|
| Use Case             | Prevent sudden bursts (e.g., DDoS)        | Limit total requests over a time window                |
| Storage              | Shared memory (in-memory)                 | Database or shared memory                              |
| Best For             | Real-time traffic shaping                 | Usage-based billing or quota enforcement 			    |

**Use Flood Control** when you want to protect your backend from **sudden traffic spikes** or **denial-of-service attacks**.

**Avoid using Flood Control** when you need to **count and limit total number of requests** over a time window. For that, use the **Rate Limiting** or **Rate Limiting Advanced** plugin.

---

## Does It Store Count in a Database?

- **Database Storage**: ❌ No
- **Shared Memory Storage**: ✅ Yes

The plugin uses **shared memory** for fast, in-memory request tracking, ensuring low latency and high performance.

---
