

## 用户登录


**接口地址**:`/community/user/login`


**请求方式**:`POST`


**请求数据类型**:`application/json`


**响应数据类型**:`*/*`


**接口描述**:


**请求参数**:


**请求参数**:


| 参数名称 | 参数说明 | 请求类型    | 是否必须 | 数据类型 | schema |
| -------- | -------- | ----- | -------- | -------- | ------ |
|password|password|query|true|string||
|username|username|query|true|string||


**响应状态**:


| 状态码 | 说明 | schema |
| -------- | -------- | ----- | 
|200|OK|Result«string»|
|201|Created||
|401|Unauthorized||
|403|Forbidden||
|404|Not Found||


**响应参数**:


| 参数名称 | 参数说明 | 类型 | schema |
| -------- | -------- | ----- |----- | 
|code||integer(int32)|integer(int32)|
|data||string||
|msg||string||


**响应示例**:
```javascript
{
	"code": 0,
	"data": "",
	"msg": ""
}
```




## 用户注册


**接口地址**:`/community/user/register`


**请求方式**:`POST`


**请求数据类型**:`application/json`


**响应数据类型**:`*/*`


**接口描述**:


**请求示例**:


```javascript
{
  "avatarUrl": "",
  "birthDate": "",
  "createTime": "",
  "email": "",
  "gender": 0,
  "id": 0,
  "location": "",
  "nickname": "",
  "password": "",
  "phone": "",
  "signature": "",
  "status": 0,
  "updateTime": "",
  "username": ""
}
```


**请求参数**:


**请求参数**:


| 参数名称 | 参数说明 | 请求类型    | 是否必须 | 数据类型 | schema |
| -------- | -------- | ----- | -------- | -------- | ------ |
|user|用户实体类|body|true|Users|Users|
|&emsp;&emsp;avatarUrl|头像URL||false|string||
|&emsp;&emsp;birthDate|生日||false|string(date-time)||
|&emsp;&emsp;createTime|创建时间||false|string(date-time)||
|&emsp;&emsp;email|邮箱||false|string||
|&emsp;&emsp;gender|性别: 0未知, 1男, 2女||false|integer(int32)||
|&emsp;&emsp;id|主键ID||false|integer(int64)||
|&emsp;&emsp;location|位置，可选||false|string||
|&emsp;&emsp;nickname|昵称||false|string||
|&emsp;&emsp;password|密码||false|string||
|&emsp;&emsp;phone|手机号||false|string||
|&emsp;&emsp;signature|个性签名||false|string||
|&emsp;&emsp;status|状态: 1正常, 0禁用||false|integer(int32)||
|&emsp;&emsp;updateTime|更新时间||false|string(date-time)||
|&emsp;&emsp;username|账号，暂时传账密码用于登录注册||false|string||


**响应状态**:


| 状态码 | 说明 | schema |
| -------- | -------- | ----- | 
|200|OK|Result«string»|
|201|Created||
|401|Unauthorized||
|403|Forbidden||
|404|Not Found||


**响应参数**:


| 参数名称 | 参数说明 | 类型 | schema |
| -------- | -------- | ----- |----- | 
|code||integer(int32)|integer(int32)|
|data||string||
|msg||string||


**响应示例**:
```javascript
{
	"code": 0,
	"data": "",
	"msg": ""
}
```

注册暂时只需要传账号密码和昵称即可

登录注册的前缀为http://47.94.84.165:8080/