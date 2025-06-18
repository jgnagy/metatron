# frozen_string_literal: true

RSpec.describe Metatron::Templates::CronJob do
  describe "for simple cron jobs" do
    let(:cron_job) do
      cron_job = described_class.new("hello")
      cron_job.containers << Metatron::Templates::Container.new("hello")
      cron_job
    end

    let(:rendered_cron_job) do
      {
        apiVersion: "batch/v1",
        kind: "CronJob",
        metadata: { labels: { "metatron.therubyist.org/name": "hello" }, name: "hello" },
        spec: {
          schedule: "* * * * *",
          jobTemplate: {
            spec: {
              template: {
                metadata: { labels: { "metatron.therubyist.org/name": "hello" } },
                spec: {
                  containers: [
                    {
                      image: "gcr.io/google_containers/pause",
                      imagePullPolicy: "IfNotPresent",
                      name: "hello",
                      stdin: true,
                      tty: true
                    }
                  ]
                }
              }
            }
          }
        }
      }
    end

    it "produces a hash" do
      expect(cron_job.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(cron_job.render).to eq(rendered_cron_job)
    end
  end

  describe "for complex cron jobs" do
    let(:cron_job) do
      cron_job = described_class.new("hello", "*/5 * * * *")
      container = Metatron::Templates::Container.new("hello")
      container.env = { LOG_LEVEL: "DEBUG", FOO: "bar" }
      container.resources = {
        limits: { cpu: "500m", memory: "512Mi" },
        requests: { cpu: "10m", memory: "64Mi" }
      }
      cron_job.containers << container
      cron_job.active_deadline_seconds = 10
      cron_job.job_active_deadline_seconds = 30
      cron_job.annotations = { "a.test/foo": "bar" }
      cron_job.additional_labels[:foo] = "bar"
      cron_job.backoff_limit = 5
      cron_job.concurrency_policy = "Forbid"
      cron_job.failed_jobs_history_limit = 7
      cron_job.namespace = "testnamespace"
      cron_job.starting_deadline_seconds = 10
      cron_job.successful_jobs_history_limit = 5
      cron_job.suspend = false
      cron_job.ttl_seconds_after_finished = 3600
      cron_job
    end

    let(:rendered_cron_job) do
      {
        apiVersion: "batch/v1",
        kind: "CronJob",
        metadata: {
          annotations: { "a.test/foo": "bar" },
          labels: { "metatron.therubyist.org/name": "hello", foo: "bar" },
          name: "hello",
          namespace: "testnamespace"
        },
        spec: {
          concurrencyPolicy: "Forbid",
          schedule: "*/5 * * * *",
          successfulJobsHistoryLimit: 5,
          failedJobsHistoryLimit: 7,
          startingDeadlineSeconds: 10,
          suspend: false,
          jobTemplate: {
            spec: {
              activeDeadlineSeconds: 30,
              backoffLimit: 5,
              ttlSecondsAfterFinished: 3600,
              template: {
                metadata: { labels: { "metatron.therubyist.org/name": "hello" } },
                spec: {
                  activeDeadlineSeconds: 10,
                  containers: [
                    {
                      image: "gcr.io/google_containers/pause",
                      imagePullPolicy: "IfNotPresent",
                      env: [
                        { name: :LOG_LEVEL, value: "DEBUG" },
                        { name: :FOO, value: "bar" }
                      ],
                      resources: {
                        limits: { cpu: "500m", memory: "512Mi" },
                        requests: { cpu: "10m", memory: "64Mi" }
                      },
                      name: "hello",
                      stdin: true,
                      tty: true
                    }
                  ]
                }
              }
            }
          }
        }
      }
    end

    it "produces a hash" do
      expect(cron_job.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(cron_job.render).to eq(rendered_cron_job)
    end
  end
end
