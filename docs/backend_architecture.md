# Architecture Backend - Jarvis Mobile App

## Vue d'ensemble

L'architecture backend de Jarvis Mobile App est conçue pour être **évolutive**, **auto-hébergeable** et **100% open source**. Elle utilise Kubernetes pour l'orchestration et N8N/Flowise pour l'automatisation des workflows.

## Composants Principaux

### 1. Orchestration (Kubernetes)

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: jarvis-app
  labels:
    name: jarvis-app
```

### 2. Base de Données

- **PostgreSQL** : Données utilisateurs, conversations, paramètres
- **Redis** : Cache, sessions, queues
- **Qdrant** : Base vectorielle pour RAG (Retrieval-Augmented Generation)

### 3. Workflow Automation (N8N/Flowise)

#### Workflow Chat Texte
```json
{
  "name": "text-chat-workflow",
  "nodes": [
    {
      "id": "webhook-receiver",
      "type": "n8n-nodes-base.webhook",
      "position": [100, 100],
      "parameters": {
        "httpMethod": "POST",
        "path": "text-chat"
      }
    },
    {
      "id": "ai-processor",
      "type": "n8n-nodes-base.httpRequest",
      "position": [300, 100],
      "parameters": {
        "url": "{{$json.openai_url}}/chat/completions",
        "method": "POST",
        "headers": {
          "Authorization": "Bearer {{$env.OPENAI_API_KEY}}",
          "Content-Type": "application/json"
        },
        "body": {
          "model": "{{$json.model}}",
          "messages": [
            {
              "role": "user",
              "content": "{{$json.content}}"
            }
          ],
          "max_tokens": 2000,
          "temperature": 0.7
        }
      }
    },
    {
      "id": "rag-enhancer",
      "type": "n8n-nodes-base.httpRequest",
      "position": [500, 100],
      "parameters": {
        "url": "{{$json.qdrant_url}}/collections/{{$json.collection}}/points/search",
        "method": "POST",
        "headers": {
          "Content-Type": "application/json"
        },
        "body": {
          "vector": "{{$json.embedding}}",
          "limit": 5
        }
      }
    }
  ]
}
```

#### Workflow Chat Vocal
```json
{
  "name": "voice-chat-workflow",
  "nodes": [
    {
      "id": "audio-receiver",
      "type": "n8n-nodes-base.webhook",
      "position": [100, 100],
      "parameters": {
        "httpMethod": "POST",
        "path": "voice-chat"
      }
    },
    {
      "id": "speech-to-text",
      "type": "n8n-nodes-base.httpRequest",
      "position": [300, 100],
      "parameters": {
        "url": "{{$json.openai_url}}/audio/transcriptions",
        "method": "POST",
        "headers": {
          "Authorization": "Bearer {{$env.OPENAI_API_KEY}}"
        },
        "formData": {
          "file": "{{$json.audio_file}}",
          "model": "whisper-1"
        }
      }
    },
    {
      "id": "ai-processor",
      "type": "n8n-nodes-base.httpRequest",
      "position": [500, 100],
      "parameters": {
        "url": "{{$json.openai_url}}/chat/completions",
        "method": "POST",
        "headers": {
          "Authorization": "Bearer {{$env.OPENAI_API_KEY}}",
          "Content-Type": "application/json"
        },
        "body": {
          "model": "{{$json.model}}",
          "messages": [
            {
              "role": "user",
              "content": "{{$json.transcription}}"
            }
          ]
        }
      }
    },
    {
      "id": "text-to-speech",
      "type": "n8n-nodes-base.httpRequest",
      "position": [700, 100],
      "parameters": {
        "url": "{{$json.openai_url}}/audio/speech",
        "method": "POST",
        "headers": {
          "Authorization": "Bearer {{$env.OPENAI_API_KEY}}",
          "Content-Type": "application/json"
        },
        "body": {
          "model": "tts-1",
          "input": "{{$json.ai_response}}",
          "voice": "alloy"
        }
      }
    }
  ]
}
```

### 4. API Gateway (Nginx)

```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream n8n_backend {
        server n8n-service:5678;
    }

    upstream qdrant_backend {
        server qdrant-service:6333;
    }

    server {
        listen 80;
        server_name api.jarvis.local;

        # Rate limiting
        limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
        limit_req zone=api burst=20 nodelay;

        # CORS
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';

        # Auth middleware
        location / {
            auth_request /auth;
            proxy_pass http://n8n_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Auth endpoint
        location = /auth {
            internal;
            proxy_pass http://auth-service:3000/verify;
            proxy_pass_request_body off;
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
        }
    }
}
```

### 5. Service d'Authentification

```javascript
// auth-service.js
const express = require('express');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

