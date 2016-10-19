# lua-file-upload
基于Openresty的文件上传API

# 配置
```
$save_tempdr    #: 临时文件存放目录 , 权限需同Nginx 运行用户相同
$upload_root    #: 文件上传落地目录 , 权限需同Nginx 运行用户相同
$render_url     #: 文件上传成功后, 返回时的请求URL
```

# 使用
## 使用项目内自带的demo配置运行
```
$PATH/sbin/nginx -c $PATH/lua-file-upload/nginx.conf
```

## 测试 API
```
curl -i http://localhost:8000/api
HTTP/1.1 200 OK
Date: Tue, 18 Oct 2016 11:20:22 GMT
Content-Type: application/json
Transfer-Encoding: chunked
Connection: keep-alive

{"message": "Welcome Blob Service."}


#: 文件上传
curl -i -X POST -H "Content-Type: multipart/form-data;" -F "path=test" -F "file=@./ok.txt" "http://localhost:8000/api/upload"
HTTP/1.1 100 Continue

HTTP/1.1 200 OK
Date: Tue, 18 Oct 2016 11:19:58 GMT
Content-Type: application/json
Transfer-Encoding: chunked
Connection: keep-alive

{"file":"ok.txt","size":0,"path":"coreos.me\/test\/ok.txt"}

#: 如果文件存在, 替换文件
curl -i -X POST -H "Content-Type: multipart/form-data;" -F "path=test" -F "force=true" -F "file=@./ok.txt" "http://localhost:8000/api/upload"
HTTP/1.1 100 Continue

HTTP/1.1 200 OK
Date: Wed, 19 Oct 2016 02:19:41 GMT
Content-Type: application/json
Transfer-Encoding: chunked
Connection: keep-alive

{"file":"ok.txt","size":0,"path":"coreos.me\/test\/ok.txt"}
```



