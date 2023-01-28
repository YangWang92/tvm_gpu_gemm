# from tvm.script import tir as T
@T.prim_func
def func(A: T.Buffer[(1024, 512, 16, 32), "int8"], B: T.Buffer[(1024, 512, 16, 32), "int8"], C: T.Buffer[(1024, 1024, 16, 16), "int32"]):
    # function attr dict
    T.func_attr({"tir.noalias": True, "global_symbol": "main"})
    # body
    # with T.block("root")
    A_shared = T.alloc_buffer([1024, 512, 16, 32], dtype="int8", scope="shared")
    A_shared_warp = T.alloc_buffer([1024, 512, 32, 16], dtype="int8", scope="warp")
    B_shared = T.alloc_buffer([1024, 512, 16, 32], dtype="int8", scope="shared")
    B_shared_warp = T.alloc_buffer([1024, 512, 32, 16], dtype="int8", scope="warp")
    C_warp = T.alloc_buffer([1024, 1024, 32, 8], dtype="int32", scope="warp")
    for ii_0 in T.thread_binding(64, thread="blockIdx.x"):
        for jj_0 in T.thread_binding(256, thread="blockIdx.y"):
            for ii_1 in T.thread_binding(4, thread="threadIdx.y"):
                for jj_1 in T.thread_binding(1, thread="threadIdx.z"):
                    for ii_2_init, jj_2_init, i_init, j_init in T.grid(4, 4, 16, 16):
                        with T.block("B_init"):
                            vii = T.axis.spatial(1024, ii_0 * 16 + ii_1 * 4 + ii_2_init)
                            vjj = T.axis.spatial(1024, jj_0 * 4 + jj_1 * 4 + jj_2_init)
                            vi, vj = T.axis.remap("SS", [i_init, j_init])
                            T.reads()
                            T.writes(C_warp[vii, vjj, vi % 8 * 4 + vj % 8 // 2, vj // 8 * 4 + vi // 8 * 2 + vj % 2])
                            C_warp[vii, vjj, vi % 8 * 4 + vj % 8 // 2, vj // 8 * 4 + vi // 8 * 2 + vj % 2] = 0
                    for kk_0 in T.serial(256, annotations={"thread_rasterization":16}):
                        for ax0_ax1_ax2_ax3_fused_0 in T.thread_binding(4, thread="threadIdx.y"):
                            for ax0_ax1_ax2_ax3_fused_1 in T.thread_binding(1, thread="threadIdx.z"):
                                for ax0_ax1_ax2_ax3_fused_2 in T.serial(8):
                                    for ax0_ax1_ax2_ax3_fused_3 in T.thread_binding(32, thread="threadIdx.x"):
                                        for ax0_ax1_ax2_ax3_fused_4 in T.vectorized(16):
                                            with T.block("A_shared"):
                                                v0 = T.axis.spatial(1024, ii_0 * 16 + (ax0_ax1_ax2_ax3_fused_0 * 4096 + ax0_ax1_ax2_ax3_fused_1 * 4096 + ax0_ax1_ax2_ax3_fused_2 * 512 + ax0_ax1_ax2_ax3_fused_3 * 16 + ax0_ax1_ax2_ax3_fused_4) // 1024)
                                                v1 = T.axis.spatial(512, kk_0 * 2 + (ax0_ax1_ax2_ax3_fused_0 * 4096 + ax0_ax1_ax2_ax3_fused_1 * 4096 + ax0_ax1_ax2_ax3_fused_2 * 512 + ax0_ax1_ax2_ax3_fused_3 * 16 + ax0_ax1_ax2_ax3_fused_4) % 1024 // 512)
                                                v2 = T.axis.spatial(16, (ax0_ax1_ax2_ax3_fused_0 * 4096 + ax0_ax1_ax2_ax3_fused_1 * 4096 + ax0_ax1_ax2_ax3_fused_2 * 512 + ax0_ax1_ax2_ax3_fused_3 * 16 + ax0_ax1_ax2_ax3_fused_4) % 512 // 32)
                                                v3 = T.axis.spatial(32, (ax0_ax1_ax2_ax3_fused_0 * 4096 + ax0_ax1_ax2_ax3_fused_1 * 4096 + ax0_ax1_ax2_ax3_fused_2 * 512 + ax0_ax1_ax2_ax3_fused_3 * 16 + ax0_ax1_ax2_ax3_fused_4) % 32)
                                                T.reads(A[v0, v1, v2 % 8 * 2 + v3 // 16, v2 // 8 * 16 + v3 % 16])
                                                T.writes(A_shared[v0, v1, v2, v3])
                                                A_shared[v0, v1, v2, v3] = A[v0, v1, v2 % 8 * 2 + v3 // 16, v2 // 8 * 16 + v3 % 16]
                        for ax0_ax1_ax2_ax3_fused_0 in T.thread_binding(4, thread="threadIdx.y"):
                            for ax0_ax1_ax2_ax3_fused_1 in T.thread_binding(1, thread="threadIdx.z"):
                                for ax0_ax1_ax2_ax3_fused_2 in T.serial(2):
                                    for ax0_ax1_ax2_ax3_fused_3 in T.thread_binding(32, thread="threadIdx.x"):
                                        for ax0_ax1_ax2_ax3_fused_4 in T.vectorized(16):
                                            with T.block("B_shared"):
                                                v0 = T.axis.spatial(1024, jj_0 * 4 + (ax0_ax1_ax2_ax3_fused_0 * 1024 + ax0_ax1_ax2_ax3_fused_1 * 1024 + ax0_ax1_ax2_ax3_fused_2 * 512 + ax0_ax1_ax2_ax3_fused_3 * 16 + ax0_ax1_ax2_ax3_fused_4) // 1024)
                                                v1 = T.axis.spatial(512, kk_0 * 2 + (ax0_ax1_ax2_ax3_fused_0 * 1024 + ax0_ax1_ax2_ax3_fused_1 * 1024 + ax0_ax1_ax2_ax3_fused_2 * 512 + ax0_ax1_ax2_ax3_fused_3 * 16 + ax0_ax1_ax2_ax3_fused_4) % 1024 // 512)
                                                v2 = T.axis.spatial(16, (ax0_ax1_ax2_ax3_fused_0 * 1024 + ax0_ax1_ax2_ax3_fused_1 * 1024 + ax0_ax1_ax2_ax3_fused_2 * 512 + ax0_ax1_ax2_ax3_fused_3 * 16 + ax0_ax1_ax2_ax3_fused_4) % 512 // 32)
                                                v3 = T.axis.spatial(32, (ax0_ax1_ax2_ax3_fused_0 * 1024 + ax0_ax1_ax2_ax3_fused_1 * 1024 + ax0_ax1_ax2_ax3_fused_2 * 512 + ax0_ax1_ax2_ax3_fused_3 * 16 + ax0_ax1_ax2_ax3_fused_4) % 32)
                                                T.reads(B[v0, v1, v2 // 8 * 8 + v2 % 4 * 2 + v3 // 16, v2 % 8 // 4 * 16 + v3 % 16])
                                                T.writes(B_shared[v0, v1, v2, v3])
                                                B_shared[v0, v1, v2, v3] = B[v0, v1, v2 // 8 * 8 + v2 % 4 * 2 + v3 // 16, v2 % 8 // 4 * 16 + v3 % 16]
                        for kk_1 in T.serial(2):
                            for ax0, ax1, ax2 in T.grid(4, 16, 32):
                                with T.block("A_shared_warp"):
                                    v0 = T.axis.spatial(1024, ii_0 * 16 + ii_1 * 4 + ax0)
                                    v1 = T.axis.spatial(512, kk_0 * 2 + kk_1)
                                    v2, v3 = T.axis.remap("SS", [ax1, ax2])
                                    T.reads(A_shared[v0, v1, v2, v3])
                                    T.writes(A_shared_warp[v0, v1, v2 * 2 + v3 // 16, v3 % 16])
                                    A_shared_warp[v0, v1, v2 * 2 + v3 // 16, v3 % 16] = A_shared[v0, v1, v2, v3]
                            for ax0, ax1, ax2 in T.grid(4, 16, 32):
                                with T.block("B_shared_warp"):
                                    v0 = T.axis.spatial(1024, jj_0 * 4 + ax0)
                                    v1 = T.axis.spatial(512, kk_0 * 2 + kk_1)
                                    v2, v3 = T.axis.remap("SS", [ax1, ax2])
                                    T.reads(B_shared[v0, v1, v2, v3])
                                    T.writes(B_shared_warp[v0, v1, v2 * 2 + v3 // 16, v3 % 16])
                                    B_shared_warp[v0, v1, v2 * 2 + v3 // 16, v3 % 16] = B_shared[v0, v1, v2, v3]
                            for ii_2, jj_2, i, j, k in T.grid(4, 4, 16, 16, 32):
                                with T.block("B_update"):
                                    vii = T.axis.spatial(1024, ii_0 * 16 + ii_1 * 4 + ii_2)
                                    vjj = T.axis.spatial(1024, jj_0 * 4 + jj_1 * 4 + jj_2)
                                    vkk = T.axis.reduce(512, kk_0 * 2 + kk_1)
                                    vi, vj, vk = T.axis.remap("SSR", [i, j, k])
                                    T.reads(C_warp[vii, vjj, vi % 8 * 4 + vj % 8 // 2, vj // 8 * 4 + vi // 8 * 2 + vj % 2], A_shared_warp[vii, vkk, vi * 2 + vk // 16, vk % 16], B_shared_warp[vjj, vkk, vj * 2 + vk // 16, vk % 16])
                                    T.writes(C_warp[vii, vjj, vi % 8 * 4 + vj % 8 // 2, vj // 8 * 4 + vi // 8 * 2 + vj % 2])
                                    C_warp[vii, vjj, vi % 8 * 4 + vj % 8 // 2, vj // 8 * 4 + vi // 8 * 2 + vj % 2] = C_warp[vii, vjj, vi % 8 * 4 + vj % 8 // 2, vj // 8 * 4 + vi // 8 * 2 + vj % 2] + T.Cast("int32", A_shared_warp[vii, vkk, vi * 2 + vk // 16, vk % 16]) * T.Cast("int32", B_shared_warp[vjj, vkk, vj * 2 + vk // 16, vk % 16])
                    for ax0, ax1, ax2, ax3 in T.grid(4, 4, 16, 16):
                        with T.block("C_warp"):
                            v0 = T.axis.spatial(1024, ii_0 * 16 + ii_1 * 4 + ax0)
                            v1 = T.axis.spatial(1024, jj_0 * 4 + ax1)
                            v2, v3 = T.axis.remap("SS", [ax2, ax3])
                            T.reads(C_warp[v0, v1, v2 % 8 * 4 + v3 % 8 // 2, v3 // 8 * 4 + v2 // 8 * 2 + v3 % 2])
                            T.writes(C[v0, v1, v2, v3])
                            C[v0, v1, v2, v3] = C_warp[v0, v1, v2 % 8 * 4 + v3 % 8 // 2, v3 // 8 * 4 + v2 // 8 * 2 + v3 % 2]
