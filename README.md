# aws_gpu_server_setup
# Setting up a CUDA server on AWS


# After server is running
* Upudate ip in `.ssh/config`
```
Host awsgpu
    HostName <aws public ip>
    User ubuntu
    ServerAliveInterval 60
    IdentityFile ~/.ssh/cuda_gpu.pem
```
* On local machine
```
ssh -L 8888:localhost:8888 awsgpu
```
* On remote EC2
```
. env/bin/activate; jupyter lab --ip=0.0.0.0 --port=8888 --no-browser
```
* Click link with 127.0.0.1, it should just open up on local
