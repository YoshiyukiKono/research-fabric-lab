# Network Architecture

## Overview

This lab runs on Harvester and separates the roles clearly:

```text
Mac / Browser
   |
   | HTTP / HTTPS / SSH
   v
Ubuntu Jump Host
   |
   | kubectl / git / docker build
   v
workload-k3s
   |
   +-- Agent Fabric Lab
   |     +-- Ollama
   |     +-- Researcher / Architect / Reviewer
   |     +-- Orchestrator UI
   |
   +-- Research Fabric Lab
         +-- Argo CD
         +-- MinIO
         +-- Research Portal
         +-- Experiment / AgentTask CRDs
         +-- Runtime Jobs
```

## Important IPs and hostnames

| Component | IP / Hostname | Role |
|---|---:|---|
| Rancher Manager | `10.110.1.211` / `rancher.demo.local` | Rancher UI and cluster management |
| workload-k3s | `10.110.1.212` / `k3s-server` | Kubernetes runtime cluster |
| Jump Host | `10.110.1.213` | Git, kubectl, build/deploy operations |
| MinIO API | `minio.lab.local` | S3-compatible artifact endpoint |
| MinIO Console | `console.minio.lab.local` | Browser UI |
| Research Portal | `portal.agent.lab.local` | Streamlit portal |

## External vs internal access

For browser access, ingress hostnames are used:

```text
http://portal.agent.lab.local/
http://minio.lab.local/
http://console.minio.lab.local/
```

For Pod-to-Pod access, Kubernetes Service DNS is generally preferable:

```text
http://minio.storage.svc.cluster.local:9000
```

In this lab, `minio.lab.local` was also made resolvable from inside Pods by adding it to CoreDNS `NodeHosts`.
