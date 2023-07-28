# frozen_string_literal: true

# apiVersion: batch/v1
# kind: CronJob
# metadata:
#   name: hello
# spec:
#   schedule: "* * * * *"
#   jobTemplate:
#     spec:
#       template:
#         spec:
#           containers:
#           - name: hello
#             image: busybox:1.28
#             imagePullPolicy: IfNotPresent
#             command:
#             - /bin/sh
#             - -c
#             - date; echo Hello from the Kubernetes cluster
#           restartPolicy: OnFailure

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
                spec: {
                  restartPolicy: "OnFailure",
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
end
