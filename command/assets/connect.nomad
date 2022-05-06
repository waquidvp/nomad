# There can only be a single job definition per file. This job is named
# "countdash" so it will create a job with the ID and Name "countdash".

# The "job" stanza is the top-most configuration option in the job
# specification. A job is a declarative specification of tasks that Nomad
# should run. Jobs have a globally unique name, one or many task groups, which
# are themselves collections of one or many tasks.
#
# For more information and examples on the "job" stanza, please see
# the online documentation at:
#
#     https://www.nomadproject.io/docs/job-specification/job.html
#
job "countdash" {
  # The "region" parameter specifies the region in which to execute the job. If
  # omitted, this inherits the default region name of "global".
  # region = "global"
  #
  # The "datacenters" parameter specifies the list of datacenters which should
  # be considered when placing this task. This must be provided.
  datacenters = ["dc1"]

  # The "type" parameter controls the type of job, which impacts the scheduler's
  # decision on placement. This configuration is optional and defaults to
  # "service". For a full list of job types and their differences, please see
  # the online documentation.
  #
  # For more information, please see the online documentation at:
  #
  #     https://www.nomadproject.io/docs/jobspec/schedulers.html
  #
  type = "service"

  # The "constraint" stanza defines additional constraints for placing this job,
  # in addition to any resource or driver constraints. This stanza may be placed
  # at the "job", "group", or "task" level, and supports variable interpolation.
  #
  # For more information and examples on the "constraint" stanza, please see
  # the online documentation at:
  #
  #     https://www.nomadproject.io/docs/job-specification/constraint.html
  #
  # constraint {
  #   attribute = "${attr.kernel.name}"
  #   value     = "linux"
  # }

  # The "update" stanza specifies the update strategy of task groups. The update
  # strategy is used to control things like rolling upgrades, canaries, and
  # blue/green deployments. If omitted, no update strategy is enforced. The
  # "update" stanza may be placed at the job or task group. When placed at the
  # job, it applies to all groups within the job. When placed at both the job and
  # group level, the stanzas are merged with the group's taking precedence.
  #
  # For more information and examples on the "update" stanza, please see
  # the online documentation at:
  #
  #     https://www.nomadproject.io/docs/job-specification/update.html
  #
  update {
    # The "max_parallel" parameter specifies the maximum number of updates to
    # perform in parallel. In this case, this specifies to update a single task
    # at a time.
    max_parallel = 1

    # The "min_healthy_time" parameter specifies the minimum time the allocation
    # must be in the healthy state before it is marked as healthy and unblocks
    # further allocations from being updated.
    min_healthy_time = "10s"

    # The "healthy_deadline" parameter specifies the deadline in which the
    # allocation must be marked as healthy after which the allocation is
    # automatically transitioned to unhealthy. Transitioning to unhealthy will
    # fail the deployment and potentially roll back the job if "auto_revert" is
    # set to true.
    healthy_deadline = "3m"

    # The "progress_deadline" parameter specifies the deadline in which an
    # allocation must be marked as healthy. The deadline begins when the first
    # allocation for the deployment is created and is reset whenever an allocation
    # as part of the deployment transitions to a healthy state. If no allocation
    # transitions to the healthy state before the progress deadline, the
    # deployment is marked as failed.
    progress_deadline = "10m"

    # The "auto_revert" parameter specifies if the job should auto-revert to the
    # last stable job on deployment failure. A job is marked as stable if all the
    # allocations as part of its deployment were marked healthy.
    auto_revert = false

    # The "canary" parameter specifies that changes to the job that would result
    # in destructive updates should create the specified number of canaries
    # without stopping any previous allocations. Once the operator determines the
    # canaries are healthy, they can be promoted which unblocks a rolling update
    # of the remaining allocations at a rate of "max_parallel".
    #
    # Further, setting "canary" equal to the count of the task group allows
    # blue/green deployments. When the job is updated, a full set of the new
    # version is deployed and upon promotion the old version is stopped.
    canary = 0
  }
  # The migrate stanza specifies the group's strategy for migrating off of
  # draining nodes. If omitted, a default migration strategy is applied.
  #
  # For more information on the "migrate" stanza, please see
  # the online documentation at:
  #
  #     https://www.nomadproject.io/docs/job-specification/migrate.html
  #
  migrate {
    # Specifies the number of task groups that can be migrated at the same
    # time. This number must be less than the total count for the group as
    # (count - max_parallel) will be left running during migrations.
    max_parallel = 1

    # Specifies the mechanism in which allocations health is determined. The
    # potential values are "checks" or "task_states".
    health_check = "checks"

    # Specifies the minimum time the allocation must be in the healthy state
    # before it is marked as healthy and unblocks further allocations from being
    # migrated. This is specified using a label suffix like "30s" or "15m".
    min_healthy_time = "10s"

    # Specifies the deadline in which the allocation must be marked as healthy
    # after which the allocation is automatically transitioned to unhealthy. This
    # is specified using a label suffix like "2m" or "1h".
    healthy_deadline = "5m"
  }
  # The "group" stanza defines a series of tasks that should be co-located on
  # the same Nomad client. Any task within a group will be placed on the same
  # client.
  #
  # For more information and examples on the "group" stanza, please see
  # the online documentation at:
  #
  #     https://www.nomadproject.io/docs/job-specification/group.html
  #
  group "api" {
    # The "count" parameter specifies the number of the task groups that should
    # be running under this group. This value must be non-negative and defaults
    # to 1.
    count = 1

    # The "restart" stanza configures a group's behavior on task failure. If
    # left unspecified, a default restart policy is used based on the job type.
    #
    # For more information and examples on the "restart" stanza, please see
    # the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/restart.html
    #
    restart {
      # The number of attempts to run the job within the specified interval.
      attempts = 2
      interval = "30m"

      # The "delay" parameter specifies the duration to wait before restarting
      # a task after it has failed.
      delay = "15s"

      # The "mode" parameter controls what happens when a task has restarted
      # "attempts" times within the interval. "delay" mode delays the next
      # restart until the next interval. "fail" mode does not restart the task
      # if "attempts" has been hit within the interval.
      mode = "fail"
    }

    # The "ephemeral_disk" stanza instructs Nomad to utilize an ephemeral disk
    # instead of a hard disk requirement. Clients using this stanza should
    # not specify disk requirements in the resources stanza of the task. All
    # tasks in this group will share the same ephemeral disk.
    #
    # For more information and examples on the "ephemeral_disk" stanza, please
    # see the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/ephemeral_disk.html
    #
    ephemeral_disk {
      # When sticky is true and the task group is updated, the scheduler
      # will prefer to place the updated allocation on the same node and
      # will migrate the data. This is useful for tasks that store data
      # that should persist across allocation updates.
      # sticky = true
      #
      # Setting migrate to true results in the allocation directory of a
      # sticky allocation directory to be migrated.
      # migrate = true
      #
      # The "size" parameter specifies the size in MB of shared ephemeral disk
      # between tasks in the group.
      size = 300
    }

    # The "affinity" stanza enables operators to express placement preferences
    # based on node attributes or metadata.
    #
    # For more information and examples on the "affinity" stanza, please
    # see the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/affinity.html
    #
    # affinity {
    #   # attribute specifies the name of a node attribute or metadata
    #   attribute = "${node.datacenter}"
    #
    #   # value specifies the desired attribute value. In this example Nomad
    #   # will prefer placement in the "us-west1" datacenter.
    #   value = "us-west1"
    #
    #   # weight can be used to indicate relative preference
    #   # when the job has more than one affinity. It defaults to 50 if not set.
    #   weight = 100
    # }


    # The "spread" stanza allows operators to increase the failure tolerance of
    # their applications by specifying a node attribute that allocations
    # should be spread over.
    #
    # For more information and examples on the "spread" stanza, please
    # see the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/spread.html
    #
    # spread {
    #   # attribute specifies the name of a node attribute or metadata
    #   attribute = "${node.datacenter}"
    # }

    # targets can be used to define desired percentages of allocations
    # for each targeted attribute value.
    #
    #   target "us-east1" {
    #     percent = 60
    #   }
    #   target "us-west1" {
    #     percent = 40
    #   }
    #  }

    # The "network" stanza for a group creates a network namespace shared
    # by all tasks within the group.
    network {
      # "mode" is the CNI plugin used to configure the network namespace.
      # see the documentation for CNI plugins at:
      #
      #     https://github.com/containernetworking/plugins
      #
      mode = "bridge"

      # The service we define for this group is accessible only via
      # Consul Connect, so we do not define ports in its network.
      # port "http" {
      #   to = "8080"
      # }

      # The "dns" stanza allows operators to override the DNS configuration
      # inherited by the host client.
      # dns {
      #   servers = ["1.1.1.1"]
      # }
    }
    # The "service" stanza enables Consul Connect.
    service {
      name = "count-api"

      # The port in the service stanza is the port the service listens on.
      # The Envoy proxy will automatically route traffic to that port
      # inside the network namespace. If the application binds to localhost
      # on this port, the task needs no additional network configuration.
      port = "9001"

      # The "check" stanza specifies a health check associated with the service.
      # This can be specified multiple times to define multiple checks for the
      # service. Note that checks run inside the task indicated by the "task"
      # field.
      #
      # check {
      #   name     = "alive"
      #   type     = "tcp"
      #   task     = "api"
      #   interval = "10s"
      #   timeout  = "2s"
      # }

      connect {
        # The "sidecar_service" stanza configures the Envoy sidecar admission
        # controller. For each task group with a sidecar_service, Nomad  will
        # inject an Envoy task into the task group. A group network will be
        # required and a dynamic port will be registered for remote services
        # to connect to Envoy with the name `connect-proxy-<service>`.
        #
        # By default, Envoy will be run via its official upstream Docker image.
        sidecar_service {}
      }
    }
    # The "task" stanza creates an individual unit of work, such as a Docker
    # container, web application, or batch processing.
    #
    # For more information and examples on the "task" stanza, please see
    # the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/task.html
    #
    task "web" {
      # The "driver" parameter specifies the task driver that should be used to
      # run the task.
      driver = "docker"

      # The "config" stanza specifies the driver configuration, which is passed
      # directly to the driver to start the task. The details of configurations
      # are specific to each driver, so please see specific driver
      # documentation for more information.
      config {
        image = "hashicorp/counter-api:v3"

        # The "auth_soft_fail" configuration instructs Nomad to try public
        # repositories if the task fails to authenticate when pulling images
        # and the Docker driver has an "auth" configuration block.
        auth_soft_fail = true
      }

      # The "artifact" stanza instructs Nomad to download an artifact from a
      # remote source prior to starting the task. This provides a convenient
      # mechanism for downloading configuration files or data needed to run the
      # task. It is possible to specify the "artifact" stanza multiple times to
      # download multiple artifacts.
      #
      # For more information and examples on the "artifact" stanza, please see
      # the online documentation at:
      #
      #     https://www.nomadproject.io/docs/job-specification/artifact.html
      #
      # artifact {
      #   source = "http://foo.com/artifact.tar.gz"
      #   options {
      #     checksum = "md5:c4aa853ad2215426eb7d70a21922e794"
      #   }
      # }


      # The "logs" stanza instructs the Nomad client on how many log files and
      # the maximum size of those logs files to retain. Logging is enabled by
      # default, but the "logs" stanza allows for finer-grained control over
      # the log rotation and storage configuration.
      #
      # For more information and examples on the "logs" stanza, please see
      # the online documentation at:
      #
      #     https://www.nomadproject.io/docs/job-specification/logs.html
      #
      # logs {
      #   max_files     = 10
      #   max_file_size = 15
      # }

      # The "resources" stanza describes the requirements a task needs to
      # execute. Resource requirements include memory, network, cpu, and more.
      # This ensures the task will execute on a machine that contains enough
      # resource capacity.
      #
      # For more information and examples on the "resources" stanza, please see
      # the online documentation at:
      #
      #     https://www.nomadproject.io/docs/job-specification/resources.html
      #
      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }
    }

    # The Envoy sidecar admission controller will inject an Envoy task into
    # any task group for each service with a sidecar_service stanza it contains.
    # A group network will be required and a dynamic port will be registered for
    # remote services to connect to Envoy with the name `connect-proxy-<service>`.
    # By default, Envoy will be run via its official upstream Docker image.
    #
    # There are two ways to modify the default behavior:
    #   * Tasks can define a `sidecar_task` stanza in the `connect` stanza
    #     that merges into the default sidecar configuration.
    #   * Add the `kind = "connect-proxy:<service>"` field to another task.
    #     That task will be replace the default Envoy proxy task entirely.
    #
    # task "connect-<service>" {
    #   kind   = "connect-proxy:<service>"
    #   driver = "docker"

    #   config {
    #     image = "${meta.connect.sidecar_image}"
    #     args  = [
    #      "-c", "${NOMAD_TASK_DIR}/bootstrap.json",
    #      "-l", "${meta.connect.log_level}"
    #     ]
    #   }

    #   resources {
    #     cpu    = 100
    #     memory = 300
    #   }

    #   logs {
    #     max_files     = 2
    #     max_file_size = 2
    #   }
    # }
  }
  # This job has a second "group" stanza to define tasks that might be placed
  # on a separate Nomad client from the group above.
  #
  group "dashboard" {
    network {
      mode = "bridge"

      # The `static = 9002` parameter requests the Nomad scheduler reserve
      # port 9002 on a host network interface. The `to = 9002` parameter
      # forwards that host port to port 9002 inside the network namespace.
      port "http" {
        static = 9002
        to     = 9002
      }
    }

    service {
      name = "count-dashboard"
      port = "9002"

      connect {
        sidecar_service {
          proxy {
            # The upstreams stanza defines the remote service to access
            # (count-api) and what port to expose that service on inside
            # the network namespace. This allows this task to reach the
            # upstream at localhost:8080.
            upstreams {
              destination_name = "count-api"
              local_bind_port  = 8080
            }
          }
        }

        # The `sidecar_task` stanza modifies the default configuration
        # of the Envoy proxy task.
        # sidecar_task {
        #   resources {
        #     cpu    = 1000
        #     memory = 512
        #   }
        # }
      }
    }

    task "dashboard" {
      driver = "docker"

      # The application can take advantage of automatically created
      # environment variables to find the address of its upstream
      # service.
      env {
        COUNTING_SERVICE_URL = "http://${NOMAD_UPSTREAM_ADDR_count_api}"
      }

      config {
        image          = "hashicorp/counter-dashboard:v3"
        auth_soft_fail = true
      }
    }
  }
}
