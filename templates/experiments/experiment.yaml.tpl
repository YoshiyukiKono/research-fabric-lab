apiVersion: research.fabric/v1alpha1
kind: Experiment
metadata:
  name: {{ experiment_name }}
spec:
  domain: {{ domain }}
  engine: {{ engine }}
  task: {{ task }}
  model: {}
  parameters: {}
  runtime:
    accelerator: cpu
    image: python:3.11-slim
    resources:
      requests:
        cpu: "1"
        memory: 1Gi
      limits:
        cpu: "2"
        memory: 4Gi
  output:
    report: markdown
    artifactPath: /outputs/{{ experiment_name }}
