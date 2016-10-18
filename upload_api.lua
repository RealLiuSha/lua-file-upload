local lfs         = require("lfs")
local IO          = require("tzj.io")
local encode      = require("cjson.safe").encode
local stringy     = require("tzj.stringy")
local len         = string.len
local sub         = string.sub
local exec        = os.execute
local http_host   = ngx.var.http_host
local upload_root = ngx.var.upload_root
local save_tempdr = ngx.var.save_tempdr
local render_url  = ngx.var.render_url


local function folder_exists(folder_name)
    if lfs.attributes(folder_name:gsub("\\$",""),"mode") == "directory" then
        return true
    else
        return false
    end
end

local function render_folder_path(folder_name)
    local folder_name_head_len = 1
    local folder_name_tail_len = len(folder_name)

    if stringy.startswith(folder_name, '/') then
        folder_name_head_len = folder_name_head_len + 1
    end

    if stringy.endswith(folder_name, '/') then
        folder_name_tail_len = folder_name_tail_len - 1
    end

    return upload_root .. '/' .. sub(folder_name, folder_name_head_len, folder_name_tail_len) .. '/'
end

local function render_http_path(folder_name, filename)
    return render_url .. '/' .. folder_name .. '/' .. filename
end

local req_get, req_post, req_files = require "tzj.reqargs"({
    tmp_dir          = save_tempdr,
    timeout          = 1000,
    chunk_size       = 4096,
    max_get_args     = 100,
    mas_post_args    = 100,
    max_line_size    = 512,
    max_file_uploads = 10
})

if upload_root then
    if not folder_exists(upload_root) then
        ngx.status = 400
        ngx.say(encode({message="Bad upload_root!!!"}))
        return
    end
else
    ngx.status = 500
    ngx.say(encode({message="Upload_root Not Set.."}))
    return
end

if not req_post['path'] or not req_files.file then
    ngx.status = 400
    ngx.say(encode({message="Bad Request..."}))
    return
end

local file_path = render_folder_path(req_post['path'])
local full_file_path = file_path  .. req_files.file['file']

if not folder_exists(file_path) then
    local temp_path = ''
    local temp_path_arr = stringy.split(req_post['path'], '/')
    for i=1, #temp_path_arr do
        temp_path = temp_path .. '/' .. temp_path_arr[i]
        if not folder_exists(temp_path) then
            lfs.mkdir(upload_root .. temp_path)
        end
    end
end

if not IO.file_exists(full_file_path) then
    ngx.log(ngx.ERR, exec("mv " .. req_files.file['temp'] .. " " .. full_file_path), "\n")
else
    ngx.status = 400
    ngx.say(encode({message='this file already exists...'}))
    return
end


ngx.status = 200
ngx.say(encode({
   size=req_files.file['size'],
   file=req_files.file['file'],
   path=render_http_path(req_post['path'], req_files.file['file'])
}))
