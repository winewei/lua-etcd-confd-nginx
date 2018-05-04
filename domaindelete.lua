local json = require "cjson"
local http = require "resty.http"
local httpc = http.new()
local t = {}

local request_method = ngx.var.request_method
if "GET" == request_method then
        ngx.say("Hi.")
        ngx.exit(200)
end

ngx.req.read_body()
local p_args = ngx.req.get_post_args()

-- 判断参数的完整性
if (p_args.companyId == nil) or (p_args.domain == nil) then
	t["code"] = 9999
	t["msg"] = "Invalid parameter"
	ngx.say(json.encode(t))
	ngx.exit(500)
end

-- 判断port是否是数字
t["companyId"] = p_args.companyId
t["domain"] = p_args.domain
t["status"] = "delete"
-- 定义入etcd的key
local key = p_args.companyId .. "_" .. p_args.domain

local etcd_value = "value=" .. tostring(json.encode(t))
api_uri = ngx.var.uri
url = "http://127.0.0.1:2379/v2/keys/user_domain/"
local create_directory_response, err = httpc:request_uri(url .. key, {
	method = "DELETE",
	headers = {
	  ["Content-Type"] = "application/x-www-form-urlencoded",
	}
})
ngx.say(json.encode(t))
ngx.log(ngx.ERR,"post_data: ",json.encode(t))
ngx.log(ngx.ERR,"response_data:  ",create_directory_response.body)

