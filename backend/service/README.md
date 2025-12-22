## **Handler:**

xxx_handler

## **Usecase:**

- get_xxx_usecase：如果是获取数据并且数据有明确的唯一标识（ID），可以改为 retrieve_xxx_usecase 或 fetch_xxx_usecase
- find_xxx_usecase：可以保持不变，但如果这个操作是 条件查询，可以考虑改为 search_xxx_usecase 或 query_xxx_usecase，使得操作更能体现查询过滤的意图
- save_xxx_usecase：可以替换为 create_xxx_usecase，如果它是用于创建新对象，或者 upsert_xxx_usecase（如果是增/改操作）
- delete_xxx_usecase：如果是软删除或更新状态，可以改为 remove_xxx_usecase 或 soft_delete_xxx_usecase，这样可以避免误解
- update_xxx_usecase：如果是更新操作，可以考虑改为 modify_xxx_usecase 或 patch_xxx_usecase，让其更加准确表达业务操作

## **Domain:**

- validate_xxx：验证业务规则，例如字段必填、值范围、逻辑约束
- process_xxx：处理业务逻辑，通常涉及多个实体或聚合根
- calculate_xxx：计算业务属性，例如金额、积分、汇率
- apply_xxx：应用业务操作，例如应用折扣、更新状态
- convert_xxx：DTO、VO 或其他对象转换
- build_xxx：构建领域对象或聚合根实例

## **DTO:**

| 类型     | 命名方式                          | 说明                                         |
| -------- | --------------------------------- | -------------------------------------------- |
| 请求对象 | `XxxInput`                        | 用于请求的输入对象，适用于 POST/PUT 请求。   |
| 响应对象 | `XxxOutput`                       | 用于响应的输出对象，适用于 GET 请求。        |
| 创建对象 | `CreateXxxReq` / `CreateXxxInput` | 用于创建操作的请求对象。                     |
| 更新对象 | `UpdateXxxReq` / `UpdateXxxInput` | 用于更新操作的请求对象。                     |
| 分页请求 | `XxxPageReq`                      | 带有分页参数的请求对象。                     |
| 查询对象 | `XxxSearch` / `XxxFilter`         | 用于筛选/查询的请求对象。                    |
| 删除对象 | `DeleteXxxReq` / `DeleteXxxInput` | 用于删除操作的请求对象。                     |
| 通用对象 | `XxxDTO`                          | 通用数据对象，适用于输入和输出都相同的场景。 |

## **Repository:**

##### 基本 CRUD 操作（增删改查）

- get_xxx(id): 必定有
- save_xxx(entity): 同时包含 新增/更新 功能
- create_xxx: 明确的 创建新实体 或 新记录
- update_xxx(entity): 明确更新
- delete_xxx(id): 物理删除

##### 集合与批量操作（批量新增/更新/删除）

- add_xxx_to_xxx: 将新实体添加到集合中; 例如：add_item_to_cart，add_role_to_user。适用于向某个已有的集合、聚合中新增元素
- save_xxx_list(entities)：批量新增/更新
- update_xxx_list(entities)：批量更新
- delete_xxx_list(ids)：批量物理删除
- soft_delete_xxx_list(ids) / mark_xxx_as_deleted_list(ids)：批量软删除
- archive_xxx_list(ids)：批量归档

##### 软删除与归档（数据标记或移动）

- soft_delete_xxx / mark_xxx_as_deleted: 软删除,使用标记字段
- archive_xxx: 删除后数据不在主表，而是存档

##### 按条件更新

- update_xxx_by_field(field, value, updates)：按条件更新
- soft_delete_xxx_by_field(field, value)：按条件软删除

##### 按条件查询

- find_xxx_by_field(field): 可能找不到
- find_xxx_list_by_field(field): 返回列表
- exists_xxx_by_field(field): 是否存在
- query_xxx(filter): 分页/复杂查询

##### 统计/聚合函数

- count_xxx_by_field(field): 数量
- sum_xxx_by_field(field, conditions)：按条件求和
- avg_xxx_by_field(field, conditions)：按条件求平均
- max_xxx_by_field(field, conditions): 按条件求最大值
- min_xxx_by_field(field, conditions): 按条件求最小值

##### 存在与检查

- is_xxx_exists(id)：按 ID 判断
- is_xxx_exists_by_conditions(conditions)：按条件判断