const app = express();
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

app.post('/verify', async (req, res) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: 'Token manquant' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await pool.query(
      'SELECT * FROM users WHERE id = $1 AND is_active = true',
      [decoded.userId]
    );

    if (user.rows.length === 0) {
      return res.status(401).json({ error: 'Utilisateur non trouvé' });
    }

    res.status(200).json({ user: user.rows[0] });
  } catch (error) {
    res.status(401).json({ error: 'Token invalide' });
  }
});

app.listen(3000, () => {
  console.log('Auth service running on port 3000');
});
```

## Déploiement

### 1. Installation Kubernetes

```bash
# Installation k3s (Kubernetes léger)
curl -sfL https://get.k3s.io | sh -

# Vérification
kubectl get nodes
```

### 2. Configuration des Secrets

```bash
# Créer les secrets
kubectl create secret generic jarvis-secrets \
  --from-literal=openai-api-key=your-openai-key \
  --from-literal=claude-api-key=your-claude-key \
  --from-literal=jwt-secret=your-jwt-secret \
  --from-literal=database-url=postgresql://user:pass@host:5432/jarvis
```

### 3. Déploiement des Services

```bash
# Déployer l'infrastructure
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/deployments/
kubectl apply -f k8s/services/
kubectl apply -f k8s/ingress.yaml
```

### 4. Configuration SSL

```bash
# Installation cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml

# Configuration Let's Encrypt
kubectl apply -f k8s/certificate.yaml
```

## Monitoring

### Prometheus + Grafana

```yaml
# monitoring/prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'jarvis-app'
        static_configs:
          - targets: ['jarvis-app:8080']
      - job_name: 'n8n'
        static_configs:
          - targets: ['n8n-service:5678']
```

### Logs Centralisés

```yaml
# logging/fluentd-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      <parse>
        @type json
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>
    
    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch-service
      port 9200
      logstash_format true
      logstash_prefix k8s
    </match>
```

## Sécurité

### 1. Network Policies

```yaml
# security/network-policies.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: jarvis-network-policy
spec:
  podSelector:
    matchLabels:
      app: jarvis-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: TCP
      port: 53
```

### 2. RBAC

```yaml
# security/rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: jarvis-app
  name: jarvis-role
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jarvis-role-binding
  namespace: jarvis-app
subjects:
- kind: ServiceAccount
  name: jarvis-service-account
  namespace: jarvis-app
roleRef:
  kind: Role
  name: jarvis-role
  apiGroup: rbac.authorization.k8s.io
```

## Évolutivité

### Auto-scaling

```yaml
# scaling/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: jarvis-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: jarvis-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Backup et Récupération

```bash
#!/bin/bash
# scripts/backup.sh

# Backup PostgreSQL
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup Qdrant
curl -X POST "http://qdrant-service:6333/collections/backup" \
  -H "Content-Type: application/json" \
  -d '{"path": "/backup/qdrant_$(date +%Y%m%d_%H%M%S)"}'

# Upload vers S3
aws s3 cp backup_*.sql s3://jarvis-backups/
aws s3 cp /backup/qdrant_* s3://jarvis-backups/
```

## Coûts et Optimisation

### Monitoring des Coûts

```yaml
# monitoring/cost-monitoring.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-monitoring
data:
  cost-alerts.yml: |
    groups:
    - name: cost-alerts
      rules:
      - alert: HighCost
        expr: cost_per_hour > 0.50
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Coût élevé détecté"
          description: "Le coût horaire dépasse 0.50€"
```

### Optimisation des Ressources

```yaml
# optimization/resource-limits.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: jarvis-quota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
```

Cette architecture garantit une **scalabilité horizontale**, une **haute disponibilité** et une **optimisation des coûts** tout en restant **100% open source** et **auto-hébergeable**.
