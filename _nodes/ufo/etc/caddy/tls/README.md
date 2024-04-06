To extract credentials from an existing `cert-manager` secret:

```
export secret=foobar-tls
kubectl get secret $secret -o json | tee \
  >(jq -r '.data."tls.crt"' | base64 -d > $secret.crt) \
  >(jq -r '.data."tls.key"' | base64 -d > $secret.key) \
  >/dev/null
```
