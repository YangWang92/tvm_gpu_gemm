#[version = "0.0.5"]
@main = primfn(a: handle, b: handle, c: handle) -> ()
  attr = {"tir.noalias": True, "global_symbol": "main"}
  buffers = {A: Buffer(A_1: Pointer(global int8), int8, [1024, 512, 16, 32], []),
             B: Buffer(B_1: Pointer(global int8), int8, [1024, 512, 16, 32], []),
             C: Buffer(C_1: Pointer(global int32), int32, [1024, 1024, 16, 16], [])}
  buffer_map = {a: A, b: B, c: C} {
  block([], "root") {
    tir.reads([])
    tir.writes([])
    A_shared = alloc_buffer(int8[1024, 512, 16, 32])
    A_shared_warp = alloc_buffer(int8[1024, 512, 32, 16])
    B_shared = alloc_buffer(int8[1024, 512, 16, 32])
    B_shared_warp = alloc_buffer(int8[1024, 512, 32, 16])
    C_warp = alloc_buffer(int32[1024, 1024, 32, 8])
    for (ii_0: int32, 0, 64) "thread_binding" {
      for (jj_0: int32, 0, 256) "thread_binding" {
        for (ii_1: int32, 0, 4) "thread_binding" {
          for (jj_1: int32, 0, 1) "thread_binding" {
            for (ii_2_init: int32, 0, 4) {
              for (jj_2_init: int32, 0, 4) {
                block([1024, 1024, 1, 1], "B_init_o") as [vii, vjj, vi_o, vj_o] {
                  bind(vii, (((ii_0*16) + (ii_1*4)) + ii_2_init))
                  bind(vjj, (((jj_0*4) + (jj_1*4)) + jj_2_init))
                  bind(vi_o, 0)
                  bind(vj_o, 0)
                  tir.reads([])
                  tir.writes([C_warp[vii, vjj, 0:32, 0:8]])
                  C_warp_1 = match_buffer(C_warp[vii, vjj, 0:32, 0:8])
                  attr [IterVar(tx: int32, [0:32], "ThreadIndex", "threadIdx.x")] "thread_extent" = 32;
                  @tir.mma_fill(8, C_warp_2: Pointer(warp int32), elem_offset: int32, dtype=int32)
              }
            }
            for (kk_0: int32, 0, 256) {
              for (ax0_ax1_ax2_ax3_fused_0: int32, 0, 4) "thread_binding" {
                for (ax0_ax1_ax2_ax3_fused_1: int32, 0, 1) "thread_binding" {
                  for (ax0_ax1_ax2_ax3_fused_2: int32, 0, 8) {
                    for (ax0_ax1_ax2_ax3_fused_3: int32, 0, 32) "thread_binding" {
                      for (ax0_ax1_ax2_ax3_fused_4: int32, 0, 16) "vectorized" {
                        block([1024, 512, 16, 32], "A_shared") as [v0, v1, v2, v3] {
                          bind(v0, ((ii_0*16) + floordiv((((((ax0_ax1_ax2_ax3_fused_0*4096) + (ax0_ax1_ax2_ax3_fused_1*4096)) + (ax0_ax1_ax2_ax3_fused_2*512)) + (ax0_ax1_ax2_ax3_fused_3*16)) + ax0_ax1_ax2_ax3_fused_4), 1024)))
                          bind(v1, ((kk_0*2) + floordiv(floormod((((((ax0_ax1_ax2_ax3_fused_0*4096) + (ax0_ax1_ax2_ax3_fused_1*4096)) + (ax0_ax1_ax2_ax3_fused_2*512)) + (ax0_ax1_ax2_ax3_fused_3*16)) + ax0_ax1_ax2_ax3_fused_4), 1024), 512)))
                          bind(v2, floordiv(floormod((((((ax0_ax1_ax2_ax3_fused_0*4096) + (ax0_ax1_ax2_ax3_fused_1*4096)) + (ax0_ax1_ax2_ax3_fused_2*512)) + (ax0_ax1_ax2_ax3_fused_3*16)) + ax0_ax1_ax2_ax3_fused_4), 512), 32))
                          bind(v3, floormod((((((ax0_ax1_ax2_ax3_fused_0*4096) + (ax0_ax1_ax2_ax3_fused_1*4096)) + (ax0_ax1_ax2_ax3_fused_2*512)) + (ax0_ax1_ax2_ax3_fused_3*16)) + ax0_ax1_ax2_ax3_fused_4), 32))
                          tir.reads([A[v0, v1, ((floormod(v2, 8)*2) + floordiv(v3, 16)), ((floordiv(v2, 8)*16) + floormod(v3, 16))]])
                          tir.writes([A_shared[v0, v1, v2, v3]])
                          A_shared[v0, v1, v2, v3] = A[v0, v1, ((floormod(v2, 8)*2) + floordiv(v3, 16)), ((floordiv(v2, 8)*16) + floormod(v3, 16))]
                      }
                    }
                  }
                }
              }
              for (ax0_ax1_ax2_ax3_fused_0_1: int32, 0, 4) "thread_binding" {
                for (ax0_ax1_ax2_ax3_fused_1_1: int32, 0, 1) "thread_binding" {
                  for (ax0_ax1_ax2_ax3_fused_2_1: int32, 0, 2) {
                    for (ax0_ax1_ax2_ax3_fused_3_1: int32, 0, 32) "thread_binding" {
                      for (ax0_ax1_ax2_ax3_fused_4_1: int32, 0, 16) "vectorized" {
                        block([1024, 512, 16, 32], "B_shared") as [v0_1, v1_1, v2_1, v3_1] {
                          bind(v0_1, ((jj_0*4) + floordiv((((((ax0_ax1_ax2_ax3_fused_0_1*1024) + (ax0_ax1_ax2_ax3_fused_1_1*1024)) + (ax0_ax1_ax2_ax3_fused_2_1*512)) + (ax0_ax1_ax2_ax3_fused_3_1*16)) + ax0_ax1_ax2_ax3_fused_4_1), 1024)))
                          bind(v1_1, ((kk_0*2) + floordiv(floormod((((((ax0_ax1_ax2_ax3_fused_0_1*1024) + (ax0_ax1_ax2_ax3_fused_1_1*1024)) + (ax0_ax1_ax2_ax3_fused_2_1*512)) + (ax0_ax1_ax2_ax3_fused_3_1*16)) + ax0_ax1_ax2_ax3_fused_4_1), 1024), 512)))
                          bind(v2_1, floordiv(floormod((((((ax0_ax1_ax2_ax3_fused_0_1*1024) + (ax0_ax1_ax2_ax3_fused_1_1*1024)) + (ax0_ax1_ax2_ax3_fused_2_1*512)) + (ax0_ax1_ax2_ax3_fused_3_1*16)) + ax0_ax1_ax2_ax3_fused_4_1), 512), 32))
                          bind(v3_1, floormod((((((ax0_ax1_ax2_ax3_fused_0_1*1024) + (ax0_ax1_ax2_ax3_fused_1_1*1024)) + (ax0_ax1_ax2_ax3_fused_2_1*512)) + (ax0_ax1_ax2_ax3_fused_3_1*16)) + ax0_ax1_ax2_ax3_fused_4_1), 32))
                          tir.reads([B[v0_1, v1_1, (((floordiv(v2_1, 8)*8) + (floormod(v2_1, 4)*2)) + floordiv(v3_1, 16)), ((floordiv(floormod(v2_1, 8), 4)*16) + floormod(v3_1, 16))]])
                          tir.writes([B_shared[v0_1, v1_1, v2_1, v3_1]])
                          B_shared[v0_1, v1_1, v2_1, v3_1] = B[v0_1, v1_1, (((floordiv(v2_1, 8)*8) + (floormod(v2_1, 4)*2)) + floordiv(v3_1, 16)), ((floordiv(floormod(v2_1, 8), 4)*16) + floormod(v3_1, 16))]
                      }
                    }
                  }
                }
              }
              for (kk_1: int32, 0, 2) {
                for (ax0: int32, 0, 4) {
                  block([1024, 512, 1, 1], "A_shared_warp_o") as [v0_2, v1_2, v2_o, v3_o] {
                    bind(v0_2, (((ii_0*16) + (ii_1*4)) + ax0))
                    bind(v1_2, ((kk_0*2) + kk_1))
                    bind(v2_o, 0)
                    bind(v3_o, 0)
                    tir.reads([A_shared[v0_2, v1_2, 0:16, 0:32]])
                    tir.writes([A_shared_warp[v0_2, v1_2, 0:32, 0:16]])
                    warp = match_buffer(A_shared_warp[v0_2, v1_2, 0:32, 0:16])
                    shared = match_buffer(A_shared[v0_2, v1_2, 0:16, 0:32])
                    attr [IterVar(tx_1: int32, [0:32], "ThreadIndex", "threadIdx.x")] "thread_extent" = 32;
                    @tir.ptx_ldmatrix(False, 4, ".b16", warp_1: Pointer(warp int8), (elem_offset_1: int32 + (16*tx_1)), @tir.tvm_access_ptr(@tir.type_annotation(, dtype=int8), shared_1: Pointer(shared int8), elem_offset_2: int32, (shared_s0: int32*16), 1, dtype=handle), (16*tx_1), dtype=int8)
                }
                for (ax0_1: int32, 0, 4) {
                  block([1024, 512, 1, 1], "B_shared_warp_o") as [v0_3, v1_3, v2_o_1, v3_o_1] {
                    bind(v0_3, ((jj_0*4) + ax0_1))
                    bind(v1_3, ((kk_0*2) + kk_1))
                    bind(v2_o_1, 0)
                    bind(v3_o_1, 0)
                    tir.reads([B_shared[v0_3, v1_3, 0:16, 0:32]])
                    tir.writes([B_shared_warp[v0_3, v1_3, 0:32, 0:16]])
                    warp_2 = match_buffer(B_shared_warp[v0_3, v1_3, 0:32, 0:16])
                    shared_2 = match_buffer(B_shared[v0_3, v1_3, 0:16, 0:32])
                    attr [IterVar(tx_2: int32, [0:32], "ThreadIndex", "threadIdx.x")] "thread_extent" = 32;
                    @tir.ptx_ldmatrix(False, 4, ".b16", warp_3: Pointer(warp int8), (elem_offset_3: int32 + (16*tx_2)), @tir.tvm_access_ptr(@tir.type_annotation(, dtype=int8), shared_3: Pointer(shared int8), elem_offset_4: int32, (shared_s0_1: int32*16), 1, dtype=handle), (16*tx_2), dtype=int8)
                }
                for (ii_2: int32, 0, 4) {
                  for (jj_2: int32, 0, 4) {
                    block([1024, 1024, tir.reduce_axis(0, 512), 1, 1, tir.reduce_axis(0, 1)], "B_update_o") as [vii_1, vjj_1, vkk, vi_o_1, vj_o_1, vk_o] {
                      bind(vii_1, (((ii_0*16) + (ii_1*4)) + ii_2))
                      bind(vjj_1, (((jj_0*4) + (jj_1*4)) + jj_2))
                      bind(vkk, ((kk_0*2) + kk_1))
                      bind(vi_o_1, 0)
                      bind(vj_o_1, 0)
                      bind(vk_o, 0)
                      tir.reads([C_warp[vii_1, vjj_1, 0:32, 0:8], A_shared_warp[vii_1, vkk, 0:32, 0:16], B_shared_warp[vjj_1, vkk, 0:32, 0:16]])
                      tir.writes([C_warp[vii_1, vjj_1, 0:32, 0:8]])
                      A_2 = match_buffer(A_shared_warp[vii_1, vkk, 0:32, 0:16])
                      B_2 = match_buffer(B_shared_warp[vjj_1, vkk, 0:32, 0:16])
                      C_2 = match_buffer(C_warp[vii_1, vjj_1, 0:32, 0:8])
                      attr [IterVar(tx_3: int32, [0:32], "ThreadIndex", "threadIdx.x")] "thread_extent" = 32 {
                        @tir.ptx_mma("m16n8k32", "row", "col", "int8", "int8", "int32", A_3: Pointer(warp int8), (elem_offset_5: int32 + (tx_3*16)), B_3: Pointer(warp int8), (elem_offset_6: int32 + (tx_3*16)), C_3: Pointer(warp int32), (elem_offset_7: int32 + (tx_3*8)), False, dtype=int32)
                        @tir.ptx_mma("m16n8k32", "row", "col", "int8", "int8", "int32", A_3, (elem_offset_5 + (tx_3*16)), B_3, ((elem_offset_6 + (tx_3*16)) + floordiv(16, 2)), C_3, ((elem_offset_7 + (tx_3*8)) + floordiv(8, 2)), False, dtype=int32)
                      }
                  }
                }
              }
            }
            for (ax0_2: int32, 0, 4) {
              for (ax1: int32, 0, 4) {
                block([1024, 1024, 1, 1], "C_warp_o") as [v0_4, v1_4, v2_o_2, v3_o_2] {
                  bind(v0_4, (((ii_0*16) + (ii_1*4)) + ax0_2))
                  bind(v1_4, ((jj_0*4) + ax1))
                  bind(v2_o_2, 0)
                  bind(v3_o_2, 0)
                  tir.reads([C_warp[v0_4, v1_4, 0:32, 0:8]])
                  tir.writes([C[v0_4, v1_4, 0:16, 0:16]])
                  C_warp_3 = match_buffer(C_warp[v0_4, v1_4, 0:32, 0:8])
                  C_4 = match_buffer(C[v0_4, v1_4, 0:16, 0:16])
                  attr [IterVar(tx_4: int32, [0:32], "ThreadIndex", "threadIdx.x")] "thread_extent" = 32;
                  @tir.mma_store(16, 16, @tir.tvm_access_ptr(@tir.type_annotation(, dtype=int32), C_5: Pointer(global int32), elem_offset_8: int32, (C_s0: int32*16), 2, dtype=handle), C_warp_4: Pointer(warp int32), elem_offset_9: int32, C_s0, dtype=int32)
              }
            }
          }
        }
      }
    }
}

#[metadata]
{
  "root": 1, 
  "nodes": [
    {
      "type_key": ""
    }, 
    {
      "type_key": "Map", 
      "keys": [
        "IntImm"
      ], 
      "data": [2]
    }, 
    {
      "type_key": "Array", 
      "data": [3]
    }, 
    {
      "type_key": "IntImm", 
      "attrs": {
        "dtype": "bool", 
        "span": "0", 
        "value": "1"
      }
    }
  ], 
  "b64ndarrays": [], 
  "attrs": {"tvm_version": "0.11.dev0"}
}