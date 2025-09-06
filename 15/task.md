# Install Docker/Podman, create a container running Nginx, map it to port 8080, and verifyservice.

## Step 1:
Install docker and run neccesary commands:
```bash
sudo apt update && sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
```
To refrest log out and log in again or run:
```bash
newgrp docker
```

## Step 2:
Run ngnix container:
```bash
docker run -d --name nginx-test -p 8080:80 nginx
```
Check if container is still running:
```bash
docker ps
```
test with curl:
```bash
curl http://localhost:8080
```