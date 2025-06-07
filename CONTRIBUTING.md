# Contributing to kong flood-control plugin

Thank you for considering contributing to this project!

## Overview

`flood-control` is a Kong custom plugin that provides real-time traffic smoothing (similar to Apigee Spike Arrest or Mulesoft Spike Control). It protects APIs against sudden traffic bursts using Lua.

---

## Running Kong Locally with This Plugin

To test the plugin locally, follow these steps:

**Clone your fork**:
   ```bash
   git clone https://github.com/SachinGhumbre/flood-control.git
   cd flood-control
  ```


**Setup Kong**:


Install Kong OSS or Enterprise. Below is an example of Docker with the plugin mounted
For detailed steps on how to install Kong Gateway, refer official documentation (Kong Gateway Setup) [https://docs.konghq.com/gateway/latest/]


Create a `docker-compose.yml` with plugin volume mounted:


   ```yaml
   version: "3"
   services:
     kong:
       image: kong:3.10
       container_name: kong
       environment:
         KONG_DATABASE: "off"
         KONG_DECLARATIVE_CONFIG: /kong/declarative/kong.yml
         KONG_PLUGINS: bundled,flood-control
         KONG_LOG_LEVEL: debug
       ports:
         - "8000:8000"
         - "8001:8001"
         - "8002:8002"
       volumes:
         - ./kong-plugin:/usr/local/share/lua/5.1/kong/plugins/flood-control
         - ./examples/kong.yml:/kong/declarative/kong.yml
   ```

**Allocate shared memory**:

Go to kong container bash and update shared memory allocation. 

This enables to store Identifier and the time when last API call was made by this identifier

   ```bash
	vi /usr/local/share/lua/5.1/kong/templates/nginx_kong.lua
	## add below line near similar lines
	lua_shared_dict flood_control 10m;
   ```
   
**Start Kong**:

   ```bash
   docker-compose up
   ```

**Send test traffic**:

Refer README.md file.

---

## Development Guidelines

* Use clean, idiomatic Lua code
* Stick to the structure of existing Kong plugins
* Comment your logic where it's not obvious
* Respect the plugin schema conventions
* Follow semantic commit messages

---

## Testing the Plugin

Automated tests are not yet in place (contributions welcome!), but you can manually test using:

* Example Kong configuration in `examples/kong.yml`
* Docker setup described above
* Logs (`docker logs kong`) for plugin behavior

Refer README.md for complete testing of plugin.

---

## Submitting a Pull Request

We welcome contributions in the form of bug fixes, enhancements, or documentation improvements.

1. Fork the repo
2. Create a feature branch:

   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes
4. Commit with a clear message:

   ```bash
   git commit -m "Add: new option to control flood interval"
   ```
5. Push your branch:

   ```bash
   git push origin feature/your-feature-name
   ```
6. Open a **Pull Request** to `main` branch

Please ensure your code is well-tested and follows the plugin's purpose of *real-time traffic smoothing*.

---

## License

By contributing to this project, you agree that your code will be licensed under the [Apache License 2.0](LICENSE).

---

## Need Help?

Open a [GitHub Discussion](https://github.com/SachinGhumbre/flood-control/discussions) or create a [New Issue](https://github.com/SachinGhumbre/flood-control/issues/new) if you're stuck or have an idea ??.

We look forward to your contributions!
