# Firegroup
Process to deploy this API to K8S
- Write shell script and python flask app follow the requirement
- Dockerize this api and build it
- After build successfully, push image to dockerhub
- Write file yaml to create deloyment and service use this image
- Apply file yaml to k8s cluster and waiting for it show status running
- Then use command port-forward to run this api.
- Check result via URL: localhost:5000
