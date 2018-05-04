local json = require "cjson"
local http = require "resty.http"
local httpc = http.new()
local t = {}
local url = "http://127.0.0.1:2379/v2/keys/user_domain/"

local request_method = ngx.var.request_method
if "GET" == request_method then
        ngx.say("Hi.")
        ngx.exit(200)
end

ngx.req.read_body()
local p_args = ngx.req.get_post_args()

-- 判断参数的完整性
if (p_args.companyId == nil) or (p_args.domain == nil) or (p_args.port == nil) then
	t["code"] = 9999
	t["msg"] = "Invalid parameter"
	ngx.say(json.encode(t))
	ngx.exit(500)
end

-- 判断port是否是数字
if not tonumber(p_args.port) then
	t["code"] = 9998
	t["msg"] = "Invalid parameter, port is not a number."
	ngx.say(json.encode(t))
	ngx.exit(500)
end
t["companyId"] = p_args.companyId
t["domain"] = p_args.domain
t["port"] = p_args.port
t["code"] = 0
t["status"] = "add"

-- 定义入etcd的key
local key = p_args.companyId .. "_" .. p_args.domain
local etcd_value = "value=" .. tostring(json.encode(t))
local create_directory_response, err = httpc:request_uri(url .. key, {
	method = "PUT",
	body = etcd_value,
	headers = {
	  ["Content-Type"] = "application/x-www-form-urlencoded",
	}
})
ngx.say(json.encode(t))
ngx.log(ngx.ERR,"post_data: ",json.encode(t))
ngx.log(ngx.ERR,"response_data:  ",create_directory_response.body)
