# OpenAPI 注释约定

`backend/generate_openapi.vsh` 会扫描 `backend/route` 和 `backend/service`，生成 `backend/openapi.json`。

默认响应状态码说明会优先参考 `backend/common/api/http_response.v` 中的 `json_success_xxx` / `json_error_xxx` 定义。

生成命令：

```bash
v run backend/generate_openapi.vsh
```

或：

```bash
./backend/generate_openapi.vsh
```

## 注释放置位置

- 接口级注释：写在 `@['...']` 路由注解的正上方，紧贴 handler 函数。
- 字段级注释：写在 DTO 字段的正上方。

## 支持的 6 个注释标签

### 1. `@summary`

接口标题，建议一句话描述接口用途。

```v
// @summary 获取用户列表
```

### 2. `@description`

接口详细说明，可以描述筛选条件、业务语义、注意事项。

```v
// @description 分页查询系统用户，支持按部门、用户名、昵称、手机号、邮箱筛选。
```

### 3. `@tag`

接口分组，可重复声明多次。

```v
// @tag sys_admin/user
```

### 4. `@security`

接口鉴权方式。当前生成器内置支持 `bearerAuth`。

```v
// @security bearerAuth
```

如果接口不需要鉴权，不写即可。  
如果你想显式覆盖掉路由默认鉴权，可以写：

```v
// @security none
```

### 5. `@response`

定义响应状态码、响应类型和说明。

语法：

```text
@response <status_code> <type_name> <description>
```

示例：

```v
// @response 200 GetUserListResp 查询成功
// @response 400 api.ApiErrorResponse 请求参数错误
// @response 401 api.ApiErrorResponse 未登录
// @response 403 api.ApiErrorResponse 无权限
// @response 500 api.ApiErrorResponse 服务器内部错误
```

说明：

- `2xx` 响应里的 `type_name` 表示业务数据类型，生成器会自动包装成 `ApiSuccessResponse_xxx`。
- `4xx/5xx` 通常使用 `api.ApiErrorResponse` 或 `ApiErrorResponse`。
- `type_name` 支持当前文件中的 DTO 名称，例如 `GetUserListResp`。
- `type_name` 也支持数组写法，例如 `[]GetUserList`。

### 6. `@example`

定义字段示例值，写在 DTO 字段注释上。

```v
// @example 1
page int = 1 @[json: 'page']

// @example "admin"
username ?string @[json: 'username']

// @example ["admin","editor"]
role_codes []string @[json: 'roleCodes']
```

说明：

- 推荐使用合法 JSON 字面量，生成器会按 JSON 解析。
- 如果不是合法 JSON，会按字符串处理。

## 完整示例

```v
// @summary 获取用户列表
// @description 分页查询系统用户，支持按部门、用户名、昵称、手机号、邮箱筛选。
// @tag sys_admin/user
// @security bearerAuth
// @response 200 GetUserListResp 查询成功
// @response 400 api.ApiErrorResponse 请求参数错误
// @response 401 api.ApiErrorResponse 未登录
// @response 403 api.ApiErrorResponse 无权限
// @response 500 api.ApiErrorResponse 服务器内部错误
@['/list'; post]
pub fn (app &User) user_list_handler(mut ctx Context) veb.Result {
	...
}

pub struct GetUserListReq {
	// 页码，从 1 开始。
	// @example 1
	page int = 1 @[json: 'page']

	// 每页条数。
	// @example 10
	page_size int = 10 @[json: 'pageSize']

	// 用户名，可选。
	// @example "admin"
	username ?string @[json: 'username']
}
```

## 默认行为

即使不写这些标签，生成器也会继续工作：

- 路由路径仍然来自 `backend/route` + `@['...']`
- `summary` 默认使用 handler 函数名
- `tag` 默认使用模块路径，例如 `sys_admin_api/user`
- 受保护路由默认带 `bearerAuth`
- `Req` / `Resp` 结构体仍然会转换成 OpenAPI schema

## 建议

- `@summary` 保持一句话，面向接口调用方。
- `@description` 写业务说明，不要重复 `summary`。
- `@response` 至少补 `200` 和常见错误码。
- `@example` 尽量使用真实但安全的样例值。
- DTO 里 `?T` 表示可选字段，OpenAPI 会按可选字段生成。
