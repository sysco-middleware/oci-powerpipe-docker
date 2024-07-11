# oci-powerpipe-docker
This setup enables system admins to run powerpipe and steampipe components using compose files (docker-compose/podman-compose).
The end goal is to 
- generate oci-compliance reports periodically.
- work on the issues highlighted in the report
- use [oci-powerpipe-import](https://github.com/sysco-middleware/oci-powerpipe-import) to import compliance report to powerpipe
- use [oci-powerpipe-diff-mod](https://github.com/sysco-middleware/oci-powerpipe-diff-mod) to compare compliance reports

##  1. oci-powerpipe-docker setup instructions
The entrypoint for this setup is the compose.yaml file. It defines 2 services 
- `steampipe` : 
  - runs the postgres and steampipe server. 
  - provides cli to install various plugins.
  - volume mounts files from host to the container for easy access
- `powerpipe` :
  - run the powerpipe client that connects with steampipe
  - provides cli to install different mods
  - volume mount from host to the container to run cli commands
                        
### 1.a Steampipe setup
- Host directory [sp](sp) is mounted as working directory for steampipe
- Mount [init.sh](sp/init.sh) and [run.sh](sp/run.sh).
  - init.sh: is used to start the steampipe service.
  - run.sh: can be used to run commands at later point. For ex: installing new plugin
- *Mount the oci-private-key from the host* . We will need this to configure oci plugin
- start the steampipe container `podman-compose down steampipe && podman-compose up -d steampipe`
- wait for few seconds and check if container is running `podman-compose ps`
   ```shell
  podman-compose ps
  CONTAINER ID  IMAGE                              COMMAND     CREATED         STATUS         PORTS                   NAMES
  4af0fc616a69  docker.io/turbot/steampipe:latest              10 minutes ago  Up 10 minutes  0.0.0.0:9193->9193/tcp  steampipe
  ```
  - install oci plugin 
    - update the [run.sh](sp/run.sh) with command you want to execute. For example `steampipe plugin install oci`
    - execute [run.sh](sp/run.sh) `podman-compose exec steampipe /bin/sh /home/steampipe/run.sh`
    ```shell
    podman-compose exec steampipe /bin/sh /home/steampipe/run.sh 
    oci [====================================================================>] Done
    Installed plugin: oci@latest v0.36.0
    Documentation:    https://hub.steampipe.io/plugins/turbot/oci
    ``` 
    - validate if the plugin is installed
    ```shell
     podman-compose exec steampipe steampipe plugin list 
     +--------------------------------------------+---------+-------------+
     | Installed                                  | Version | Connections |
     +--------------------------------------------+---------+-------------+
     | hub.steampipe.io/plugins/turbot/oci@latest | 0.36.0  | oci         |
     +--------------------------------------------+---------+-------------+
    ```                 
    - This above will generate a config file for the `oci plugin` at `sp/.steampipe/config/oci.spc`. Update the file with OCI connection details like below
    ```hcl
     connection "oci" {
     plugin = "oci"
     tenancy_ocid     = "ocid1.tenancy.oc1......" # OCI tenant ID
     user_ocid        = "ocid1.user.oc1........." # OCI user ID
     fingerprint      = "24:a1:23:xxxx.........." # fingerprint
     private_key_path = "~/.ssh/steampipe.pem"    # private key path in the container(mounted in compose.yaml)
     regions          = ["ap-mumbai-1", "us-ashburn-1"]  # List of regions to query resources
    }
    ```           
### 1.b Powerpipe setup 
- run `podman-compose exec steampipe steampipe service status --show-password` which will reveal the password
- ```shell
  podman-compose exec steampipe steampipe service status --show-password
  Steampipe service is running:

  Database:

  Host(s):            127.0.0.1, ::1, 10.89.4.17
  Port:               9193
  Database:           steampipe
  User:               steampipe
  Password:           POSTGRES_DATABASE_PASSWORD
  Connection string:  postgres://steampipe:POSTGRES_DATABASE_PASSWORD@127.0.0.1:9193/steampipe
  ...

  ```      
- Copy and replace the connection string in  [pp/init.sh](pp/init.sh) and [pp/run.sh](pp/run.sh). Make sure to rename the host to `steampipe` instead of `127.0.0.1`
- Start the containers `podman-compose down powerpipe && podman-compose up -d powerpipe`
- validate the container status `podman-compose ps `
- ```shell
  podman-compose ps 
  CONTAINER ID  IMAGE                                            COMMAND     CREATED         STATUS         PORTS                   NAMES
  08828ac6a768  docker.io/turbot/steampipe:latest                            16 seconds ago  Up 16 seconds  0.0.0.0:9193->9193/tcp  steampipe
  dc0cb3c4f38b  localhost/oci-powerpipe-docker_powerpipe:latest              15 seconds ago  Up 16 seconds  0.0.0.0:9033->9033/tcp  powerpipe
  ```          
- install the oci plugin for powerpipe 
  - update **pp/run.sh** script with the mod that you want to install
  - run ` podman-compose exec powerpipe  /bin/sh /home/powerpipe/run.sh ` 
- run the oci benchmark
  - comment the previous commands in  **pp/run.sh**
  - add command to run the benchmark
  - run the benchmark `podman-compose exec powerpipe  /bin/sh /home/powerpipe/run.sh `
  - the compliance file will be available under `pp/mod/.powerpipe` directory