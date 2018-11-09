gcloud compute instances create \
  reddit-app-from-baked \
  --image-family reddit-full \
  --tags puma-server \
  --boot-disk-size=10GB \
  --machine-type=g1-small \
  --restart-on-failure
