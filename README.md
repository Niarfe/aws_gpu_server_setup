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

    LocalForward 8888 127.0.0.1:8888
```
* On local machine, first terminal
```
ssh awsgpu
```
* then start jupyter lab
```
. env/bin/activate; jupyter lab --ip=127.0.0.1 --port=8888 --no-browser
```
* On local machine on a second terminal, execute this again, it now auto starts the port forward
```
ssh awsgpu
```
* Back to first terminal, click link with 127.0.0.1, it should just open up on local


## Deprecated instructions, but good for skipping config
* On local machine if this is not set on config
```
ssh -L 8888:localhost:8888 awsgpu
```
