module middleware

// import (
// 	"errors"
// 	"net/http"

// 	"github.com/redis/go-redis/v9"
// 	"github.com/suyuan32/simple-admin-common/i18n"
// 	"github.com/suyuan32/simple-admin-common/orm/ent/entctx/datapermctx"
// 	"github.com/suyuan32/simple-admin-common/orm/ent/entctx/deptctx"
// 	"github.com/suyuan32/simple-admin-common/orm/ent/entctx/rolectx"
// 	"github.com/suyuan32/simple-admin-common/orm/ent/entenum"
// 	"github.com/zeromicro/go-zero/core/errorx"
// 	"github.com/zeromicro/go-zero/core/logx"
// 	"github.com/zeromicro/go-zero/rest/httpx"

// 	"github.com/suyuan32/simple-admin-core/rpc/coreclient"
// 	"github.com/suyuan32/simple-admin-core/rpc/types/core"
// )

// type DataPermMiddleware struct {
// 	Rds     redis.UniversalClient
// 	CoreRpc coreclient.Core
// 	Trans   *i18n.Translator
// }

// func NewDataPermMiddleware(rds redis.UniversalClient, coreRpcClient coreclient.Core, trans *i18n.Translator) *DataPermMiddleware {
// 	return &DataPermMiddleware{
// 		Rds:     rds,
// 		CoreRpc: coreRpcClient,
// 		Trans:   trans,
// 	}
// }

// func (m *DataPermMiddleware) Handle(next http.HandlerFunc) http.HandlerFunc {
// 	return func(w http.ResponseWriter, r *http.Request) {
// 		ctx := r.Context()
// 		var subDept, dataScope, customDept string

// 		deptId, err := deptctx.GetDepartmentIDFromCtx(ctx)
// 		if err != nil {
// 			httpx.Error(w, err)
// 			return
// 		}

// 		roleCodes, err := rolectx.GetRoleIDFromCtx(ctx)
// 		if err != nil {
// 			httpx.Error(w, err)
// 			return
// 		}

// 		dataScope, err = m.Rds.Get(ctx, datapermctx.GetRoleScopeDataPermRedisKey(roleCodes)).Result()
// 		if err != nil {
// 			if errors.Is(err, redis.Nil) {
// 				_, err = m.CoreRpc.InitRoleDataPermToRedis(ctx, &core.Empty{})
// 				if err != nil {
// 					httpx.Error(w, err)
// 					return
// 				}

// 				dataScope, err = m.Rds.Get(ctx, datapermctx.GetRoleScopeDataPermRedisKey(roleCodes)).Result()
// 				if err != nil {
// 					httpx.Error(w, errorx.NewInternalError(m.Trans.Trans(ctx, i18n.RedisError)))
// 					return
// 				}
// 			} else {
// 				logx.Error("redis error", logx.Field("detail", err))
// 				httpx.Error(w, errorx.NewInternalError(m.Trans.Trans(ctx, i18n.RedisError)))
// 				return
// 			}
// 		}

// 		ctx = datapermctx.WithScopeContext(ctx, dataScope)

// 		if dataScope == entenum.DataPermOwnDeptAndSubStr {
// 			subDept, err = m.Rds.Get(ctx, datapermctx.GetSubDeptDataPermRedisKey(deptId)).Result()
// 			if err != nil {
// 				if errors.Is(err, redis.Nil) {
// 					_, err = m.CoreRpc.InitDeptDataPermToRedis(ctx, &core.Empty{})
// 					if err != nil {
// 						httpx.Error(w, err)
// 						return
// 					}

// 					subDept, err = m.Rds.Get(ctx, datapermctx.GetSubDeptDataPermRedisKey(deptId)).Result()
// 					if err != nil {
// 						httpx.Error(w, errorx.NewInternalError(m.Trans.Trans(ctx, i18n.RedisError)))
// 						return
// 					}
// 				} else {
// 					logx.Error("redis error", logx.Field("detail", err))
// 					httpx.Error(w, errorx.NewInternalError(m.Trans.Trans(ctx, i18n.RedisError)))
// 					return
// 				}
// 			}

// 			ctx = datapermctx.WithSubDeptContext(ctx, subDept)
// 		}

// 		if dataScope == entenum.DataPermCustomDeptStr {
// 			customDept, err = m.Rds.Get(ctx, datapermctx.GetRoleCustomDeptDataPermRedisKey(roleCodes)).Result()
// 			if err != nil {
// 				if errors.Is(err, redis.Nil) {
// 					_, err = m.CoreRpc.InitDeptDataPermToRedis(ctx, &core.Empty{})
// 					if err != nil {
// 						httpx.Error(w, err)
// 						return
// 					}

// 					customDept, err = m.Rds.Get(ctx, datapermctx.GetRoleCustomDeptDataPermRedisKey(roleCodes)).Result()
// 					if err != nil {
// 						httpx.Error(w, errorx.NewInternalError(m.Trans.Trans(ctx, i18n.RedisError)))
// 						return
// 					}
// 				} else {
// 					logx.Error("redis error", logx.Field("detail", err))
// 					httpx.Error(w, errorx.NewInternalError(m.Trans.Trans(ctx, i18n.RedisError)))
// 					return
// 				}
// 			}

// 			ctx = datapermctx.WithCustomDeptContext(ctx, customDept)
// 		}

// 		next(w, r.WithContext(ctx))
// 	}
// }
