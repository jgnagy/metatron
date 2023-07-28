# frozen_string_literal: true

RSpec.describe Metatron::Templates::Job do
  describe "for simple jobs" do
    let(:job) do
      job = described_class.new("hello")
      job.containers << Metatron::Templates::Container.new("hello")
      job
    end

    let(:rendered_job) do
      {
        apiVersion: "batch/v1",
        kind: "Job",
        metadata: { labels: { "metatron.therubyist.org/name": "hello" }, name: "hello" },
        spec: {
          template: {
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
    end

    it "produces a hash" do
      expect(job.render).to be_a(Hash)
    end

    it "renders properly" do
      expect(job.render).to eq(rendered_job)
    end
  end
end
