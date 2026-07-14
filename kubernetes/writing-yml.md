1. error: unable to decode ".\\API-Deployment.yml": json: cannot unmarshal array into Go struct field ObjectMeta.metadata.labels of type map[string]string
For `Labels`, `MatchLabels`, `annotations` the values should almost always be written as key-value maps, not lists.
```yml
# Correct:
labels:
  app: api
  env: dev
  creator: AJ
# Incorrect:
labels:
  - app: api
  - env: dev
  - creator: AJ

################### SAME ERROR IF ###################
metadata:
  name: my-app
  labels:
    environment: production
    stable: true # <--- This causes the error!
-------------------- Booleans like true/false or 0/1 in Quotes ---------------------
```
