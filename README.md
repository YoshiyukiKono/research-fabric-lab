# research-fabric-lab

Research Fabric on Kubernetes is a GitOps-driven reference architecture for running quantum, HPC, OR, and AI-agent assisted research workloads on Kubernetes.

The first milestone is intentionally small:

1. A user describes a research intent in a UI.
2. An AI agent generates a GitHub Pull Request containing an experiment spec.
3. A human reviews and merges it.
4. Argo CD applies the workload to Kubernetes.
5. The experiment runs as a Kubernetes Job and stores results.
6. A report agent may later generate a report Pull Request.

Core principle:

> AI generates PR. Human reviews. GitOps applies.

## Repository map

```text
docs/                     Design notes and architecture documents
infra/harvester/           Harvester VM and cloud-init definitions
deploy/                    Argo CD and Kubernetes manifests
apps/                      Portal/API/agent application skeletons
contracts/                 JSON schemas for Experiment and AgentTask
experiments/               Example experiment definitions
templates/                 Reusable experiment/report templates
scripts/                   Helper scripts
.github/workflows/         CI validation examples
```

## MVP target

- Harvester hosts one lightweight Kubernetes VM for research workloads.
- Existing Rancher VM can manage the cluster.
- Argo CD watches this repository.
- External LLM API is used; no local Ollama/GPU requirement at the beginning.
- Experiment execution starts with simple Kubernetes Jobs.
